using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;

class SettingsNumberPickerDelegate extends WatchUi.NumberPickerDelegate {
    // Initialize value null so we ignore if it was never modified
    // by the user with the watch.
    var myValue = null;

    function initialize() {
        //Application.getApp().cout("initialize() NumberPickerDelegate...");
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        if (value == null) {
            Application.getApp().cout("NULL VALUE!!!");
        } else {
            Application.getApp().cout("Picked a new value...");
        }
        me.myValue = value;
        Application.getApp().cout(Lang.format("New Setting Value = $1$", [value])); 
        Application.getApp().loadNewWatchSettings();
    }
}

class HR_Speed_TestMenuDelegate extends WatchUi.MenuInputDelegate {
    private var myPicker;
    private var starting_speed_initial_picker_value;
    private var delta_speed_initial_picker_value;
    private var level_duration_initial_picker_value;

    var watchSettings;

    function initialize(watchSettings) {
        //Application.getApp().cout("initialize() MenuInputDelegate...");
        MenuInputDelegate.initialize();

        me.starting_speed_initial_picker_value = Application.getApp().getProperty("initialSpeedKph") * 1000;
        me.delta_speed_initial_picker_value = Application.getApp().getProperty("deltaSpeedKph") * 1000;
        me.level_duration_initial_picker_value = new Time.Duration(Application.getApp().getProperty("levelDurationS"));
        me.watchSettings = watchSettings;
    }

    function onMenuItem(item) {
        //Application.getApp().cout("onMenuItem()...");
        if (item == :item_0) { // Starting speed
            //Application.getApp().cout("ITEM 0!");
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
            //Application.getApp().cout("ITEM 1!");
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
            //Application.getApp().cout("ITEM 2!");
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