using Toybox.WatchUi;
using Toybox.System;

class SettingsNumberPickerDelegate extends WatchUi.NumberPickerDelegate {
    var myValue;

    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        System.println(value);
        me.myValue = value;
    }
}

class HR_Speed_TestMenuDelegate extends WatchUi.MenuInputDelegate {
    var myPicker;
    var starting_speed_initial_picker_value = 8000; // 8 kph

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        var InitialSpeedNumberPickerDelegate = new SettingsNumberPickerDelegate();
        if (item == :item_1) { // Starting speed
            System.println("item 1");
            if (WatchUi has :NumberPicker) {
                me.myPicker = new WatchUi.NumberPicker(
                    WatchUi.NUMBER_PICKER_DISTANCE,
                    me.starting_speed_initial_picker_value
                );
                WatchUi.pushView(
                    me.myPicker,
                    InitialSpeedNumberPickerDelegate,
                    WatchUi.SLIDE_IMMEDIATE
                );
            }
        } else if (item == :item_2) {
            System.println("item 2");
        }
    }

}