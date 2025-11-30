import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandMenuDebug extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.menuDebug,
      null,
      null,
      Rez.Drawables.bug,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuDebug(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
