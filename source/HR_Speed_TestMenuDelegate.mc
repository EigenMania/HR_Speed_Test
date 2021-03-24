using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;

using HR_Speed_Test_Logger as Logger;

class SettingsNumberPickerDelegate extends WatchUi.NumberPickerDelegate {
    // Initialize value null so we ignore if it was never modified
    // by the user with the watch.
    var myValue = null;

    private var app_base;

    function initialize() {
        me.app_base = Application.getApp();
        Logger.LOG2("initialize() NumberPickerDelegate...");
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        me.myValue = value;
        Logger.LOG2(Lang.format("New Setting Value = $1$", [value]));
        me.app_base.loadNewWatchSettings();
    }
}

class HR_Speed_TestMenuDelegate extends WatchUi.MenuInputDelegate {
    var watchSettings;

    private var myPicker;
    private var starting_speed_initial_picker_value;
    private var delta_speed_initial_picker_value;
    private var level_duration_initial_picker_value;

    private var app_base;

    function initialize(watchSettings) {
        Logger.LOG2("initialize() MenuInputDelegate...");
        MenuInputDelegate.initialize();

        me.app_base = Application.getApp();
        me.starting_speed_initial_picker_value = me.app_base.getProperty("initialSpeedKph") * 1000;
        me.delta_speed_initial_picker_value = me.app_base.getProperty("deltaSpeedKph") * 1000;
        me.level_duration_initial_picker_value = new Time.Duration(me.app_base.getProperty("levelDurationS"));
        me.watchSettings = watchSettings;
    }

    function onMenuItem(item) {
        Logger.LOG2("onMenuItem()...");
        if (item == :item_0) { // Starting speed
            Logger.LOG3("ITEM 0!");
            if (WatchUi has :NumberPicker) {
                me.myPicker = new WatchUi.NumberPicker(
                    WatchUi.NUMBER_PICKER_DISTANCE,
                    me.starting_speed_initial_picker_value);

                WatchUi.pushView(
                    me.myPicker,
                    me.watchSettings[0],
                    WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (item == :item_1) { // Speed increment
            Logger.LOG3("ITEM 1!");
            if (WatchUi has :NumberPicker) {
                me.myPicker = new WatchUi.NumberPicker(
                    WatchUi.NUMBER_PICKER_DISTANCE,
                    me.delta_speed_initial_picker_value);

                WatchUi.pushView(
                    me.myPicker,
                    me.watchSettings[1],
                    WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (item == :item_2) { // Level duration
            Logger.LOG3("ITEM 2!");
            if (WatchUi has :NumberPicker) {
                me.myPicker = new WatchUi.NumberPicker(
                    WatchUi.NUMBER_PICKER_TIME_MIN_SEC,
                    me.level_duration_initial_picker_value);

                WatchUi.pushView(
                    me.myPicker,
                    me.watchSettings[2],
                    WatchUi.SLIDE_IMMEDIATE);
            }
        }
    }
}
