import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemMenuComplications extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
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
