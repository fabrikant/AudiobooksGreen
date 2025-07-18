import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemSetDefaultColors extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.resetColors,
      null,
      null,
      Rez.Drawables.resetColors,
      null
    );
  }

  function command() {
    AbooksColors.setDefaultColors();
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
