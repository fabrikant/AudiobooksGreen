import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BooksMenuAll extends BooksMenuAbstract {
  // **************************************************************************
  function initialize() {
    BooksMenuAbstract.initialize(Rez.Strings.allBooks);
  }

  // **************************************************************************
  function getFilesDescription(bookId, booksStorage) {
    var files = booksStorage.getFileList(bookId);
    var result = "--/--";
    if (files != null and files instanceof Lang.Array and files.size() > 0) {
      var downloaded = 0;
      for (var i = 0; i < files.size(); i++) {
        if (files[i][booksStorage.FILE_CONTENT_ID] != null) {
          downloaded += 1;
        }
      }
      if (downloaded == null) {
        downloaded = "--";
      }
      return "" + downloaded + "/" + files.size();
    }
    return result;
  }

  // **************************************************************************
  function getBooksArray(books) {
    var result = [];
    var booksKeys = books.keys();
    for (var i = 0; i < booksKeys.size(); i++) {
      result.add(booksKeys[i]);
    }
    return result;
  }

  // **************************************************************************
  function getAvailableСommands(ownerItemWeak) {
    return [];
  }
}
