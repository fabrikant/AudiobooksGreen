import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;
import Toybox.Media;

class AboutView extends WatchUi.View {
  var logoBitmap = null;
  var colors = null;

  function initialize() {
    View.initialize();
    colors = new AbooksColors();
    logoBitmap = Application.loadResource(Rez.Drawables.logoAboutBig);
  }

  function onUpdate(dc) {
    dc.setColor(colors.textColor, colors.backgroundColor);
    dc.setAntiAlias(true);
    dc.clear();
    var text = "";

    var fonts = Style.getFonts();
    var logoSize = logoBitmap.getWidth();
    var y = logoSize / 4;
    var xCenter = dc.getWidth() / 2;

    // логотип
    dc.drawBitmap((dc.getWidth() - logoSize) / 2, y, logoBitmap);
    y += logoSize;

    // название программы
    dc.setColor(colors.highlightFillColor, colors.backgroundColor);
    var font = fonts[:font];
    text = Application.loadResource(Rez.Strings.AppName);
    dc.drawText(xCenter, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    y += Graphics.getFontHeight(font);

    // Версия
    dc.setColor(colors.textColor, colors.backgroundColor);
    text = "vers. " + getApp().version;
    dc.drawText(xCenter, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    y += Graphics.getFontHeight(font);

    // заголовок кэша
    font = fonts[:fontExtra];
    text = Application.loadResource(Rez.Strings.cacheSize);
    dc.drawText(xCenter, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    y += Graphics.getFontHeight(font);

    // размер кэша
    var cache = Media.getCacheStatistics();
    text =
      "" +
      bytesToGbytes(cache.size) +
      "Gb / " +
      bytesToGbytes(cache.capacity) +
      "Gb";
    dc.drawText(xCenter, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
  }

  function bytesToGbytes(bytes) {
    // 1073741824 = 1024*1024*1024
    var result = (bytes.toDouble() / 1073741824).format("%.3f");
    return result;
  }
}

class AboutViewDelegate extends WatchUi.BehaviorDelegate {
  function onSelect() {
    var message = Application.loadResource(Rez.Strings.removeCacheQuestion);
    WatchUi.pushView(
      new WatchUi.Confirmation(message),
      new RemoveCacheConfirmation(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}

class RemoveCacheConfirmation extends WatchUi.ConfirmationDelegate {
  function onResponse(response) {
    if (response == WatchUi.CONFIRM_YES) {
      ContentProcessor.removeAllBooks();
    }
  }
}
