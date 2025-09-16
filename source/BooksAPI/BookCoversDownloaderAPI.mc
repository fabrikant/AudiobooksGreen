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
        logger.debug("Added book: " + keys[i] + " for downloading cover");
        bookKeys.add(keys[i]);
      }
    }
    keyIndex = 0;
    startLoadingCovers();
  }

  // **************************************************************************
  function startLoadingCovers() {
    if (keyIndex < bookKeys.size()) {
      var url = api_url + "/items/" + bookKeys[keyIndex] + "/cover";
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

      WebRequest.makeImageRequest(
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
      //Записываем данные обложки
      Application.Storage.setValue(
        booksStorage.getCoverKey(bookKeys[keyIndex]),
        data
      );
      logger.info(
        "The cover of the book: " +
          bookInfo[BooksStore.BOOK_TITLE] +
          " has been downloaded"
      );
    }
    // Запускаем загрузку следующего файла
    keyIndex += 1;
    startLoadingCovers();
  }
}
