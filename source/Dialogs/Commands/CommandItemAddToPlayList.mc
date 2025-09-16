import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemAddToPlayList extends CommandItemAbstract {
  function initialize(ownerItemWeak) {
    CommandItemAbstract.initialize(
      Rez.Strings.addToPlaylist,
      null,
      null,
      Rez.Drawables.addBook,
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
      BooksStore.addToPlaylist(bookId);
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
