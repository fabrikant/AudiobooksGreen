import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BooksMenuPlaylist extends BooksMenuAbstract {
  // **************************************************************************
  function initialize() {
    BooksMenuAbstract.initialize(Rez.Strings.playlist);
  }

  // **************************************************************************
  function getBooksArray(books) {
    var result = [];
    var booksKeys = Application.Storage.getValue(BooksStore.PLAYLIST);
    if (booksKeys instanceof Lang.Array) {
      result = booksKeys;
    }
    return result;
  }

  // **************************************************************************
  function getAvailableСommands(ownerItemWeak) {
    return [
      new CommandtemResumeThisBook(ownerItemWeak),
      new CommandtemShowFiles(ownerItemWeak),
      new CommandtemRemoveFromPlaylist(ownerItemWeak),
      new CommandtemPlay(ownerItemWeak),
      new CommandtemEditMetadata(ownerItemWeak),
    ];
  }
}
