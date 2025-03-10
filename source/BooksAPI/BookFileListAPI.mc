import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

// Получение информации о книге
class BookFileListAPI extends BooksAPI {
  var booksStorage = null;
  var finalCallback = null;
  var arrayBooksId = null;
  var bookInfo = null;
  var currenIndexBooks = null;
  var sid = null;

  var bookId;

  // **************************************************************************
  function initialize(
    finalCallback,
    booksStorage,
    arrayBooksId,
    currenIndexBooks
  ) {
    self.booksStorage = booksStorage;
    self.finalCallback = finalCallback;
    self.arrayBooksId = arrayBooksId;
    self.bookId = arrayBooksId[currenIndexBooks];
    self.bookInfo = booksStorage.booksOnDevice[bookId];
    self.currenIndexBooks = currenIndexBooks;
  }

  // **************************************************************************
  // Сначала пробуем получить список файлов непосредственно
  // с сайта litres
  function start() {
    logger.info(
      "Начало получения списка файлов книги: " +
        bookInfo[BooksStore.BOOK_TITLE]
    );
    sid = Application.Storage.getValue(SID);
    var path = "/foundation/api/arts/" + bookId + "/files/grouped";
    var url = api_url + path;
    var context = { URL => url };

    logger.debug("start: " + url);
    Communications.makeWebRequest(
      url,
      {},
      createOptions(sid, context),
      self.method(:onGettingFirstTry)
    );
  }

  // **************************************************************************
  function onGettingFirstTry(code, data, context) {
    if (code == 200) {
      onGettingFilesList(code, data, context);
    } else {
      // Если возникла ошибка при запросе списка файлов
      // непосредственно с сайта litres, возможно список слишком
      // большой. Пробуем запросить через прокси. Там не будет
      // лишних данных
      var url = books_proxy_url + "/litres_mp3_list/" + bookId + "/" + sid;
      context[URL] = url;

      logger.debug("start: " + url);
      Communications.makeWebRequest(
        url,
        {},
        createOptions(sid, context),
        self.method(:onGettingFilesList)
      );
    }
  }

  // **************************************************************************
  function onGettingFilesList(code, data, context) {
    if (code != 200) {
      onError(getErrorMessage(code, data, "Получение списка файлов"));
      return;
    }

    logger.info("Получен список файлов");
    var filesList = [];
    var content = data["payload"];
    if (content != null) {
      content = content["data"];
      if (content != null and content instanceof Toybox.Lang.Array) {
        for (var i = 0; i < content.size(); i++) {
          var group = content[i];
          var pattern = "standard_quality_mp3";
          var fileTypeForCheck = group["file_type"].substring(
            0,
            pattern.length()
          );
          if (fileTypeForCheck.equals(pattern)) {
            var files = group["files"];
            for (var j = 0; j < files.size(); j++) {
              filesList.add({
                BooksStore.FILE_ID => files[j]["id"],
                BooksStore.FILE_NAME => files[j]["filename"],
                BooksStore.DURATION => files[j]["seconds"],
              });
            }
            break;
          }
        }
      }
    }

    if (filesList.size() == 0) {
      logger.warning(
        "Не найден контент для загрузки: " +
          bookInfo[BooksStore.BOOK_TITLE] +
          " автор: " +
          bookInfo[BooksStore.BOOK_AUTHOR] +
          " книга пропущена"
      );
      finalCallback.invoke(booksStorage, arrayBooksId, currenIndexBooks);
      return;
    }

    // Получен список файлов. Добавляем информацию о нем в хранилище
    booksStorage.addFilesList(bookId, filesList);
    finalCallback.invoke(booksStorage, arrayBooksId, currenIndexBooks);
  }

  // **************************************************************************
  function createOptions(sid, context) {
    return {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => commonHeaders(sid),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };
  }
}
