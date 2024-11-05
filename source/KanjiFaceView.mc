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
    private var extraKanjiElements as Boolean;
    private var firstUpdate as Boolean;

    // Store label references so we don't have to keep calling findDrawableById
    private var dateLabel as Text?;
    private var timeLabel as Text?;
    private var statusLabel as Text?;
    private var stepsLabel as Text?;
    private var heartRateLabel as Text?;
    private var kanjiLabel as Text?;

    function initialize() {
        WatchFace.initialize();
        kanjiLoader = new KanjiLoader();
        isSleeping = false;
        userWakeTime = 0;
        userSleepTime = 0;
        lastKanjiDisplay = new Time.Moment(0);
        extraKanjiElements = true;
        firstUpdate = true;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        statusFont = WatchUi.loadResource(Rez.Fonts.Status);

        setLayout(Rez.Layouts.WatchFace(dc));

        dateLabel = View.findDrawableById("DateLabel") as Text;
        timeLabel = View.findDrawableById("TimeLabel") as Text;
        statusLabel = View.findDrawableById("StatusLabel") as Text;
        stepsLabel = View.findDrawableById("StepsLabel") as Text;
        heartRateLabel = View.findDrawableById("HeartRateLabel") as Text;
        kanjiLabel = View.findDrawableById("KanjiLabel") as Text;
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
        var timeInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var fullUpdate = (timeInfo.sec == 0 || firstUpdate);
        firstUpdate = false;
        performUpdate(dc, now, timeInfo, fullUpdate);
    }

    private function performUpdate(dc as Dc, now as Time.Moment, timeInfo as Gregorian.Info, fullUpdate as Boolean) as Void {
        updateStatusLabel(timeInfo);
        updateStepsLabel();
        updateHeartRateLabel();

        if (fullUpdate) {
            updateTimeLabel(timeInfo);
            updateDateLabel(now);
        }

        // TODO: extract this to a real option
        var changeEveryMinute = false;

        if (changeEveryMinute) {
            if (fullUpdate) {
                changeKanji(now);
            }
        } else if (now.compare(lastKanjiDisplay) >= 30) {
            changeKanji(now);
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_BLACK);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(68, 136, 72, 100, 7);
    }

    // Change the displayed kanji/kana
    private function changeKanji(now as Time.Moment) as Void {
        // Release reference to previous font
        kanjiLabel.setFont(Graphics.FONT_SYSTEM_LARGE);

        var kanjiRef = kanjiLoader.loadNextKanji();
        var codepoint = kanjiRef[0];
        var char = codepoint.toChar().toString();
        kanjiLabel.setText(char);
        kanjiLabel.setFont(kanjiRef[1]);
        lastKanjiDisplay = now;
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

    private function updateTimeLabel(timeInfo as Gregorian.Info) as Void {
        // Get the current time and format it correctly
        var hours = timeInfo.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var mins = timeInfo.min.format("%02d");
        var timeString = Lang.format("$1$:$2$", [hours, mins]);
        timeLabel.setText(timeString);
    }

    private function updateDateLabel(now as Time.Moment) as Void {
        if (extraKanjiElements) {
            dateLabel.setFont(statusFont);
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
            dateLabel.setText(dateString);
        } else {
            var today = Gregorian.info(now, Time.FORMAT_MEDIUM);
            var dateString = Lang.format("$1$ $2$", [today.day_of_week, today.day]);
            dateLabel.setText(dateString);
        }
    }

    private function updateStatusLabel(timeInfo as Gregorian.Info) as Void {
        var statusText = getStatusText(timeInfo);
        statusLabel.setText(statusText);
        if (extraKanjiElements) {
            statusLabel.setFont(statusFont);
        } else {
            statusLabel.setFont(Graphics.FONT_SYSTEM_LARGE);
        }
    }

    private function updateStepsLabel() as Void {
        var activityInfo = ActivityMonitor.getInfo();
        stepsLabel.setText(activityInfo.steps.toString());
        if (activityInfo.steps >= activityInfo.stepGoal) {
            stepsLabel.setColor(Graphics.COLOR_BLUE);
        } else {
            stepsLabel.setColor(Graphics.COLOR_YELLOW);
        }
    }

    private function updateHeartRateLabel() as Void {
        var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var hrSample = hrIterator.next();

        if (hrSample == null || hrSample.heartRate == ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRateLabel.setText("Ø");
        } else {
            heartRateLabel.setText(hrSample.heartRate.toString());
        }
    }

    // Get some status information in a condensed form
    function getStatusText(timeInfo as Gregorian.Info) as String {
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
        if (isSleepMode(timeInfo)) {
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
    function isSleepMode(timeInfo as Gregorian.Info) as Boolean {
        var sleepMode = false;
        if (userWakeTime == userSleepTime) {
            return sleepMode;
        }
        var now = timeInfo.hour*3600 + timeInfo.min*60 + timeInfo.sec;
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
