import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemMenuColors extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
      Rez.Strings.style,
      null,
      null,
      Rez.Drawables.palette,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuStyle(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
