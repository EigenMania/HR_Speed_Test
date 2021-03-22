using Toybox.Application;
using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Position;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;

class HR_Speed_TestApp extends Application.AppBase {
    var HR_Speed_Test_View;
    var HR_Speed_Test_Delegate;

    var initialSpeedWatchSetting;
    var deltaSpeedWatchSetting;
    var levelDurationWatchSetting;
    var watchSettings;

    var timer;
    var timer_method;
    var timer_period_ms = 1000;
    var timer_do_repeat = true;

    var current_activity_info;

    var split_time = 1 * 5;
    var split_counter = split_time;

    var start_speed = 4.0;
    var speed_increment = 0.5;
    var fail_speed_delta = 0.25;

    var desired_speed = start_speed;
    var current_speed = 0.0;

    var split_speed = 0.0;
    var split_distance = 0.0;

    var last_elapsed_time = 0.0;
    var current_elapsed_time = 0.0;

    // Constants for unit conversions
    var mps2kph = 3.6; // meters per second to kilometers per hour
    var kph2mps = (1.0 / me.mps2kph);
    var m2km = (1.0 / 1000.0); // meters to kilometers
    var s2hr = (1.0 / 3600.0); // seconds to hours
    var ms2s = (1.0 / 1000.0); // milliseconds to seconds

    // Speed and HR vectors
    var speed_array = [];
    var HR_array = [];
    var current_HR;

    // FitContributor Fields
    var desiredSpeedField;
    var currentSpeedField;
    var splitSpeedField;

    // Additional FitContributor crap for debugging
    var delta_d;
    var delta_t;
    var deltaDField;
    var deltaTField;

    var debug = true;

    function initialize() {
        //cout("initialize() AppBase...");

        me.timer = new Timer.Timer();
        me.initialSpeedWatchSetting = new SettingsNumberPickerDelegate();
        me.deltaSpeedWatchSetting = new SettingsNumberPickerDelegate();
        me.levelDurationWatchSetting = new SettingsNumberPickerDelegate();
        me.watchSettings = [me.initialSpeedWatchSetting, me.deltaSpeedWatchSetting, me.levelDurationWatchSetting];

        // TODO: Temporary disable update from properties to use hard-coded values;
        //updateFromProperties();

        Position.enableLocationEvents({
            :acquisitionType => Position.LOCATION_CONTINUOUS,
            :constellations => [Position.CONSTELLATION_GPS, Position.CONSTELLATION_GALILEO]
            }, method(:onPosition));

        me.timer_method = method(:timerCallback);
        me.timer.start(me.timer_method, me.timer_period_ms, me.timer_do_repeat);

        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        //cout("onStart()...");
    }

    function timerCallback() {
        //cout("timerCallback()...");
        // Update activity info
        loadCurrentActivityInfo();

        //cout(me.last_elapsed_distance);
        //cout(me.last_elapsed_time);
        //cout(me.current_elapsed_distance);
        //cout(me.current_elapsed_time);

        if (me.HR_Speed_Test_Delegate.session_active == true) {
            me.split_counter -= 1;
            updateSplitSpeed();
            logSpeedAndHR();
            logFitContributorData();

            if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
                Vibe.tooSlowWarning();
            }

            // TODO: helper function for failed level. Don't repeat code!
            // TODO: do not hard-code warning and failure conditions
            /*
            if (me.split_speed < (me.desired_speed - 4 * me.fail_speed_delta)) {
                // Automatically end activity and save.
                Vibe.levelFailed();
                me.HR_Speed_Test_Delegate.onFail();
            }
            */

            if (me.split_counter < 0) {
                cout("LEVEL UP!");
                levelUp();
            }
        }

        updateViewData();
        WatchUi.requestUpdate();
    }

    function updateViewData() {
        me.HR_Speed_Test_View.current_speed = me.current_speed;
        me.HR_Speed_Test_View.desired_speed = me.desired_speed;
        me.HR_Speed_Test_View.fail_speed_delta = me.fail_speed_delta;
        me.HR_Speed_Test_View.split_speed = me.split_speed;
        me.HR_Speed_Test_View.split_counter = me.split_counter;
    }

    function updateSplitSpeed() {
        //cout("updating split speed");
        me.split_distance += (me.current_speed * me.kph2mps); // Integrate split distance
        me.delta_t = (me.current_elapsed_time - me.last_elapsed_time) * me.s2hr; // in hours
        me.split_speed = (me.split_distance * me.m2km) / me.delta_t;
        //cout(Lang.format("Cur   Speed: $1$", [me.current_speed.format("%.2f")]));
        //cout(Lang.format("Split Speed: $1$", [me.split_speed.format("%.2f")]));
        cout(Lang.format("Integrated Split Distance: $1$", [me.split_distance]));
        cout(Lang.format("Current Split Speed:       $1$", [me.split_speed]));
    }

    function logSpeedAndHR() {
        me.HR_array.add(me.current_HR);
        me.speed_array.add(me.current_speed);
    }

    function logFitContributorData() {
        //cout("logging fit contributor data...");
        var myFormat = "v_des = $1$, v_cur = $2$, v_split = $3$";
        var myParams = [me.desired_speed.format("%.2f"),
                        me.current_speed.format("%.2f"),
                        me.split_speed.format("%.2f")];
        var myString = Lang.format(myFormat, myParams);
        cout(myString);

        me.desiredSpeedField.setData(me.desired_speed);
        me.currentSpeedField.setData(me.current_speed);
        me.splitSpeedField.setData(me.split_speed);
        //me.deltaDField.setData(me.delta_d);
        //me.deltaTField.setData(me.delta_t);
    }

    function loadCurrentActivityInfo() {
        cout("loading current activity info...");

        me.current_activity_info = Toybox.Activity.getActivityInfo();
        if (me.current_activity_info == null) {
            cout("Current activity info is null...");
            me.current_speed = 0.0;
            me.current_elapsed_time = 0.0;
            me.current_HR = 0.0;
        } else {
            if (me.current_activity_info.currentSpeed != null) {
                // Convert from mps to kph.
                me.current_speed = me.current_activity_info.currentSpeed * me.mps2kph;
            } else {
                cout("current speed was null...");
            }

            if (me.current_activity_info.elapsedTime != null) {
                // Convert from milliseconds to seconds
                me.current_elapsed_time = me.current_activity_info.elapsedTime * me.ms2s;
            } else {
                cout("current elapsed time was null...");
            }

            if (me.current_activity_info.currentHeartRate != null) {
                me.current_HR = me.current_activity_info.currentHeartRate;
            } else {
                //cout("current heart rate was null...");
            }
        }
        var myFormat = "Current Speed = $1$, Current Elapsed Time = $2$";
        var myParams = [me.current_speed.format("%.2f"), me.current_elapsed_time.format("%.3f")];
        var myString = Lang.format(myFormat, myParams);
        cout(myString);
    }

    function levelUp() {
        me.HR_Speed_Test_Delegate.session.addLap();

        // Check if we failed to achieve minimum average split speed
        if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
            // Automatically end activity and save.
            Vibe.levelFailed();
            me.HR_Speed_Test_Delegate.onFail();
        } else {
            // Reset split counters and increment target speed
            me.split_counter = me.split_time;
            me.split_distance = 0.0;
            me.desired_speed += me.speed_increment;
            me.last_elapsed_time = me.current_elapsed_time;
            Vibe.levelUp();
        }
    }

    // Helper function to load current properties.
    function updateFromProperties() {
        me.start_speed = HR_Speed_TestApp.getProperty("initialSpeedKph");
        me.desired_speed = me.start_speed;
        me.speed_increment = HR_Speed_TestApp.getProperty("deltaSpeedKph");
        me.split_time = HR_Speed_TestApp.getProperty("levelDurationS");
        me.split_counter = me.split_time;
    }

    // Callback for when settings are changed in
    // watch through the menu.
    function loadNewWatchSettings() {
        //cout("Loading new watch settings...");
        if (initialSpeedWatchSetting.myValue != null) {
            // Value is actually a distance in meters, so divide by 1000.
            me.start_speed = initialSpeedWatchSetting.myValue / 1000;
            me.desired_speed = initialSpeedWatchSetting.myValue / 1000;
        }
        if (deltaSpeedWatchSetting.myValue != null) {
            // Value is actually a distance in meters, so divide by 1000.
            me.speed_increment = deltaSpeedWatchSetting.myValue / 1000;
        }
        if (levelDurationWatchSetting.myValue != null) {
            // Value is a Time.Duration object, so use .value()
            me.split_time = levelDurationWatchSetting.myValue.value();
            me.split_counter = levelDurationWatchSetting.myValue.value();
        }
    }

    function onPosition(info) {
        //cout(info.speed * me.mps2kph);
        //cout(me.current_speed);
        return true;
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    function onSettingsChanged() {
        //cout("onSettingsChanged()...");
        // Only allow updates when testing is not in progress.
        if (me.HR_Speed_Test_Delegate.session_active == false) {
            updateFromProperties();
        }
    }

    function cout(string) {
        if (me.debug == true) {
            var clockTime = System.getClockTime();
            var msTime = System.getTimer();
            //var timeString = clockTime.hour.format("%02d") + ":" +
            //                 clockTime.min.format("%02d") + ":" +
            //                 clockTime.sec.format("%02d") + "." +
            //                 msTime.format("%06d") + ": ";
            var timeString = msTime.format("%06d") + ": ";
            System.println(timeString + string);
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        // TODO: Clean up and organize this function contents.
        //cout("getInitialView()...");

        me.HR_Speed_Test_View = new HR_Speed_TestView();
        updateViewData();

        me.HR_Speed_Test_Delegate = new HR_Speed_TestDelegate(me.watchSettings);

        return [ me.HR_Speed_Test_View, me.HR_Speed_Test_Delegate ];
    }

}