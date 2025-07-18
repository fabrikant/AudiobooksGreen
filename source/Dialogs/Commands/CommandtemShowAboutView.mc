import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemShowAboutView extends CommandItemAbstract {
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.about,
      null,
      null,
      Rez.Drawables.logoAbout,
      null
    );
  }

  function command() {
    WatchUi.pushView(
      new AboutView(),
      new AboutViewDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
