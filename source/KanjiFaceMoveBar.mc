import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class KanjiFaceMoveBar extends WatchUi.Drawable {
    private var moveBarLevel = -1;
    private var moveBarBitmap as BitmapResource?;

    function initialize(params as Dictionary) {
        Drawable.initialize(params);
        checkMoveBarLevel();
    }

    function draw(dc as Dc) as Void {
        checkMoveBarLevel();

        if (moveBarLevel > 0) {
            dc.drawBitmap(self.locX, self.locY, moveBarBitmap);
        }
    }

    // Check the move bar level, and load a new bitmap if the level has changed
    function checkMoveBarLevel() as Void {
        var activityInfo = ActivityMonitor.getInfo();
        var newMoveBarLevel = activityInfo.moveBarLevel;

        if (newMoveBarLevel == moveBarLevel) {
            return;
        }

        moveBarLevel = newMoveBarLevel;

        if (moveBarLevel == 0) {
            moveBarBitmap = null;
            return;
        }

        var moveBarRez = null;
        switch (moveBarLevel) {
            case 1:
                moveBarRez = Rez.Drawables.Move1;
                break;
            case 2:
                moveBarRez = Rez.Drawables.Move2;
                break;
            case 3:
                moveBarRez = Rez.Drawables.Move3;
                break;
            case 4:
                moveBarRez = Rez.Drawables.Move4;
                break;
            case 5:
                moveBarRez = Rez.Drawables.Move5;
                break;
        }

        moveBarBitmap = WatchUi.loadResource(moveBarRez) as BitmapResource;
    }
}

