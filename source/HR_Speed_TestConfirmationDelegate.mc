using Toybox.WatchUi;
using Toybox.System;

class MyConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            Application.getApp().HR_Speed_Test_Delegate.session.save();
        } else {
            Application.getApp().HR_Speed_Test_Delegate.session.discard();
        }
        Application.getApp().HR_Speed_Test_Delegate.session = null;
    }
}
