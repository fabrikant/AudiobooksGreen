import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemSetDefaultColors extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
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
