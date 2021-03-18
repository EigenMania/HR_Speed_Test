using Toybox.Application;
using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.WatchUi;

class HR_Speed_TestApp extends Application.AppBase {
    var HR_Speed_Test_View;
    var HR_Speed_Test_Delegate;

    var timer;

    var current_activity_info;

    var split_time = 1 * 10;
    var split_counter = split_time;

    var start_speed = 8.0;
    var speed_increment = 0.5;
    var fail_speed_delta = 0.25;

    var desired_speed = start_speed;
    var current_speed = 0.0;

    var split_speed = 0.0;
    var n_split = 0;

    var last_elapsed_distance = 0.0;
    var current_elapsed_distance = 0.0;

    var session;
    var session_active = false;
    var session_active_prev = false;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        // Set color properties
        HR_Speed_TestApp.setProperty("ForegroundColor", Graphics.COLOR_WHITE);
        HR_Speed_TestApp.setProperty("BackgroundColor", Graphics.COLOR_BLACK);
        HR_Speed_TestApp.setProperty("BandLow", Graphics.COLOR_RED);
        HR_Speed_TestApp.setProperty("BandMed", Graphics.COLOR_ORANGE);
        HR_Speed_TestApp.setProperty("BandHigh", Graphics.COLOR_GREEN);

        me.timer = new Timer.Timer();
        me.timer.start(method(:timerCallback), 1000, true);
    }

    function timerCallback() {
        // Update activity info
        loadCurrentActivityInfo();

        // Hack to restart timer the moment activity recording is started
        // to get non-zero elapsed distance for first iteration.
        if (me.session_active_prev == false && me.HR_Speed_Test_Delegate.session_active == true) {
            me.timer.stop();
            me.session_active_prev = true;
            me.timer.start(method(:timerCallback), 1000, true);
        }

        if (me.HR_Speed_Test_Delegate.session_active == true) {
            me.split_counter -= 1;
            updateSplitSpeed();

            if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
                Vibe.tooSlowWarning();
            }

            if (me.split_counter < 0) {
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
        me.n_split += 1;
        //System.println(me.current_elapsed_distance);
        //System.println(me.last_elapsed_distance);
        //System.println(me.n_split);
        me.split_speed = (me.current_elapsed_distance - me.last_elapsed_distance) / me.n_split;
        //System.println(me.split_speed);
    }

    function loadCurrentActivityInfo() {
        me.current_activity_info = Toybox.Activity.getActivityInfo();
        if (me.current_activity_info == null) {
            me.current_speed = 0.0;
            me.current_elapsed_distance = 0.0;
        } else {
            if (me.current_activity_info.currentSpeed != null) {
                me.current_speed = me.current_activity_info.currentSpeed;
            }
            if (me.current_activity_info.elapsedDistance != null) {
                me.current_elapsed_distance = me.current_activity_info.elapsedDistance;
            }
        }
    }

    function levelUp() {
        // Check if we failed to achieve minimum average split speed
        if (me.split_speed < (me.desired_speed - me.fail_speed_delta)) {
            // Automatically end activity and save.
            Vibe.levelFailed();
            me.HR_Speed_Test_Delegate.onFail();
        } else {
            // Reset split counters and increment target speed
            me.split_counter = me.split_time;
            me.n_split = 0;
            me.desired_speed += me.speed_increment;
            me.last_elapsed_distance = me.current_elapsed_distance;
            Vibe.levelUp();
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    function onSettingsChanged() {
        System.println("onSettingsChanged()...");
        // Only allow updates when testing is not in progress.
        if (me.HR_Speed_Test_Delegate.session_active == false) {
            me.start_speed = HR_Speed_TestApp.getProperty("initialSpeedKph");
            me.desired_speed = me.start_speed;
            me.speed_increment = HR_Speed_TestApp.getProperty("deltaSpeedKph");
            me.split_time = HR_Speed_TestApp.getProperty("levelDurationS");
            me.split_counter = me.split_time;
            System.println(me.start_speed);
            System.println(me.speed_increment);
            System.println(me.split_time);
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        System.println("getInitialView()...");

        me.HR_Speed_Test_View = new HR_Speed_TestView();
        updateViewData();

        me.HR_Speed_Test_Delegate = new HR_Speed_TestDelegate();

        return [ me.HR_Speed_Test_View, me.HR_Speed_Test_Delegate ];
    }

}