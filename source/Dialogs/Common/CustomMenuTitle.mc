import Toybox.WatchUi;
import Toybox.Graphics;

class CustomMenuTitle extends WatchUi.TextArea {
  function initialize(text) {
    var colors = new AbooksColors();
    TextArea.initialize({
      :text => text,
      :color => colors.textColor,
      :backgroundColor => colors.menuBackgroundColor,
      :font => Style.getFonts()[:font],
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
    });
  }

  function draw(dc) {
    var width = dc.getWidth() / 2;
    setLocation((dc.getWidth() - width) / 2, 0);
    setSize(width, dc.getHeight());
    TextArea.draw(dc);
  }
}
