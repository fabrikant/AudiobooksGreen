import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemRemoveFromPlaylist extends CommandItemAbstract {
  function initialize(ownerItemWeak) {
    CommandItemAbstract.initialize(
      Rez.Strings.removeFromPlaylist,
      null,
      null,
      Rez.Drawables.removeBook,
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
      // Удаляем книгу из плейлиста
      // Также нужно удалить пункт меню
      BooksStore.removeFromPlaylist(bookId);
      if (ownerItem != null) {
        ownerItem.killYourself();
      }
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
