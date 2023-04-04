using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;


var fontAntonio70 = null;
var fontAntonio30 = null;
var fontShare13 = null;

class wf01View extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        fontAntonio70 = WatchUi.loadResource(Rez.Fonts.fntAntonio70);
        fontAntonio30 = WatchUi.loadResource(Rez.Fonts.fntAntonio30);
        fontShare13 = WatchUi.loadResource(Rez.Fonts.fntShare13);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        setHeartrate();
        View.onUpdate(dc);

//        var clockTime = System.getClockTime();
//        dc.setColor(dc.COLOR_BLACK,dc.COLOR_BLACK);
//        dc.clear();
        setDateTime(dc);
        setCalendar(dc);
        // Get and show the current time
/*
        setBattery();
        setSteps();
*/
        // Call the parent onUpdate function to redraw the layout
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


    hidden function setClock(dc) {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        dc.setColor(dc.COLOR_RED,dc.COLOR_BLACK);
        dc.drawText(0, 30, fontAntonio70, timeString, dc.TEXT_JUSTIFY_RIGHT);

        //var view = View.findDrawableById("TimeLabel");
        //view.setText(timeString);
    }


    hidden function setDateTime(dc) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        var timeString = Lang.format(
//            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            "$1$:$2$",
            [
                today.hour,
                today.min.format("%02d")
            ]
        );
 
        var secondsString = Lang.format(
            "$1$",
            [
                today.sec.format("%02d")
            ]
        );

        //var timeLabel = View.findDrawableById("TimeLabel");
        //timeLabel.setText(timeString);
        dc.setColor(dc.COLOR_BLUE,dc.COLOR_BLACK);
        dc.drawText(dc.getWidth()-50, 20, fontAntonio70, timeString, dc.TEXT_JUSTIFY_RIGHT);
        dc.setColor(dc.COLOR_YELLOW,dc.COLOR_BLACK);
        dc.drawText(dc.getWidth()-45, 65, fontAntonio30, secondsString, dc.TEXT_JUSTIFY_LEFT);

/*
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
*/
    }

    hidden function setCalendar(dc) {
        var X1 = 35;
        var Y1 = dc.getHeight()/2;
        var stepX = (dc.getWidth() - X1*2)/7;
        var stepY = 14;

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

/* TEST
        var options = {
            :year   => 2022,
            :month  => 10,
            :day    => 12,
            :hour   => 1
        };
        today = Gregorian.utcInfo(Gregorian.moment(options), Time.FORMAT_SHORT);
*/


        var firstDayOfMonth = 1;
        var firstDayOfWeek = getFistDayOfWeek(today);

        var lastDay = getLastDay(today);
        var lastDayOfMonth = Gregorian.utcInfo(lastDay, Time.FORMAT_SHORT);



        dc.setColor(dc.COLOR_WHITE,dc.COLOR_BLACK);
        for(var i = 0; i < 38; i++) {
            var currentDay = i - firstDayOfWeek + 3;
            if(currentDay < 1) { continue; }
            if(currentDay > lastDayOfMonth.day) { break; }
            dc.drawText(X1 + stepX * (i % 7 + 1), Y1 + stepY * (i / 7), fontShare13, currentDay, dc.TEXT_JUSTIFY_RIGHT);
        }
        //dc.setColor(dc.COLOR_WHITE,dc.COLOR_BLACK);
        //dc.drawText(X1, Y1, fontAntonio15, todayDate, dc.TEXT_JUSTIFY_LEFT);
        //dc.drawText(X1+stepX, Y1, fontAntonio15, todayMonth, dc.TEXT_JUSTIFY_LEFT);
        //dc.drawText(X1+stepX*2, Y1, fontAntonio15, todayDOW, dc.TEXT_JUSTIFY_LEFT);
        //dc.drawText(X1+stepX*3, Y1, fontAntonio15, firstDayOfWeek, dc.TEXT_JUSTIFY_LEFT);

    }

    hidden function getFistDayOfWeek(today) {
        var options = {
            :year   => today.year,
            :month  => today.month,
            :day    => 1,
            :hour   => 1
        };
        var date1 = Gregorian.moment(options);
        var dateInfo = Gregorian.utcInfo(date1, Time.FORMAT_SHORT);
        return dateInfo.day_of_week;
    }

    hidden function getLastDay(today) {
        var options = {
            :year   => today.year,
            :month  => today.month,
            :day    => 1,
            :hour   => 1
        };
        var date1 = Gregorian.moment(options);
        var nextMonthDay = date1.add(Gregorian.duration({:days => 35}));
        var dateInfo = Gregorian.utcInfo(nextMonthDay, Time.FORMAT_SHORT);
        options = {
            :year   => dateInfo.year,
            :month  => dateInfo.month,
            :day    => 1,
            :hour   => 1
        };
        var nextMonthDate1 = Gregorian.moment(options);
        var lastDay = nextMonthDate1.subtract(Gregorian.duration({:days => 1}));
        return lastDay;
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
