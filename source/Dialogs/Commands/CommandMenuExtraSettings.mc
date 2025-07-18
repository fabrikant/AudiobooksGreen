import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandMenuExtraSettings extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.extraSettings,
      null,
      null,
      Rez.Drawables.settings,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuExtraSettings(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
