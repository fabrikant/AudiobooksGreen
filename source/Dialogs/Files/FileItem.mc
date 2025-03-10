import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Media;

class FileItem extends WatchUi.CustomMenuItem {
  var bitmap = null;
  var fonts = null;
  var bookItemWeak = null;
  var fileInfo = null;
  var yText = null;
  var yBitmap = null;
  var textDuration = null;
  var colors = null;

  function initialize(bookItemWeak, fileInfo) {
    fonts = Style.getFonts();
    self.bookItemWeak = bookItemWeak;
    self.fileInfo = fileInfo;
    self.colors = new AbooksColors();

    var textArray = [fileInfo[BooksStore.FILE_NAME]];

    if (fileInfo[BooksStore.FILE_CONTENT_ID] == null) {
      bitmap = Application.loadResource(Rez.Drawables.not_loaded_file);
    } else {
      bitmap = Application.loadResource(Rez.Drawables.loaded_file);
      var contRef = new Media.ContentRef(
        fileInfo[BooksStore.FILE_CONTENT_ID],
        Media.CONTENT_TYPE_AUDIO
      );

      var mediaContent = Media.getCachedContentObj(contRef);
      var metadata = mediaContent.getMetadata();
      if (metadata.title.length() > 0) {
        textArray.add(metadata.artist);
      }
      if (metadata.album.length() > 0) {
        textArray.add(metadata.album);
      }
    }

    var x = bitmap.getWidth() + 2 * Style.coverOffset;

    var titleDrawable = new FileTitleDrawable(
      textArray,
      fonts[:fontExtra],
      colors
    );

    titleDrawable.setLocation(x, 0);
    // Размер поправим при отрисовке,
    // когда будут параметры dc
    titleDrawable.setSize(x, x);

    CustomMenuItem.initialize(fileInfo[BooksStore.FILE_ID], {
      :drawable => titleDrawable,
    });
  }

  // **************************************************************************
  function titleHeight() {
    return (
      2 * Graphics.getFontHeight(fonts[:font]) +
      Graphics.getFontDescent(fonts[:font])
    );
  }

  // **************************************************************************
  function draw(dc) {
    dc.setColor(colors.menuItemBackgroundColor, colors.menuItemBackgroundColor);
    dc.clear();

    if (yText == null) {
      yText = dc.getHeight() - Graphics.getFontHeight(fonts[:fontExtra]);
      yBitmap = (yText - bitmap.getHeight()) / 2;
    }

    // картинка
    dc.drawBitmap(Style.coverOffset, yBitmap, bitmap);
    dc.setColor(colors.textColor, colors.menuItemBackgroundColor);

    // текст
    if (textDuration == null) {
      textDuration = BooksStore.prettyDuration(fileInfo[BooksStore.DURATION]);

      if (fileInfo[BooksStore.FILE_CONTENT_ID] != null) {
        var contRef = new Media.ContentRef(
          fileInfo[BooksStore.FILE_CONTENT_ID],
          Media.CONTENT_TYPE_AUDIO
        );

        var mediaContent = Media.getCachedContentObj(contRef);
        if (mediaContent != null) {
          var metadata = mediaContent.getMetadata();
          textDuration += " " + metadata.title;
        }
      }

      textDuration = Graphics.fitTextToArea(
        textDuration,
        fonts[:fontExtra],
        dc.getWidth() - Style.coverOffset,
        Graphics.getFontHeight(fonts[:fontExtra]),
        true
      );
    }

    dc.drawText(
      Style.coverOffset,
      yText,
      fonts[:fontExtra],
      textDuration,
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // Рамка
    dc.setColor(colors.highlightFillColor, colors.highlightFillColor);
    dc.drawRectangle(0, 0, dc.getWidth(), dc.getHeight());

    CustomMenuItem.draw(dc);
  }

  // **************************************************************************
  function getBookItem() {
    if (!bookItemWeak.stillAlive()) {
      return null;
    }
    return bookItemWeak.get();
  }

  // **************************************************************************
  function onSelectItem() {
    logger.debug("onSelectItem file: " + getId());

    if (fileInfo[BooksStore.FILE_CONTENT_ID] == null) {
      return;
    }

    // Проверим, что книга полностью загружена
    var bookItem = getBookItem();
    var bookId = bookItem.getId();
    var booksStorage = new BooksStore();
    var bookInfo = booksStorage.booksOnDevice[bookId];
    if (
      bookInfo[BooksStore.BOOK_DOWNLOADED] == null or
      bookInfo[BooksStore.BOOK_DOWNLOADED] != true
    ) {
      return;
    }

    var callback = self.method(:playFileAfterConfirmation);
    var confirmationOptions = {
      :callback => callback,
      :context => null,
    };
    var message = Application.loadResource(Rez.Strings.playFileQuestion);
    var dialog = new WatchUi.Confirmation(message);
    WatchUi.pushView(
      dialog,
      new SimpleConfirmation(confirmationOptions),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  // **************************************************************************
  function playFileAfterConfirmation(context) {
    var bookItem = getBookItem();
    var bookId = bookItem.getId();
    var cont_id = BooksStore.FILE_CONTENT_ID;
    // Записываем закладку
    BooksStore.createPlayerBookmark(
      {
        BooksStore.BOOK_ID => bookId,
        cont_id => fileInfo[cont_id],
      },
      0
    );
    // Добавляем книгу в плейлист
    BooksStore.addToPlaylist(bookId);
    // Стартуем воспроизведение
    Media.startPlayback([bookId, true]);
    // Закрываем текущее меню
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}

// **************************************************************************
class FileTitleDrawable extends WatchUi.Drawable {
  var w = null;
  var font = null;
  var textArray = null;
  var isFirstShow = null;
  var fontH = null;
  var colors = null;

  function initialize(textArray, font, colors) {
    self.textArray = textArray;
    self.font = font;
    self.colors = colors;

    fontH = Graphics.getFontHeight(font);
    isFirstShow = true;
    Drawable.initialize({});
  }

  function draw(dc) {
    if (w == null) {
      w = dc.getWidth() - locX;
      setSize(w, height);
    }

    dc.setColor(colors.textColor, Graphics.COLOR_TRANSPARENT);

    var y = locY + 1;

    for (var i = 0; i < textArray.size(); i++) {
      if (isFirstShow) {
        textArray[i] = Graphics.fitTextToArea(
          textArray[i],
          font,
          width,
          fontH,
          true
        );
      }
      dc.drawText(locX, y, font, textArray[i], Graphics.TEXT_JUSTIFY_LEFT);
      y += fontH;
    }
    isFirstShow = false;
  }
}
