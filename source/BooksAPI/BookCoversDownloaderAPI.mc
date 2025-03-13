import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
// Получение информации о книге
// и загрузка файлов
class BookCoversDownloaderAPI extends BooksAPI {
  var coverMaxSize = null;
  var finalCallback = null;
  var booksStorage = null;
  var bookKeys = null;
  var keyIndex = null;
  var token = null;

  // **************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.booksStorage = booksStorage;
    self.finalCallback = finalCallback;
    self.coverMaxSize = Style.coverSize();
    self.token = Application.Properties.getValue(TOKEN);
    BooksAPI.initialize();
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
    keyIndex = 0;
    startLoadingCovers();
  }

  // **************************************************************************
  function startLoadingCovers() {
    if (keyIndex < bookKeys.size()) {
      var bookInfo = booksStorage.booksOnDevice[bookKeys[keyIndex]];
      var responseCallback = self.method(:onGettingImage);

      var url =
        api_url + "/items/" + bookKeys[keyIndex] + "/cover?token=" + token;
      var params = {
        "width" => coverMaxSize,
        "format" => "jpeg",
      };
      var options = {
        :maxWidth => coverMaxSize,
        :maxHeight => coverMaxSize,
        :dithering => Communications.IMAGE_DITHERING_FLOYD_STEINBERG,
        :packingFormat => Communications.PACKING_FORMAT_JPG,
      };
      Communications.makeImageRequest(
        url,
        params,
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
      logger.info("Загружена обложка: " + bookInfo[BooksStore.BOOK_TITLE]);
      //Записываем данные обложки
      Application.Storage.setValue(
        booksStorage.getCoverKey(bookKeys[keyIndex]),
        data
      );
    } else {
      logger.error("Код: " + code);
      logger.debug(bookInfo[BooksStore.BOOK_COVER_URL]);
    }
    // Запускаем загрузку следующего файла
    keyIndex += 1;
    startLoadingCovers();
  }
}
