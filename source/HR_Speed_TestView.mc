using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Math;

class HR_Speed_TestView extends WatchUi.View {
    var current_speed = 0.0;
    var desired_speed = 0.0;
    var fail_speed_delta = 0.0;
    var split_speed = 0.0;
    var split_counter = 0.0;

    function initialize() {
        System.println("initialize()...");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("onShow()...");
    }

    // Convert a number in seconds to MM:SS format string.
    function secondsToTimeString(totalSeconds) {
        var minutes = (totalSeconds / 60).toNumber();
        var seconds = (totalSeconds - 60*minutes).toNumber();
        var timeString = Lang.format("$1$:$2$", [minutes.format("%02d"), seconds.format("%02d")]);
        return timeString;
    }

    // Obtain angle of band marker
    function getArrowAngle(v_des, v_split_cur, v_fail_delta) {
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

        // Map to angle
        var marker_angle = 180*(1 - v_normalized);

        if (marker_angle > 90) {
            //Vibe.tooSlowWarning();
        }

        return marker_angle;
    }

    function getArrowPoints(xc, yc, r_tip, angle_deg) {
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

        var arrow_angle = getArrowAngle(me.desired_speed, me.split_speed, me.fail_speed_delta);
        var r_tip = rc - 15;
        var arrow_points = getArrowPoints(xc, yc, r_tip, arrow_angle);

        dc.setColor(fg_color, bg_color);
        dc.fillPolygon(arrow_points);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
}
