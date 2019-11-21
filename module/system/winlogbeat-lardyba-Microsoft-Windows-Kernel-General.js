
var system = (function () {
    var path = require("path");
    var processor = require("processor");
    var winlogbeat = require("winlogbeat");


    var setDeltaTime = function(evt) {
        var new_time = new Date(evt.Get("winlog.event_data.NewTime"));
		var old_time = new Date(evt.Get("winlog.event_data.OldTime"));

		evt.Put("winlog.event_data.DeltaTime", new_time - old_time);
    };

    var SystemTimeChange = new processor.Chain()
        .Add(setDeltaTime)
        .Build();


    return {
        // 1 - The system time has changed. => compute delat Tiem (new - old)
        1: SystemTimeChange.Run,

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
    return system.process(evt);
}
