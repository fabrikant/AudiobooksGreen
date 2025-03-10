import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class MenuItemDrawable extends WatchUi.Drawable {
  var bitmapRez = null;
  var bitmap = null;
  var y = null;
  var bitmapX = null;
  var bitmapY = null;

  function initialize(bitmapRez) {
    if (bitmapRez != null) {
      self.bitmapRez = bitmapRez;
    }
    Drawable.initialize({});
    setLocation(0, 0);
  }

  function drawBorder(dc) {
    var colors = new AbooksColors();
    dc.setColor(colors.highlightFillColor, colors.highlightFillColor);
    dc.drawRectangle(0, 0, dc.getWidth(), dc.getHeight());
  }

  function draw(dc) {
    if (bitmap == null) {
      bitmap = WatchUi.loadResource(bitmapRez);
    }
    if (bitmapX == null) {
      bitmapX = (dc.getWidth() - bitmap.getWidth()) / 2;
      bitmapY = (dc.getHeight() - bitmap.getHeight()) / 2;
    }
    dc.drawBitmap(bitmapX, bitmapY, bitmap);

    //drawBorder(dc);
  }
}
