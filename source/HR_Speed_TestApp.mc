using Toybox.Application;
using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Position;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;

using HR_Speed_Test_Logger as Logger;

class HR_Speed_TestApp extends Application.AppBase {
    var HR_Speed_Test_View;
    var HR_Speed_Test_Delegate;
    var HR_Speed_Test_Vibe;

    var initialSpeedWatchSetting;
    var deltaSpeedWatchSetting;
    var levelDurationWatchSetting;
    var watchSettings;

    var timer;
    var timer_method;
    var timer_period_ms = 1000;
    var timer_do_repeat = true;

    var current_activity_info;

    var split_time = 60;
    var split_counter = split_time;

    var start_speed = 8.0;
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
    var delta_t;

    // Session objects
    var session = null;
    var session_active = false;

    function initialize() {
        // Setup logger with desired verbosity level.
        Logger.loggerLevel = Logger.LOG_LEVEL_1;
        Logger.LOG2("initialize() AppBase...");

        me.timer = new Timer.Timer();
        me.initialSpeedWatchSetting = new SettingsNumberPickerDelegate();
        me.deltaSpeedWatchSetting = new SettingsNumberPickerDelegate();
        me.levelDurationWatchSetting = new SettingsNumberPickerDelegate();
        me.watchSettings = [me.initialSpeedWatchSetting, me.deltaSpeedWatchSetting, me.levelDurationWatchSetting];

        updateFromProperties();

        // Vibrator ;)
        me.HR_Speed_Test_Vibe = new HR_Speed_TestVibe();

        // Enable GPS
        Position.enableLocationEvents({
            :acquisitionType => Position.LOCATION_CONTINUOUS,
            :constellations => [Position.CONSTELLATION_GPS, Position.CONSTELLATION_GALILEO]
            }, method(:onPosition));

        // Setup timer
        me.timer_method = method(:timerCallback);
        me.timer.start(me.timer_method, me.timer_period_ms, me.timer_do_repeat);

        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        Logger.LOG2("onStart()...");
    }

    function timerCallback() {
        Logger.LOG2("timerCallback()...");
        // Update activity info
        loadCurrentActivityInfo();

        if (me.session_active == true) {
            me.split_counter -= 1;
            updateSplitSpeed();
            logSpeedAndHR();
            logFitContributorData();

            if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
                me.HR_Speed_Test_Vibe.tooSlowWarning();
            }

            // TODO: helper function for failed level. Don't repeat code!
            //       This implementation could be buggy in the first few seconds
            //       of a new lap if the speed has excessive noise. Maybe the criteria
            //       should be being below this speed for consecutive cycles?
            if (me.split_speed < (me.desired_speed - 4 * me.fail_speed_delta)) {
                // Automatically end activity and save.
                me.HR_Speed_Test_Vibe.levelFailed();
                me.HR_Speed_Test_Delegate.onFail();
            }

            if (me.split_counter < 0) {
                Logger.LOG2("LEVEL UP!");
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
        Logger.LOG2("updating split speed");
        me.split_distance += (me.current_speed * me.kph2mps); // Integrate split distance
        me.delta_t = (me.current_elapsed_time - me.last_elapsed_time) * me.s2hr; // in hours
        me.split_speed = (me.split_distance * me.m2km) / me.delta_t;

        Logger.LOG3(Lang.format("Cur   Speed: $1$", [me.current_speed.format("%.2f")]));
        Logger.LOG3(Lang.format("Split Speed: $1$", [me.split_speed.format("%.2f")]));
        Logger.LOG3(Lang.format("Integrated Split Distance: $1$", [me.split_distance]));
        Logger.LOG3(Lang.format("Current Split Speed:       $1$", [me.split_speed]));
    }

    function logSpeedAndHR() {
        me.HR_array.add(me.current_HR);
        me.speed_array.add(me.current_speed);
    }

    function logFitContributorData() {
        Logger.LOG3("logging fit contributor data...");
        var myFormat = "v_des = $1$, v_cur = $2$, v_split = $3$";
        var myParams = [me.desired_speed.format("%.2f"),
                        me.current_speed.format("%.2f"),
                        me.split_speed.format("%.2f")];
        var myString = Lang.format(myFormat, myParams);
        Logger.LOG3(myString);

        me.desiredSpeedField.setData(me.desired_speed);
        me.currentSpeedField.setData(me.current_speed);
        me.splitSpeedField.setData(me.split_speed);
    }

    function loadCurrentActivityInfo() {
        Logger.LOG2("loading current activity info...");

        me.current_activity_info = Toybox.Activity.getActivityInfo();
        if (me.current_activity_info == null) {
            Logger.LOG3("Current activity info is null...");
            me.current_speed = 0.0;
            me.current_elapsed_time = 0.0;
            me.current_HR = 0.0;
        } else {
            if (me.current_activity_info.currentSpeed != null) {
                // Convert from mps to kph.
                me.current_speed = me.current_activity_info.currentSpeed * me.mps2kph;
            } else {
                Logger.LOG3("current speed was null...");
            }

            if (me.current_activity_info.elapsedTime != null) {
                // Convert from milliseconds to seconds
                me.current_elapsed_time = me.current_activity_info.elapsedTime * me.ms2s;
            } else {
                Logger.LOG3("current elapsed time was null...");
            }

            if (me.current_activity_info.currentHeartRate != null) {
                me.current_HR = me.current_activity_info.currentHeartRate;
            } else {
                Logger.LOG3("current heart rate was null...");
            }
        }
        var myFormat = "Current Speed = $1$, Current Elapsed Time = $2$";
        var myParams = [me.current_speed.format("%.2f"), me.current_elapsed_time.format("%.3f")];
        var myString = Lang.format(myFormat, myParams);
        Logger.LOG3(myString);
    }

    function levelUp() {
        // Check if we failed to achieve minimum average split speed
        if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
            // Automatically end activity and save.
            me.HR_Speed_Test_Vibe.levelFailed();
            me.HR_Speed_Test_Delegate.onFail();
        } else {
            // Reset split counters and increment target speed
            me.split_counter = me.split_time;
            me.split_distance = 0.0;
            me.desired_speed += me.speed_increment;
            me.last_elapsed_time = me.current_elapsed_time;
            me.HR_Speed_Test_Vibe.levelUp();
        }
        // Add the lap at the end of the callback so that we do not
        // add an empty lap upon failure.
        me.session.addLap();
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
        Logger.LOG3("Loading new watch settings...");
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

    // This function does not need to do anything.
    // It is just provided as the callback for when new
    // GPS data comes in.
    function onPosition(info) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        Logger.LOG3("onStop()...");
        if (me.session != null) {
            if (me.session.isRecording() == true) {
                me.session.stop();
            }
            me.session.discard();
            me.session = null;
        }
    }

    function onSettingsChanged() {
        Logger.LOG3("onSettingsChanged()...");
        // Only allow updates when testing is not in progress.
        if (me.session_active == false) {
            updateFromProperties();
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        // TODO: Clean up and organize this function contents.
        Logger.LOG2("getInitialView()...");

        me.HR_Speed_Test_View = new HR_Speed_TestView();
        updateViewData();

        me.HR_Speed_Test_Delegate = new HR_Speed_TestDelegate(me.watchSettings);

        return [ me.HR_Speed_Test_View, me.HR_Speed_Test_Delegate ];
    }

}
