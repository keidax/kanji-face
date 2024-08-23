import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.UserProfile;

using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.StringUtil;

class KanjiFaceView extends WatchUi.WatchFace {

    private var kanjiLoader as KanjiLoader;
    private var isSleeping as Boolean;
    private var userWakeTime as Number;
    private var userSleepTime as Number;
    private var lastKanjiDisplay as Time.Moment;
    private var statusFont as FontResource?;

    function initialize() {
        WatchFace.initialize();
        kanjiLoader = new KanjiLoader();
        isSleeping = false;
        userWakeTime = 0;
        userSleepTime = 0;
        lastKanjiDisplay = new Time.Moment(0);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        statusFont = WatchUi.loadResource(Rez.Fonts.Status);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var userProfile = UserProfile.getProfile();
        userWakeTime = userProfile.wakeTime.value();
        userSleepTime = userProfile.sleepTime.value();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var now = Time.now();
        var date = View.findDrawableById("DateLabel") as Text;

        if (false) {
            var today = Gregorian.info(now, Time.FORMAT_MEDIUM);
            var dateString = Lang.format("$1$ $2$", [today.day_of_week, today.day]);
            date.setText(dateString);
        } else {
            date.setFont(statusFont);
            var today = Gregorian.info(now, Time.FORMAT_SHORT);
            var dateString = "";
            switch (today.day_of_week) {
                case 1:
                    dateString += "g ";
                    break;
                case 2:
                    dateString += "a ";
                    break;
                case 3:
                    dateString += "b ";
                    break;
                case 4:
                    dateString += "c ";
                    break;
                case 5:
                    dateString += "d ";
                    break;
                case 6:
                    dateString += "e ";
                    break;
                case 7:
                    dateString += "f ";
                    break;
            }
            dateString += japaneseNumerals(today.day);
            date.setText(dateString);
        }

        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // Update the view
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setColor(getApp().getProperty("ForegroundColor") as Number);
        view.setText(timeString);

        var activityInfo = ActivityMonitor.getInfo();
        var moveBar = activityInfo.moveBarLevel;
        var moveLabel = View.findDrawableById("MoveLabel") as Text;

        if (false) {
            moveLabel.setFont(Graphics.FONT_SYSTEM_LARGE);
        } else {
            moveLabel.setFont(statusFont);
        }

        if (moveBar > 0) {
            moveLabel.setText(moveBar.toString());
        } else {
            moveLabel.setText("");
        }

        var seconds = clockTime.sec;
        var batteryLabel = View.findDrawableById("BatteryLabel") as Text;
        var stats = System.getSystemStats();
        var batteryPercent = stats.battery.format("%2.0f");
        batteryLabel.setText(batteryPercent);

        var statusLabel = View.findDrawableById("StatusLabel") as Text;
        var statusText = getStatusText();
        statusLabel.setText(statusText);
        if (false) {
            statusLabel.setFont(Graphics.FONT_SYSTEM_LARGE);
        } else {
            statusLabel.setFont(statusFont);
        }

        var stepsLabel = View.findDrawableById("StepsLabel") as Text;
        stepsLabel.setText(activityInfo.steps.toString());

        if (seconds == 0 || now.compare(lastKanjiDisplay) > 15) {
            var kanjiText = View.findDrawableById("KanjiLabel") as Text;
            // release reference to previous font
            kanjiText.setFont(Graphics.FONT_SYSTEM_LARGE);

            var kanjiRef = kanjiLoader.loadNextKanji();
            var codepoint = kanjiRef[0];
            var char = codepoint.toChar().toString();
            kanjiText.setText(char);
            kanjiText.setFont(kanjiRef[1]);
            lastKanjiDisplay = now;
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(66, 136, 76, 100, 7);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isSleeping = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isSleeping = true;
    }

    // Get some status information in a condensed form
    function getStatusText() as String {
        var statusText = "";

        var settings = System.getDeviceSettings();
        if (settings.alarmCount > 0) {
            statusText += "A";
        }
        if (settings.phoneConnected) {
            statusText += "P";
        } else {
            statusText += "D";
        }
        if (isSleepMode()) {
            statusText += "Z";
        }
        if (isSleeping) {
            statusText += "S";
        }

        return statusText;
    }

    // Based on https://forums.garmin.com/developer/connect-iq/f/discussion/2416/do-not-disturb
    // We don't have access to the Do Not Disturb state, so we assume the user's configured
    // sleep/wake times are equivalent.
    function isSleepMode() {
        var sleepMode = false;
        if (userWakeTime == userSleepTime) {
            return sleepMode;
        }
        var nowT = System.getClockTime();
        var now = nowT.hour*3600 + nowT.min*60 + nowT.sec;
        if(userSleepTime > userWakeTime) {
            if(now >= userSleepTime || now <= userWakeTime) {
                sleepMode = true;
            }
        } else {
            if(now <= userWakeTime && now >= userSleepTime) {
                sleepMode = true;
            }
        }
        return sleepMode;
    }

    function japaneseNumerals(number as Number) as String {
        if (number <= 0) {
            return "0";
        }

        var string = "";

        if (number >= 20) {
            var tens = number / 10;
            string += tens.toString();
        }

        if (number >= 10) {
            string += "%";
        }

        var ones = number % 10;
        if (ones > 0) {
            string += ones.toString();
        }

        return string;
    }

}
