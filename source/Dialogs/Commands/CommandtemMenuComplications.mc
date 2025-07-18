import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemMenuComplications extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.complications,
      null,
      null,
      Rez.Drawables.watch,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuComplications(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
