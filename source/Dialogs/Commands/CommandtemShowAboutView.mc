import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemShowAboutView extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
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
