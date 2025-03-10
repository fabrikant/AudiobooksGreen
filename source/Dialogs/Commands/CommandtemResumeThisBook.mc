import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemResumeThisBook extends CommandtemAbstract {
  function initialize(ownerItemWeak) {
    CommandtemAbstract.initialize(
      Rez.Strings.resumePlayingThisBook,
      null,
      null,
      Rez.Drawables.resume,
      ownerItemWeak
    );
  }

  function command() {
    var bookId = null;
    var ownerItem = null;

    if (ownerItemWeak != null and ownerItemWeak.stillAlive()) {
      ownerItem = ownerItemWeak.get();
      bookId = ownerItem.getId();
    }

    if (bookId != null) {
      // Запуск книги с закладки
      // Предварительно нужно добавить книгу в плейлист
      BooksStore.addToPlaylist(bookId);
      Media.startPlayback([bookId, true]);
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
