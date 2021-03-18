using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;

class SettingsNumberPickerDelegate extends WatchUi.NumberPickerDelegate {
    // Initialize value null so we ignore if it was never modified
    // by the user with the watch.
    var myValue = null;

    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        me.myValue = value;
        System.println(value);
        Application.getApp().loadNewWatchSettings();
    }
}

class HR_Speed_TestMenuDelegate extends WatchUi.MenuInputDelegate {
    private var myPicker;
    private var starting_speed_initial_picker_value = Application.getApp().getProperty("initialSpeedKph") * 1000;
    private var delta_speed_initial_picker_value = Application.getApp().getProperty("deltaSpeedKph") * 1000;
    var test = Application.getApp().getProperty("levelDurationS");
    //private var level_duration_initial_picker_value = new Time.Duration(Application.getApp().getProperty("levelDurationS"));
    private var level_duration_initial_picker_value = new Time.Duration(60);

    var watchSettings;

    function initialize(watchSettings) {
        System.println(test);
        me.watchSettings = watchSettings;
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :item_0) { // Starting speed
            System.println("item 0");
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
            System.println("item 1");
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
            System.println("item 2");
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