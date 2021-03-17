using Toybox.WatchUi;
using Toybox.System;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {
    var session;
    var session_active;

    function initialize() {
        System.println("initialize() BehaviourDelegate...");
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
            // TODO: Do not allow user to stop activity
            else if ((me.session != null) && me.session.isRecording()) {
                me.session.stop();
                me.session.save();
                me.session = null;
                me.session_active = false;
            }
        }
        return true;
    }

    function onFail() {
        if ((me.session != null) && me.session.isRecording()) {
            me.session.stop();
            me.session.save();
            me.session = null;
            me.session_active = false;
        }
    }

    function onMenu() {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new HR_Speed_TestMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}