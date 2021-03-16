using Toybox.Application;
using Toybox.WatchUi;

class HR_Speed_TestApp extends Application.AppBase {

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
        return [ new HR_Speed_TestView(), new HR_Speed_TestDelegate() ];
    }

}
