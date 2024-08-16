import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.StringUtil;

class kanji_faceView extends WatchUi.WatchFace {

    private var kanjiLoader as KanjiLoader;

    function initialize() {
        WatchFace.initialize();
        kanjiLoader = new KanjiLoader();
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
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
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
        var text1 = View.findDrawableById("TextLabel1") as Text;
        text1.setText(moveBar.toString());

        var kanjiText = View.findDrawableById("KanjiLabel") as Text;
        // release reference to previous font
        kanjiText.setFont(Graphics.FONT_SYSTEM_LARGE);

        var kanjiRef = kanjiLoader.loadNextKanji();
        var codepoint = kanjiRef[0];
        var char = codepoint.toChar().toString();
        kanjiText.setText(char);
        kanjiText.setFont(kanjiRef[1]);

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
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
