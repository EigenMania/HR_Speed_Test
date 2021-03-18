using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Math;

class HR_Speed_TestView extends WatchUi.View {
    // Public Members
    var current_speed = 0.0;
    var desired_speed = 0.0;
    var fail_speed_delta = 0.0;
    var split_speed = 0.0;
    var split_counter = 0.0;

    // Private Members
    private var fg_color = Application.getApp().getProperty("ForegroundColor");
    private var bg_color = Application.getApp().getProperty("BackgroundColor");
    private var low_color = Application.getApp().getProperty("BandLow");
    private var med_color = Application.getApp().getProperty("BandMed");
    private var high_color = Application.getApp().getProperty("BandHigh");

    private var curSpeedView = View.findDrawableById("CurSpeedLabel");
    private var desSpeedView = View.findDrawableById("DesSpeedLabel");
    private var splitSpeedView = View.findDrawableById("SplitSpeedLabel");
    private var lapTimeView = View.findDrawableById("LapTimeLabel");

    private var xc;
    private var yc;
    private var rc;

    function initialize() {
        System.println("initialize()...");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        // Must set layout before loading drawables.
        setLayout(Rez.Layouts.MainLayout(dc));

        // Some screen size parameters.
        me.xc = dc.getWidth() / 2;
        me.yc = dc.getHeight() / 2;
        me.rc = dc.getWidth() / 2;

        // Load drawables.
        me.curSpeedView = View.findDrawableById("CurSpeedLabel");
        me.desSpeedView = View.findDrawableById("DesSpeedLabel");
        me.splitSpeedView = View.findDrawableById("SplitSpeedLabel");
        me.lapTimeView = View.findDrawableById("LapTimeLabel");

        // Set drawable colors.
        me.curSpeedView.setColor(me.fg_color);
        me.desSpeedView.setColor(me.fg_color);
        me.splitSpeedView.setColor(me.fg_color);
        me.lapTimeView.setColor(me.fg_color);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("onShow()...");
    }

    // Convert a number in seconds to MM:SS format string.
    private function secondsToTimeString(totalSeconds) {
        var minutes = (totalSeconds / 60).toNumber();
        var seconds = (totalSeconds - 60*minutes).toNumber();
        var timeString = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
        return timeString;
    }

    // Obtain angle of band marker
    private function getArrowAngle(v_des, v_split_cur, v_fail_delta) {
        // v_low corresponds to 180°, v_high to 0°
        var v_low = v_des - 4 * v_fail_delta;
        var v_high = v_des + 2 * v_fail_delta;
        var v_delta = v_high - v_low;

        // Normalized speed, 0 corresponds to v_low, 1 to v_high
        var v_normalized = (v_split_cur - v_low) / v_delta;

        // Clip
        if (v_normalized < 0) {
            v_normalized = 0;
        } else if (v_normalized > 1) {
            v_normalized = 1;
        }

        // Map to angle and return
        return 180*(1 - v_normalized);
    }

    // Vector of (x,y) points to draw arrow on screen.
    private function getArrowPoints(xc, yc, r_tip, angle_deg) {
        var p = new [3];

        var angle_rad = Math.toRadians(angle_deg);
        var angle_offset = Math.toRadians(4.0);
        var r_tip_offset = 10.0;

        var p0 = new [2];
        p0[0] = r_tip * Math.cos(angle_rad) + xc;
        p0[1] = -r_tip * Math.sin(angle_rad) + yc;
        p[0] = p0;

        var p1 = new [2];
        p1[0] = (r_tip - r_tip_offset) * Math.cos(angle_rad - angle_offset) + xc;
        p1[1] = -(r_tip - r_tip_offset) * Math.sin(angle_rad - angle_offset) + yc;
        p[1] = p1;

        var p2 = new [2];
        p2[0] = (r_tip - r_tip_offset) * Math.cos(angle_rad + angle_offset) + xc;
        p2[1] = -(r_tip - r_tip_offset) * Math.sin(angle_rad + angle_offset) + yc;
        p[2] = p2;

        return p;
    }

    private function drawBandAndArrow(dc, xc, yc, rc) {
        dc.setPenWidth(30);
        dc.setColor(me.low_color, me.bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 180, 90);
        dc.setColor(me.med_color, me.bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 90, 60);
        dc.setColor(me.high_color, me.bg_color);
        dc.drawArc(xc, yc, rc, Graphics.ARC_CLOCKWISE, 60, 0);

        var arrow_angle = getArrowAngle(me.desired_speed, me.split_speed, me.fail_speed_delta);
        var r_tip = rc - 20;
        var arrow_points = getArrowPoints(xc, yc, r_tip, arrow_angle);

        dc.setColor(me.fg_color, me.bg_color);
        dc.fillPolygon(arrow_points);
    }

    // Update the view
    function onUpdate(dc) {
        System.println("onUpdate...");

        // Update the view
        me.curSpeedView.setText(me.current_speed.format("%.2f").toString());
        me.desSpeedView.setText(me.desired_speed.format("%.2f").toString());
        me.splitSpeedView.setText(me.split_speed.format("%.2f").toString());
        me.lapTimeView.setText(secondsToTimeString(me.split_counter));

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // All dc drawing must be done after onUpdate, since it clears the screen.
        drawBandAndArrow(dc, me.xc, me.yc, me.rc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
}
