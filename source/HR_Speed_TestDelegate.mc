using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.FitContributor;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {
    // TODO: Move these to the main App file?
    var session;
    var session_active = false;

    var HR_Speed_Test_MenuDelegate;

    function initialize(watchSettings) {
        System.println("initialize() BehaviourDelegate...");
        me.HR_Speed_Test_MenuDelegate = new HR_Speed_TestMenuDelegate(watchSettings);
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        System.println("onSelect()...");

        if (Toybox has :ActivityRecording) {
            if ((me.session == null) || (me.session.isRecording() == false)) {
                me.session = ActivityRecording.createSession({
                     :name=>"HR_Speed_Test",
                     :sport=>ActivityRecording.SPORT_RUNNING,
                     :subSport=>ActivityRecording.SUB_SPORT_GENERIC
                });

                // TODO: Don't hard-code crap.
                Application.getApp().desiredSpeedField = me.session.createField(
                    "desired_speed",
                    0,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                Application.getApp().currentSpeedField = me.session.createField(
                    "current_speed",
                    1,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                Application.getApp().splitSpeedField = me.session.createField(
                    "split_speed",
                    2,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                me.session.start();
                me.session_active = true;

                // Restart timer when activity starts. This ensures that at least
                // one timer period (1s) has passed before the activity information
                // is queried for the first time, and all fields have been updated.
                Application.getApp().timer.stop();
                Application.getApp().timer.start(Application.getApp().timer_method, Application.getApp().timer_period_ms, Application.getApp().timer_do_repeat);
            }
        }
        return true;
    }

    function onFail() {
        var message = "Save Activity?";
        var dialog = new WatchUi.Confirmation(message);
        WatchUi.pushView(
            dialog,
            new MyConfirmationDelegate(),
            WatchUi.SLIDE_IMMEDIATE);

        // Immediately stop recording and end session.
        me.session.stop();
        me.session_active = false;

        /*
        var HR_vect = [];
        var V_vect = [];

        // TODO: Temporary see if local data logging works.
        var length = Application.getApp().speed_array.size();
        for (var i = 0;  i < length; i++) {
            var cur_speed = Application.getApp().speed_array[i];
            var cur_HR = Application.getApp().HR_array[i];
            if (cur_speed != null && cur_HR != null) {
                System.println(Lang.format("Speed (kph): $1$ -- HR: $2$", [cur_speed.format("%.2f"), cur_HR.format("%02d")]));
            }
        }
        */
    }

    function onMenu() {
        // Don't let the user access the menu while activity is in progress.
        if (me.session_active == false) {
            WatchUi.pushView(new Rez.Menus.MainMenu(), me.HR_Speed_Test_MenuDelegate, WatchUi.SLIDE_UP);
        }
    }

    // TODO: Catch app exit
    function onBack() {
        System.println("onBack()...");
    }

}