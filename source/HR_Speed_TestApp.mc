using Toybox.Application;
using Toybox.WatchUi;

class HR_Speed_TestApp extends Application.AppBase {
    var HR_Speed_Test_View;
    var HR_Speed_Test_Delegate;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        System.println("getInitialView()...");
        me.HR_Speed_Test_View = new HR_Speed_TestView();
        me.HR_Speed_Test_Delegate = new HR_Speed_TestDelegate(me.HR_Speed_Test_View);
        return [ me.HR_Speed_Test_View, me.HR_Speed_Test_Delegate ];
    }

}