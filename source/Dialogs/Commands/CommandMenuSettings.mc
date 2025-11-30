import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandMenuSettings extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.menuSettings,
      null,
      null,
      Rez.Drawables.settings,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuSettings(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
