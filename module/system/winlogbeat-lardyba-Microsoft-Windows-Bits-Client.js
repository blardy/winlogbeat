
var bits = (function () {
    var path = require("path");
    var processor = require("processor");
    var winlogbeat = require("winlogbeat");


    var dissectURL = function(evt) {
		var bits_url = new URL(evt.Get("winlog.event_data.url"))

		evt.Put("winlog.event_data.url_parsed", bits_url);
    };

    var URLProcessor = new processor.Chain()
        .Add(dissectURL)
        .Build();


    return {
        // 59 - BITS started the <path> transfer job that is associated with the <URL>
        59: URLProcessor.Run,
		// 60 - BITS stopped transferring the Push Notification Platform Job
		60: URLProcessor.Run,
		// 61 - BITS stopped transferring the Push Notification Platform Job
		61: URLProcessor.Run,

        process: function(evt) {
            var event_id = evt.Get("winlog.event_id");
            var processor = this[event_id];
            if (processor === undefined) {
                return;
            }
            processor(evt);
        },
    };
})();

function process(evt) {
    return bits.process(evt);
}
