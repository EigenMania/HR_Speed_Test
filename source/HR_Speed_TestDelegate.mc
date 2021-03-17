using Toybox.WatchUi;
using Toybox.System;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {
    var HR_Speed_Test_View;
    var session;

    function initialize(HR_Speed_Test_View_) {
        System.println("initialize() BehaviourDelegate...");
        me.HR_Speed_Test_View = HR_Speed_Test_View_;
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        System.println("onSelect()...");

        if (Toybox has :ActivityRecording) {                          // check device for activity recording
            if ((me.session == null) || (me.session.isRecording() == false)) {
                me.session = ActivityRecording.createSession({          // set up recording session
                     :name=>"HR_Speed_Test",                              // set session name
                     :sport=>ActivityRecording.SPORT_RUNNING,       // set sport type
                     :subSport=>ActivityRecording.SUB_SPORT_STREET // set sub sport type
                });
                me.session.start();  // call start session
                me.HR_Speed_Test_View.session_active = true;
            }
            // TODO: Do not allow user to stop activity
            else if ((session != null) && me.session.isRecording()) {
                me.session.stop();                                      // stop the session
                me.session.save();                                      // save the session
                me.session = null;                                      // set session control variable to null
                me.HR_Speed_Test_View.session_active = false;
            }
        }
        return true;                                                 // return true for onSelect function
    }

    function onMenu() {
        //WatchUi.pushView(new Rez.Menus.MainMenu(), new HR_Speed_TestMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}