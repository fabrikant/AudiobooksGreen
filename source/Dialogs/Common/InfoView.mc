import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;
import Toybox.Lang;

class InfoView extends WatchUi.View {
  var msgArray = null;
  hidden var myTextArea;
  var colors = null;

  function initialize(msgArray) {
    if (msgArray instanceof Lang.Array) {
      self.msgArray = msgArray;
    } else {
      self.msgArray = [msgArray];
    }

    colors = new AbooksColors();
    View.initialize();
    logger.finalizeLogging();
  }

  function onShow() {
    var text = "";
    var width = System.getDeviceSettings().screenWidth / Math.sqrt(2);
    for (var i = 0; i < msgArray.size(); i++) {
      text += "" + msgArray[i] + "\n";
    }
    myTextArea = new WatchUi.TextArea({
      :text => text,
      :color => colors.textColor,
      :font => [Graphics.FONT_SMALL, Graphics.FONT_SYSTEM_SMALL],
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :width => width,
      :height => width,
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
    });
  }

  function onUpdate(dc) {
    dc.setColor(colors.textColor, colors.backgroundColor);
    dc.clear();
    myTextArea.draw(dc);
  }
}
