import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemMenuAuthorisation extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
      Rez.Strings.authorisation,
      null,
      null,
      Rez.Drawables.login,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new MenuAuthorization(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
