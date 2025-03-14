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
 
  // **************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.booksStorage = booksStorage;
    self.finalCallback = finalCallback;
    self.coverMaxSize = Style.coverSize();
    BooksAPI.initialize();
  }

  // **************************************************************************
  function start() {
    // Найдем удентификаторы книг у которых не скачана
    // обложка
    var keys = booksStorage.booksOnDevice.keys();
    bookKeys = [];
    for (var i = 0; i < keys.size(); i++) {
      var coverKey = booksStorage.getCoverKey(keys[i]);
      if (Application.Storage.getValue(coverKey) == null) {
        logger.debug("Добавлена книга: " + keys[i] + " для загрузки обложки");
        bookKeys.add(keys[i]);
      }
    }
    keyIndex = 0;
    startLoadingCovers();
  }

  // **************************************************************************
  function startLoadingCovers() {
    if (keyIndex < bookKeys.size()) {
      var url =
        api_url + "/items/" + bookKeys[keyIndex] + "/cover";
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
      logger.error("Не удалось загрузить обложку книги: " + bookInfo);
    }
    // Запускаем загрузку следующего файла
    keyIndex += 1;
    startLoadingCovers();
  }
}
