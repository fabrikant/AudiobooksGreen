import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Media;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.StringUtil;

module ContentProcessor {
  
  // **************************************************************************
  function bookmarkFromAbsolutePosition(
    bookId,
    progressInSeconds,
    progresUpdatedUnixTime
  ) {
    var result = null;
    var files = BooksStore.getFileList(bookId);
    if (files instanceof Lang.Array) {
      var remain = progressInSeconds;
      for (var i = 0; i < files.size(); i++) {
        var fileDuration = files[i][BooksStore.DURATION];
        if (remain < fileDuration) {
          var unixTime = Time.now().value();
          if (progresUpdatedUnixTime != null) {
            unixTime = progresUpdatedUnixTime;
          }
          result = [i, remain, unixTime];
          break;
        } else {
          remain -= fileDuration;
        }
      }
    }
    return result;
  }

  // **************************************************************************
  function absolutePositionFromBookmark(bookId, fileIndex, position) {
    var result = position;
    var files = BooksStore.getFileList(bookId);
    if (files instanceof Lang.Array and files.size() < fileIndex) {
      for (var i = 0; i < fileIndex; i++) {
        var fileDuration = files[i][BooksStore.DURATION];
        result += fileDuration;
      }
    }
    return result;
  }

  // **************************************************************************
  function calculateProcentOfProgress(bookId, fileIndex, position) {
    var files = BooksStore.getFileList(bookId);

    var percent = 0;
    var progress = 0;
    var duration = 0;

    for (var i = 0; i < files.size(); i++) {
      if (i < fileIndex) {
        progress += files[i][BooksStore.DURATION];
      } else if (i == fileIndex) {
        progress += position;
      }
      duration += files[i][BooksStore.DURATION];
    }

    if (progress > 0 and duration > 0) {
      percent = ((progress.toDouble() / duration) * 100).toNumber();
    }
    return percent;
  }

  // **************************************************************************
  // Начало установки метаданных из описания книги
  function setMetadataFromBookDescription(bookId) {
    var callback = new Lang.Method(
      ContentProcessor,
      :continueSetMetadataAfterConfirmation
    );
    var confirmationOptions = {
      :callback => callback,
      :context => bookId,
    };
    var message = Application.loadResource(
      Rez.Strings.editMetadataConfirmationMessage
    );
    var dialog = new WatchUi.Confirmation(message);
    WatchUi.pushView(
      dialog,
      new SimpleConfirmation(confirmationOptions),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  // **************************************************************************
  // Продолжение после подтвереждение установки
  // метаданных из описания книги
  function continueSetMetadataAfterConfirmation(bookId) {
    logger.debug("continueSetMetadataAfterConfirmation");
    var booksStorage = new BooksStore();
    var bookInfo = booksStorage.booksOnDevice[bookId];
    var files = Application.Storage.getValue(bookId);
    if (bookInfo == null or files == null or files.size() == 0) {
      return;
    }

    for (var i = 0; i < files.size(); i++) {
      var file = files[i];
      var filename = file[BooksStore.FILE_NAME];
      //Удаляем расширение из имени файла
      filename = filename.substring(0, filename.length() - 4);

      var contRef = new Media.ContentRef(
        file[BooksStore.FILE_CONTENT_ID],
        Media.CONTENT_TYPE_AUDIO
      );

      var mediaContent = Media.getCachedContentObj(contRef);
      var metadata = mediaContent.getMetadata();

      metadata.album = bookInfo[BooksStore.BOOK_TITLE];
      metadata.artist = bookInfo[BooksStore.BOOK_AUTHOR];
      metadata.title = filename;

      mediaContent.setMetadata(metadata);
    }
  }

  // **************************************************************************
  function removeAllBooks() {
    var booksStorage = new BooksStore();
    var keys = booksStorage.booksOnDevice.keys();
    for (var i = 0; i < keys.size(); i++) {
      booksStorage.removeBook(keys[i]);
    }
    logger.debug("Системный сброс медиаконетна");
    Media.resetContentCache();
  }

  // **************************************************************************
  // В зависимости от того, насколько давно
  // книга была поставлена на паузу, сдвигаем
  // позицию назад на разное время,
  // чтобы слушатель мог восстановить контекст
  function calculatePositionOffset(bookmarkUnixTime) {
    if (bookmarkUnixTime == null) {
      return 0;
    }

    var result = 0;

    var now = Time.now();
    var bookmark = new Time.Moment(bookmarkUnixTime);

    var seconds = now.subtract(bookmark).value();

    if (seconds < Gregorian.SECONDS_PER_MINUTE) {
      result = 0;
    } else if (seconds < 5 * Gregorian.SECONDS_PER_MINUTE) {
      result = 5;
    } else if (seconds < Gregorian.SECONDS_PER_HOUR) {
      result = 10;
    } else if (seconds < 6 * Gregorian.SECONDS_PER_HOUR) {
      result = 20;
    } else if (seconds < Gregorian.SECONDS_PER_DAY) {
      result = 30;
    } else {
      result = 60;
    }

    return result;
  }

  // **************************************************************************
  function translitText(text) {
    var array = text.toCharArray();
    var maxLenght = Application.Properties.getValue(LENGHT_COMPLICATIONS);

    var result = [];
    for (var i = 0; i < array.size(); i++) {
      var char = array[i];
      if (char == 'а') {
        result.add('a');
      } else if (char == 'А') {
        result.add('A');
      } else if (char == 'б') {
        result.add('b');
      } else if (char == 'Б') {
        result.add('B');
      } else if (char == 'в') {
        result.add('v');
      } else if (char == 'В') {
        result.add('V');
      } else if (char == 'г') {
        result.add('g');
      } else if (char == 'Г') {
        result.add('G');
      } else if (char == 'д') {
        result.add('d');
      } else if (char == 'Д') {
        result.add('D');
      } else if (char == 'е') {
        result.add('e');
      } else if (char == 'Е') {
        result.add('E');
      } else if (char == 'ё') {
        result.add('e');
      } else if (char == 'Ё') {
        result.add('E');
      } else if (char == 'ж') {
        result.add('g');
      } else if (char == 'Ж') {
        result.add('G');
      } else if (char == 'з') {
        result.add('z');
      } else if (char == 'З') {
        result.add('Z');
      } else if (char == 'и') {
        result.add('i');
      } else if (char == 'И') {
        result.add('I');
      } else if (char == 'й') {
        result.add('i');
      } else if (char == 'Й') {
        result.add('I');
      } else if (char == 'к') {
        result.add('k');
      } else if (char == 'К') {
        result.add('K');
      } else if (char == 'л') {
        result.add('l');
      } else if (char == 'Л') {
        result.add('L');
      } else if (char == 'м') {
        result.add('m');
      } else if (char == 'М') {
        result.add('M');
      } else if (char == 'н') {
        result.add('n');
      } else if (char == 'Н') {
        result.add('N');
      } else if (char == 'о') {
        result.add('o');
      } else if (char == 'О') {
        result.add('O');
      } else if (char == 'п') {
        result.add('p');
      } else if (char == 'П') {
        result.add('P');
      } else if (char == 'р') {
        result.add('r');
      } else if (char == 'Р') {
        result.add('R');
      } else if (char == 'с') {
        result.add('s');
      } else if (char == 'С') {
        result.add('S');
      } else if (char == 'т') {
        result.add('t');
      } else if (char == 'Т') {
        result.add('T');
      } else if (char == 'у') {
        result.add('u');
      } else if (char == 'У') {
        result.add('U');
      } else if (char == 'ф') {
        result.add('f');
      } else if (char == 'Ф') {
        result.add('F');
      } else if (char == 'х') {
        result.add('h');
      } else if (char == 'Х') {
        result.add('H');
      } else if (char == 'ц') {
        result.add('t');
        result.add('s');
      } else if (char == 'Ц') {
        result.add('T');
        result.add('s');
      } else if (char == 'ч') {
        result.add('c');
        result.add('h');
      } else if (char == 'Ч') {
        result.add('C');
        result.add('h');
      } else if (char == 'ш') {
        result.add('s');
        result.add('h');
      } else if (char == 'ш') {
        result.add('S');
        result.add('h');
      } else if (char == 'щ') {
        result.add('s');
        result.add('h');
      } else if (char == 'Щ') {
        result.add('S');
        result.add('h');
      } else if (char == 'ы') {
        result.add('y');
      } else if (char == 'Ы') {
        result.add('Y');
      } else if (char == 'э') {
        result.add('e');
      } else if (char == 'Э') {
        result.add('E');
      } else if (char == 'ю') {
        result.add('y');
        result.add('u');
      } else if (char == 'Ю') {
        result.add('Y');
        result.add('u');
      } else if (char == 'я') {
        result.add('y');
        result.add('a');
      } else if (char == 'я') {
        result.add('Y');
        result.add('a');
      } else if (char == 'ь' or char == 'Ь' or char == 'ъ' or char == 'Ъ') {
      } else {
        result.add(char);
      }
      if (maxLenght > 0 and result.size() >= maxLenght) {
        break;
      }
    }

    return StringUtil.charArrayToString(result);
  }
}
