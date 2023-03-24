using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;


class wf01View extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get and show the current time
        setDateTime();
        setBattery();
        setSteps();
        setHeartrate();

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }


    hidden function setClock() {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel");

        view.setText(timeString);
    }


    hidden function setDateTime() {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        var timeString = Lang.format(
//            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            "$1$:$2$:$3$",
            [
                today.hour,
                today.min.format("%02d"),
                today.sec.format("%02d")
            ]
        );
        var timeLabel = View.findDrawableById("TimeLabel");
        timeLabel.setText(timeString);

        var dateString = Lang.format(
            "$1$ $2$ $3$",
            [
                today.day,
                today.month,
                today.day_of_week
            ]
        );
        var dateLabel = View.findDrawableById("DateLabel");
        dateLabel.setText(dateString);
    }

    hidden function setBattery() {
        var battery = System.getSystemStats().battery;
        var batteryLabel = View.findDrawableById("BatteryLabel");
        batteryLabel.setText(battery.format("%d")+"%");
    }

    hidden function setSteps() {
        var stepCount = ActivityMonitor.getInfo().steps;
        var stepCountLabel = View.findDrawableById("StepCountLabel");
        stepCountLabel.setText(stepCount.toString());

        var stepGoalPercent = (stepCount.toFloat() / ActivityMonitor.getInfo().stepGoal.toFloat() * 100f);
        var stepGoalLabel = View.findDrawableById("StepGoalLabel");
        stepGoalLabel.setText(stepGoalPercent.format( "%d" ) + "%");
    }

    hidden function setHeartrate() {
        var heartRate = "";

        if(ActivityMonitor has :INVALID_HR_SAMPLE) {
            heartRate = retrieveHeartrateText();
        }
        else {
            heartRate = "--";
        }

        var heartrateLabel = View.findDrawableById("HeartrateLabel");
        heartrateLabel.setText(heartRate);
    }

    hidden function retrieveHeartrateText() {
        var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, false);
        var currentHeartrate = heartrateIterator.next().heartRate;

        if(currentHeartrate == ActivityMonitor.INVALID_HR_SAMPLE) {
            return "--";
        }

        return currentHeartrate.format("%d");
    }



}
