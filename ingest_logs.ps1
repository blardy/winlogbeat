param(
    [Parameter(Mandatory=$true)][string] $path,
    [Parameter(Mandatory=$true)][string] $case,
    [Parameter(Mandatory=$true)][string] $es_ip,
    [Parameter(Mandatory=$true)][string] $es_password,
    [Parameter(Mandatory=$true)][string] $es_index
)

# Registry file store the state of winlogbeat // for debug puprose I have set a temporary file & delete it to ingest the same file more than 1 time
$registry_file  = New-TemporaryFile
$conf_file = New-TemporaryFile
Write-Host "Generating temporary conf file => $($conf_file.FullName) (This file will be deleted at the end)"

"winlogbeat.event_logs:" | Out-File -Append -FilePath $conf_file.FullName
Get-ChildItem -Recurse -Path $path -Filter *.evtx | % {
@"
  - name: $($_.FullName)
    no_more_events: stop
    fields_under_root: true
    fields:
      case: $case
    processors:

      - dissect:
          when.contains.message: "\n"
          tokenizer: "%{short}\n%{_unused}"
          field: "message"
          target_prefix: "description"
      - dissect:
          when.not.contains.message: "\n"
          tokenizer: "%{short}"
          field: "message"
          target_prefix: "description"
      - drop_fields:
          fields: ["description._unused"]
      - script:
          when.equals.winlog.provider_name: Microsoft-Windows-Security-Auditing
          lang: javascript
          id: Microsoft-Windows-Security-Auditing
          file: ${path.home}/module/security/config/winlogbeat-security.js
      - script:
          when.equals.winlog.provider_name: Microsoft-Windows-Kernel-General
          lang: javascript
          id: Microsoft-Windows-Kernel-General
          file: ${path.home}/module/system/winlogbeat-lardyba-Microsoft-Windows-Kernel-General.js

    
"@ | Out-File -Append -FilePath $conf_file.FullName
}

@"

winlogbeat.shutdown_timeout: 30s
winlogbeat.registry_file: $registry_file
name: "IRIS ingest ps1"
#max_procs: 8
#==================== Elasticsearch template settings ==========================

setup.template.name: "winevt"
setup.template.pattern: "winevt-*"
setup.ilm.enabled: false

setup.template.settings:
  index.number_of_shards: 1
  index.number_of_replicas: 0

setup.kibana:
  host: `http://$($es_ip):5601"

#================================ Outputs =====================================

#-------------------------- Elasticsearch output ------------------------------
output.elasticsearch:
  hosts: [`"$($es_ip):9200`"]
  username: "elastic"
  password: `"$($es_password)`"
output.elasticsearch.index: "$es_index"
"@ | Out-File -Append -FilePath $conf_file.FullName

& "$PSScriptRoot\winlogbeat.exe" -e -c $conf_file.FullName

$conf_file.Delete()
$registry_file.Delete()