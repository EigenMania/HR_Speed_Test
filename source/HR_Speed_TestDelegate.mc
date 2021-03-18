using Toybox.WatchUi;
using Toybox.System;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {
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
                me.session.start();
                me.session_active = true;
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