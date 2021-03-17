using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Activity;
using Toybox.Timer;
using Toybox.ActivityRecording;

class HR_Speed_TestView extends WatchUi.View {
    private var current_activity_info;

    private var split_time = 1 * 30;
    private var split_counter = split_time;
    
    private var start_speed = 8.0;
    private var speed_increment = 1.0;

    private var desired_speed = start_speed;
    private var current_speed = 0.0;

    private var split_speed = 0.0;
    private var n_split = 0;

    private var session;
    var session_active = false;

    function initialize() {
        System.println("initialize()...");
        me.current_activity_info = Toybox.Activity.getActivityInfo();
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        var myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 1000, true);
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("onShow()...");
    }

    function timerCallback() {
        // Update activity info
        loadNewActivityInfo();

        if (me.session_active == true) {
            me.split_counter -= 1;

            updateSplitSpeed();

            if (me.split_counter < 0) {
                levelUp();
            }
        }

        WatchUi.requestUpdate();		
    }

    function loadNewActivityInfo() {
        me.current_activity_info = Toybox.Activity.getActivityInfo();
        if (me.current_activity_info == null || me.current_activity_info.currentSpeed == null) {
            me.current_speed = 0.0;
        } else {
            me.current_speed = me.current_activity_info.currentSpeed * 3.6;
        }
    }

    function updateSplitSpeed() {
        if (me.n_split == 0) {
            me.split_speed = me.current_speed;
        } else {
            me.split_speed = (me.split_speed * me.n_split + me.current_speed) / (me.n_split + 1);
        }
        me.n_split += 1;
    }

    function levelUp() {
        // Reset split counters and increment target speed
        me.split_counter = me.split_time;
        me.n_split = 0;
        me.desired_speed += me.speed_increment;
    }

    // Convert a number in seconds to MM:SS format string.
    function secondsToTimeString(totalSeconds) {
        var minutes = (totalSeconds/60).toNumber();
        var seconds = (totalSeconds-60*minutes).toNumber();
        var timeString = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
        return timeString;
    }
    
    // Update the view
    function onUpdate(dc) {
        System.println("onUpdate...");

        var xc = dc.getWidth() / 2;
        var yc = dc.getHeight() / 2;
        var rc = dc.getWidth() / 2;

        // TODO: Load once upon initialization and store as members
        var fg_color = Application.getApp().getProperty("ForegroundColor");
        var bg_color = Application.getApp().getProperty("BackgroundColor");
        var low_color = Application.getApp().getProperty("BandLow");
        var med_color = Application.getApp().getProperty("BandMed");
        var high_color = Application.getApp().getProperty("BandHigh");

        me.current_speed = me.current_activity_info.currentSpeed * 3.6;

        // Update the view
        var curSpeedView = View.findDrawableById("CurSpeedLabel");
        curSpeedView.setColor(Application.getApp().getProperty("ForegroundColor"));
        curSpeedView.setText(me.current_speed.format("%.2f").toString());

        var desSpeedView = View.findDrawableById("DesSpeedLabel");
        desSpeedView.setColor(Application.getApp().getProperty("ForegroundColor"));
        desSpeedView.setText(me.desired_speed.format("%.2f").toString());

        var splitSpeedView = View.findDrawableById("SplitSpeedLabel");
        splitSpeedView.setColor(Application.getApp().getProperty("ForegroundColor"));
        splitSpeedView.setText(me.split_speed.format("%.2f").toString());

        var lapTimeView = View.findDrawableById("LapTimeLabel");
        lapTimeView.setColor(Application.getApp().getProperty("ForegroundColor"));
        lapTimeView.setText(secondsToTimeString(me.split_counter));

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // All dc drawing must be done after onUpdate, since it clears the screen.
        dc.setPenWidth(20);
        dc.setColor(low_color, bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 180, 90);
        dc.setColor(med_color, bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 90, 60);
        dc.setColor(high_color, bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 60, 0);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
