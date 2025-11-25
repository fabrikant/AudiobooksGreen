import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;

// **************************************************************************
class BookItem extends WatchUi.CustomMenuItem {
  var fonts = null;
  var bookInfo = null;
  var filesDescription = null;
  var ownerMenuWeak = null;
  var bitmap = null;
  var bitmapX = null;
  var bitmapY = null;
  var leftColumnWidth = null;
  var titleHeight = null;
  var colors = null;

  private var representOnServer = null;

  // **************************************************************************
  function initialize(id, ownerMenuWeak, bookInfo, filesDescription, fonts) {
    self.fonts = fonts;
    self.bookInfo = bookInfo;
    self.filesDescription = filesDescription;
    self.ownerMenuWeak = ownerMenuWeak;
    self.colors = new AbooksColors();

    // Создаем надпись с названием
    var bookTitle = new BookTitleDrawable(bookInfo, fonts[:font], colors);
    var screenWidth = System.getDeviceSettings().screenWidth;

    titleHeight =
      2 * Graphics.getFontHeight(fonts[:font]) +
      Graphics.getFontDescent(fonts[:font]);

    leftColumnWidth = Style.coverSize() + 2 * Style.coverOffset;
    bookTitle.setLocation(leftColumnWidth, 2);
    bookTitle.setSize(screenWidth - leftColumnWidth, titleHeight);

    //Получаем картинку
    bitmap = Application.Storage.getValue(BooksStore.getCoverKey(id));
    // Если нет обложки
    if (bitmap == null) {
      bitmap = Application.loadResource(Rez.Drawables.emptyBookMenu);
    }

    CustomMenuItem.initialize(id, { :drawable => bookTitle });
  }

  // **************************************************************************
  function setServerStatus(value) {
    var status = value == true ? "" : "НЕ";
    logger.debug(
      "Установлен статус [" +
        getId() +
        "] КНИГА " +
        status +
        " В СПИСКЕ на сервере"
    );
    self.representOnServer = value;
  }
  // **************************************************************************
  function draw(dc) {
    dc.setColor(colors.menuItemBackgroundColor, colors.menuItemBackgroundColor);
    dc.clear();

    // Отрисовка обложки
    if (bitmapX == null) {
      bitmapX = (leftColumnWidth - bitmap.getWidth()) / 2;
      bitmapY = (leftColumnWidth - bitmap.getHeight()) / 2;
      if (getId() == :empty) {
        bitmapY = (dc.getHeight() - bitmap.getHeight()) / 2;
      }
    }
    dc.drawBitmap(bitmapX, bitmapY, bitmap);

    // Вывод автора
    dc.setColor(colors.textColor, colors.menuItemBackgroundColor);

    var text = Graphics.fitTextToArea(
      bookInfo[BooksStore.BOOK_AUTHOR],
      fonts[:fontAuthor],
      dc.getWidth() - leftColumnWidth - 1,
      Graphics.getFontHeight(fonts[:fontAuthor]),
      true
    );

    dc.drawText(
      leftColumnWidth,
      titleHeight,
      fonts[:fontAuthor],
      text,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // Вывод информации о файлах
    dc.drawText(
      Style.coverOffset,
      leftColumnWidth,
      fonts[:fontExtra],
      filesDescription,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    //Информация о наличии на сервере
    if (representOnServer != null) {
      var rez =
        representOnServer == true
          ? Rez.Drawables.cloud_done
          : Rez.Drawables.cloud_off;
      var statusBitmap = WatchUi.loadResource(rez);
      dc.drawBitmap(
        dc.getWidth() - statusBitmap.getWidth() - statusBitmap.getWidth() / 2,
        dc.getHeight() - statusBitmap.getHeight(),
        statusBitmap
      );
    }

    // Рамка
    dc.setColor(colors.highlightFillColor, colors.highlightFillColor);
    dc.drawRectangle(0, 0, dc.getWidth(), dc.getHeight());

    CustomMenuItem.draw(dc);
  }

  // **************************************************************************
  function onSelectItem() {
    if (getId() == :empty) {
      return;
    }
    if (ownerMenuWeak.stillAlive()) {
      var menu = ownerMenuWeak.get();
      var availableСommands = menu.getAvailableСommands(weak());
      if (availableСommands == null or availableСommands.size() == 0) {
        WatchUi.pushView(
          new FilesMenu(weak()),
          new SimpleMenuDelegate(),
          WatchUi.SLIDE_IMMEDIATE
        );
      } else {
        WatchUi.pushView(
          new CommandMenu(
            Rez.Strings.menuCommandsTitle,
            weak(),
            availableСommands
          ),
          new SimpleMenuDelegate(),
          WatchUi.SLIDE_IMMEDIATE
        );
      }
    }
  }

  // **************************************************************************
  function killYourself() {
    if (ownerMenuWeak.stillAlive()) {
      var menu = ownerMenuWeak.get();
      menu.deleteItemById(getId());
    }
  }
}

// **************************************************************************
class BookTitleDrawable extends WatchUi.TextArea {
  var w = null;

  function initialize(bookInfo, font, colors) {
    var titleString = bookInfo[BooksStore.BOOK_TITLE];
    TextArea.initialize({
      :text => titleString,
      :color => colors.textColor,
      :backgroundColor => colors.menuItemBackgroundColor,
      :font => font,
      :justification => Graphics.TEXT_JUSTIFY_LEFT,
    });
  }

  function draw(dc) {
    if (w == null) {
      w = dc.getWidth() - locX;
      setSize(w, height);
    }
    TextArea.draw(dc);
  }
}
