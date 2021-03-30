using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.FitContributor;

using HR_Speed_Test_Logger as Logger;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {
    private var app_base;

    var HR_Speed_Test_MenuDelegate;

    function initialize(watchSettings) {
        me.app_base = Application.getApp();
        Logger.LOG2("initialize() BehaviourDelegate...");

        me.HR_Speed_Test_MenuDelegate = new HR_Speed_TestMenuDelegate(watchSettings);
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        Logger.LOG2("onSelect()...");

        if (Toybox has :ActivityRecording) {
            if ((me.app_base.session == null) || (me.app_base.session.isRecording() == false)) {
                me.app_base.session = ActivityRecording.createSession({
                     :name=>"HR_Speed_Test",
                     :sport=>ActivityRecording.SPORT_RUNNING,
                     :subSport=>ActivityRecording.SUB_SPORT_STREET
                });

                // TODO: Don't hard-code crap.
                me.app_base.desiredSpeedField = me.app_base.session.createField(
                    "desired_speed",
                    0,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                me.app_base.currentSpeedField = me.app_base.session.createField(
                    "current_speed",
                    1,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                me.app_base.splitSpeedField = me.app_base.session.createField(
                    "split_speed",
                    2,
                    FitContributor.DATA_TYPE_FLOAT,
                    {:mesgType=>FitContributor.MESG_TYPE_RECORD,:units=>"kph" });

                Logger.LOG1("Starting the activity!");
                me.app_base.session.start();
                me.app_base.session_active = true;
                me.app_base.split_counter--;
                me.app_base.updateViewData();
                WatchUi.requestUpdate();

                // Restart timer when activity starts. This ensures that at least
                // one timer period (1s) has passed before the activity information
                // is queried for the first time, and all fields have been updated.
                me.app_base.timer.stop();
                me.app_base.timer.start(Application.getApp().timer_method, Application.getApp().timer_period_ms, Application.getApp().timer_do_repeat);
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
        me.app_base.session.stop();
        me.app_base.session_active = false;

        /*
        var HR_vect = [];
        var V_vect = [];

        // TODO: Temporary see if local data logging works.
        var length = Application.getApp().speed_array.size();
        for (var i = 0;  i < length; i++) {
            var cur_speed = Application.getApp().speed_array[i];
            var cur_HR = Application.getApp().HR_array[i];
            if (cur_speed != null && cur_HR != null) {
                Application.getApp().cout(Lang.format("Speed (kph): $1$ -- HR: $2$", [cur_speed.format("%.2f"), cur_HR.format("%02d")]));
            }
        }
        */
    }

    function onMenu() {
        // Don't let the user access the menu while activity is in progress.
        if (me.app_base.session_active == false) {
            WatchUi.pushView(new Rez.Menus.MainMenu(), me.HR_Speed_Test_MenuDelegate, WatchUi.SLIDE_UP);
        }
    }

    // TODO: Catch app exit
    function onBack() {
        Logger.LOG2("onBack()...");
    }

}
