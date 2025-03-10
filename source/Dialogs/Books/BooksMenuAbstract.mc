import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BooksMenuAbstract extends WatchUi.CustomMenu {
  var fonts = null;

  // **************************************************************************
  function initialize(titleString) {
    fonts = Style.getFonts();

    var itemHeight =
      2 * Graphics.getFontHeight(fonts[:font]) +
      Graphics.getFontDescent(fonts[:font]) +
      Graphics.getFontHeight(fonts[:fontAuthor]) +
      Graphics.getFontHeight(fonts[:fontExtra]);

    var colors = new AbooksColors();
    CustomMenu.initialize(itemHeight, colors.menuBackgroundColor, {
      :theme => Style.getMenuTheme(),
      :titleItemHeight => itemHeight / 2,
      :title => new CustomMenuTitle(titleString),
    });

    var booksStorage = new BooksStore();
    var books = booksStorage.booksOnDevice;
    var booksId = getBooksArray(books);

    if (booksId.size() > 0) {
      for (var i = 0; i < booksId.size(); i++) {
        var filesDescription = getFilesDescription(booksId[i], booksStorage);
        addItem(
          new BookItem(
            booksId[i],
            weak(),
            books[booksId[i]],
            filesDescription,
            fonts
          )
        );
      }
    } else {
      addItem(getEmptyItem());
    }
  }

  // **************************************************************************
  function getBooksArray() {}

  // **************************************************************************
  function getFilesDescription(bookId, booksStorage) {
    var bookInfo = booksStorage.booksOnDevice[bookId];
    var result = "";

    var prettyDuration = booksStorage.prettyDuration(
      bookInfo[booksStorage.DURATION]
    );
    result += prettyDuration;

    var percent = null;
    var bookmark = booksStorage.getBookmark(bookId);
    if (bookmark != null) {
      percent = ContentProcessor.calculateProcentOfProgress(
        bookId,
        bookmark[0],
        bookmark[1]
      );
    }
    if (percent != null and percent > 0) {
      result += "   " + percent + "%";
    }
    return result;
  }

  // **************************************************************************
  function getEmptyItem() {
    return new BookItem(
      :empty,
      weak(),
      {
        BooksStore.BOOK_TITLE => Application.loadResource(
          Rez.Strings.noContentsTitle
        ),
        BooksStore.BOOK_AUTHOR => Application.loadResource(
          Rez.Strings.noContentsAuthor
        ),
      },
      "",
      fonts
    );
  }

  // **************************************************************************
  function deleteItemById(itemId) {
    var itemIndex = findItemById(itemId);
    if (itemIndex >= 0) {
      deleteItem(itemIndex);
      // Если это был последний элемент
      // нарисуем пустышку
      if (getItem(0) == null) {
        addItem(getEmptyItem());
      }
      WatchUi.requestUpdate();
    }
  }
}
