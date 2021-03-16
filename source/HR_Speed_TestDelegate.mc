using Toybox.WatchUi;

class HR_Speed_TestDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new HR_Speed_TestMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}