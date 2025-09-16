import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemPlay extends CommandItemAbstract {
  function initialize(ownerItemWeak) {
    CommandItemAbstract.initialize(Rez.Strings.play, null, null,
                                   Rez.Drawables.play, ownerItemWeak);
  }

  function command() {
    var bookId = null;
    var ownerItem = null;

    if (ownerItemWeak != null and ownerItemWeak.stillAlive()) {
      ownerItem = ownerItemWeak.get();
      bookId = ownerItem.getId();
    }

    if (bookId != null) {
      // Запуск книги сначала
      // Предварительно нужно добавить книгу в плейлист
      BooksStore.addToPlaylist(bookId);
      Media.startPlayback([ bookId, false ]);
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
