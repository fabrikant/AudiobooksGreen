import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BooksMenuDownloaded extends BooksMenuAbstract {
  // **************************************************************************
  function initialize() {
    BooksMenuAbstract.initialize(Rez.Strings.content);
  }

  // **************************************************************************
  function getBooksArray(books) {
    var result = [];
    var booksKeys = books.keys();
    for (var i = 0; i < booksKeys.size(); i++) {
      var bookId = booksKeys[i];
      var bookInfo = books[bookId];
      if (bookInfo[BooksStore.BOOK_DOWNLOADED]) {
        result.add(bookId);
      }
    }
    return result;
  }

  // **************************************************************************
  function getAvailableСommands(ownerItemWeak) {
    return [
      new CommandtemAddToPlayList(ownerItemWeak),
      new CommandtemResumeThisBook(ownerItemWeak),
      new CommandtemPlay(ownerItemWeak),
      new CommandtemShowFiles(ownerItemWeak),
      new CommandtemEditMetadata(ownerItemWeak),
    ];
  }
}
