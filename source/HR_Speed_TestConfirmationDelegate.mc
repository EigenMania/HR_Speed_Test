using Toybox.WatchUi;
using Toybox.System;

class MyConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var app_base;

    function initialize() {
        app_base = Application.getApp();
        ConfirmationDelegate.initialize();
    }

    // TODO: Check if session is active / stopped before saving or discarding?
    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            me.app_base.session.save();
        } else {
            me.app_base.session.discard();
        }
        me.app_base.session = null;
    }
}
