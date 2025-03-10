import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
// Получение информации о книге
// и загрузка файлов
class BookCoversDownloaderAPI extends BooksAPI {
  var coveMaxSize = null;
  var finalCallback = null;
  var booksStorage = null;
  var bookKeys = null;
  var sid = null;
  var keyIndex = null;

  // **************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.booksStorage = booksStorage;
    self.finalCallback = finalCallback;
    self.coveMaxSize = Style.coverSize();
  }

  // **************************************************************************
  function start() {
    // Найдем удентификаторы книг у которых не скачана
    // обложка
    var keys = booksStorage.booksOnDevice.keys();
    bookKeys = [];
    for (var i = 0; i < keys.size(); i++) {
      var bookInfo = booksStorage.booksOnDevice[keys[i]];
      if (
        bookInfo[BooksStore.BOOK_COVER_URL] != null and
        !bookInfo[BooksStore.BOOK_COVER_URL].equals("")
      ) {
        if (
          Application.Storage.getValue(booksStorage.getCoverKey(keys[i])) ==
          null
        ) {
          logger.debug(
            "Добавлен идентификатор: " + keys[i] + " для загрузки обложки"
          );
          bookKeys.add(keys[i]);
        }
      }
    }
    sid = Application.Storage.getValue(SID);
    keyIndex = 0;
    startLoadingCovers();
  }

  // **************************************************************************
  function startLoadingCovers() {
    if (keyIndex < bookKeys.size()) {
      var bookInfo = booksStorage.booksOnDevice[bookKeys[keyIndex]];
      var url = bookInfo[BooksStore.BOOK_COVER_URL];

      logger.debug("start: " + url);
      var options = {
        :maxWidth => coveMaxSize,
        :maxHeight => coveMaxSize,
        :dithering => Communications.IMAGE_DITHERING_FLOYD_STEINBERG,
        :packingFormat => Communications.PACKING_FORMAT_JPG,
      };
      Communications.makeImageRequest(
        url,
        {},
        options,
        self.method(:onGettingImage)
      );
    } else {
      // Обработали все книги
      finalCallback.invoke(booksStorage);
    }
  }

  // **************************************************************************
  function onGettingImage(code, data) {
    var bookInfo = booksStorage.booksOnDevice[bookKeys[keyIndex]];

    if (code == 200) {
      logger.info(
        "Загружена обложка: " + bookInfo[BooksStore.BOOK_TITLE]
      );
      //Записываем данные обложки
      Application.Storage.setValue(
        booksStorage.getCoverKey(bookKeys[keyIndex]),
        data
      );
    } else {
      var url = bookInfo[BooksStore.BOOK_COVER_URL];
      logger.error("Код: " + code + " url: " + url);
    }

    // Запускаем загрузку следующего файла
    keyIndex += 1;
    startLoadingCovers();
  }
}
