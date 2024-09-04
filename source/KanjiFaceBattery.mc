import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class KanjiFaceBattery extends WatchUi.Drawable {
    private var batteryLevel = -1;
    private var batteryBitmap as BitmapResource?;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);
        checkBatteryLevel();
    }

    function draw(dc as Dc) as Void {
        if (System.getClockTime().sec == 0) {
            checkBatteryLevel();
        }
        dc.drawBitmap(self.locX, self.locY, batteryBitmap);
    }

    // Check the battery level, and load a new bitmap if the level has changed
    function checkBatteryLevel() as Void {
        var stats = System.getSystemStats();
        var newBatteryLevel = stats.battery;

        if (newBatteryLevel == batteryLevel) {
            return;
        }

        batteryLevel = newBatteryLevel;

        var batteryRez = Rez.Drawables.Battery100;
        if (batteryLevel <= 20) {
            batteryRez = Rez.Drawables.Battery20;
        } else if (batteryLevel <= 40) {
            batteryRez = Rez.Drawables.Battery40;
        } else if (batteryLevel <= 60) {
            batteryRez = Rez.Drawables.Battery60;
        } else if (batteryLevel <= 80) {
            batteryRez = Rez.Drawables.Battery80;
        }
        batteryBitmap = WatchUi.loadResource(batteryRez) as BitmapResource;
    }
}
