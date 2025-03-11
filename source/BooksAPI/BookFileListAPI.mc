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

  var token;
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
    self.token = Application.Properties.getValue(TOKEN);
    BooksAPI.initialize();
  }

  // **************************************************************************
  // Сначала пробуем получить список файлов непосредственно
  function start() {
    logger.info(
      "Начало получения списка файлов книги: " + bookInfo[BooksStore.BOOK_TITLE]
    );

    var url = api_url + "/items/" + bookId;

    var callback = self.method(:onGetNative);
    var headers = {
      "Authorization" => "Bearer " + token,
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => { URL => url },
    };
    var params = { "expanded" => 0 };
    WebRequest.makeWebRequest(url, params, options, callback);
  }

  // **************************************************************************
  function onGetNative(code, data, context) {
    if (code == 200) {
      var files = data["media"]["audioFiles"];
      var filesList = [];
      for (var i = 0; i < files.size(); i++) {
        var fileObj = {
          BooksStore.FILE_ID => files[i]["ino"],
          BooksStore.FILE_NAME => files[i]["metadata"]["filename"],
          BooksStore.DURATION => files[i]["duration"].toNumber(),
        };
        logger.debug(fileObj);
        filesList.add(fileObj);
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
    } else {
      // Если возникла ошибка при запросе списка файлов
      // непосредственно с сайта, возможно список слишком
      // большой. Пробуем запросить через прокси. Там не будет
      // лишних данных

      var url = books_proxy_url + "/audiobookshelf/book";
      var callback = self.method(:onGetProxy);
      var headers = {
        "Authorization" => "Bearer " + token,
      };
      var params = {
        "server" => server_url,
        "book_id" => bookId,
        "token" => token,
      };

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => headers,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :context => { URL => url },
      };

      WebRequest.makeWebRequest(url, params, options, callback);
    }
  }

  // **************************************************************************
  function onGetProxy(code, data, context) {
    if (code != 200) {
      onError(getErrorMessage(code, data, "Получение списка файлов"));
      return;
    }

    logger.info("Получен список файлов");

    var filesList = [];

    var files = data["files"];
    if (files instanceof Lang.Array) {
      for (var i = 0; i < files.size(); i++) {
        var fileObj = {
          BooksStore.FILE_ID => files[i]["id"],
          BooksStore.FILE_NAME => files[i]["filename"],
          BooksStore.DURATION => files[i]["duration"].toNumber(),
        };
        logger.debug(fileObj);
        filesList.add(fileObj);
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
  }

}
