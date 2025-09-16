import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemResumeCurrentBook extends CommandItemAbstract {
  
  function initialize() {
    CommandItemAbstract.initialize(
      Rez.Strings.resumePlayingCurrentBook,
      null,
      null,
      Rez.Drawables.resume,
      null
    );
  }

  function command() {
    // Запуск текущей книги.
    // Т.е. запуск воспроизведения без праметров
    Media.startPlayback(null);
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
