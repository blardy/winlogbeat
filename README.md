# winlogbeat
Collection of scripts &amp; modules for winlogbeat - EVTX parsing to ELK

Elasticsearch Configuration
--------
Everything works fine by default however it is recommended to update the following:
1. Create the index template
```
curl -X PUT "http://localhost:9200/_template/winevt?pretty" -H 'Content-Type: application/json' -uelastic -d@winevt.template
```


```
TODO index template
ES conf
fields limit....
Kibana setup / utc
```

How to get started
--------

1. First you need to download the winlogbeat archive that matches your Elasticsearch instance:
   - latest winlogbeat archive is here - https://www.elastic.co/fr/downloads/beats/winlogbeat
   - latest winlogbeat OSS version is here - https://www.elastic.co/fr/downloads/past-releases#winlogbeat-oss)
   
2. Extract the archive and copy/paste `module` folder and `ingest_logs.ps1` into the winlogbeat folder

3. Run `ingest_logs.ps1` to start ingest logs into your ES instance ! Indices were you insert your logs *MUST BE* named `winevt-whatever-you-want`

Examples
--------

Ingest a folder containing evtx files into `winevt-ir19-4242` indice:
```
.\ingest_logs.ps1 -path "D:\Some Path\Logs\" -es_ip 192.168.42.42 -es_index winevt-lab42 -case TEST-42 -es_password MySuperStrongPasssword
```
