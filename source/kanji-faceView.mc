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

class kanji_faceView extends WatchUi.WatchFace {

    private var kanjiLoader as KanjiLoader;
    private var isSleeping as Boolean;
    private var userWakeTime as Number;
    private var userSleepTime as Number;
    private var lastKanjiDisplay as Time.Moment;

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
        var today = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var date = View.findDrawableById("DateLabel") as Text;
        var dateString = Lang.format("$1$ $2$", [today.day_of_week, today.day]); 
        date.setText(dateString);

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

        if (moveBar > 0) {
            moveLabel.setText(moveBar.toString());
        } else {
            moveLabel.setText("");
        }

        var seconds = clockTime.sec;
        var secondLabel = View.findDrawableById("SecondLabel") as Text;
        secondLabel.setText(seconds.format("%02d"));

        var statusLabel = View.findDrawableById("StatusLabel") as Text;
        var statusText = "";

        var settings = System.getDeviceSettings();
        if (settings.alarmCount > 0) {
            statusText += "A";
        }
        if (settings.phoneConnected) {
            statusText += "P";
        }
        if (isSleeping) {
            statusText += "S";
        }
        if (mySleepMode()) {
            statusText += "Z";
        }
        statusLabel.setText(statusText);

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
        dc.drawRoundedRectangle(66, 136, 76, 100, 6);
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

    // Based on
    // https://forums.garmin.com/developer/connect-iq/f/discussion/2416/do-not-disturb
    function mySleepMode()
    {
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

}
