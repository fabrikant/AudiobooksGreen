import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemResumeCurrentBook extends CommandtemAbstract {
  
  function initialize() {
    CommandtemAbstract.initialize(
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
