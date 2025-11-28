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
  var filesList;

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
    self.filesList = [];
    BooksAPI.initialize();
  }

  // **************************************************************************
  // Проверяем. Возможно список файлов по данной книге уже загружен
  function fileListRecieved() {
    var result = false;
    var storeFileList = Application.Storage.getValue(bookId);
    if (storeFileList instanceof Lang.Array) {
      logger.debug(
        "The list of files by book: " + bookId + " has already been downloaded"
      );
      result = true;
    }
    return result;
  }

  // **************************************************************************
  // Сначала пробуем получить список файлов непосредственно
  function start() {

    logger.info(
      "Start getting the list of files of the book: " +
        bookInfo[BooksStore.BOOK_TITLE]
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
          "No content found to load: " +
            bookInfo[BooksStore.BOOK_TITLE] +
            " author: " +
            bookInfo[BooksStore.BOOK_AUTHOR] +
            ". The book skipped"
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
      logger.warning(
        "Failed to get file list from server. Starting to get via proxy"
      );

      startProxyRequest(0);
    }
  }

  // **************************************************************************
  // Запрашиваем порцию файлов черех прокси
  function startProxyRequest(skip) {
    var limit = 30;
    var url = getProxyUrl() + "/audiobookshelf/book";
    var callback = self.method(:onGetProxy);
    var headers = {
      "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
      "Authorization" => "Bearer " + token,
    };
    var params = {
      "server" => server_url,
      "book_id" => bookId,
      "skip" => skip,
      "limit" => limit,
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => { URL => url },
    };

    logger.debug(
      "Start receiving part of the files. skip=" + skip + ", limit=" + limit
    );
    WebRequest.makeWebRequest(url, params, options, callback);
  }

  // **************************************************************************
  // Получена порция файлов через прокси
  function onGetProxy(code, data, context) {
    if (code != 200) {
      onError(getErrorMessage(code, data, "Getting a list of files"));
      return;
    }

    logger.info(
      "The next batch of files has been received. skip=" +
        data["skip"] +
        ", limit=" +
        data["limit"] +
        ", total=" +
        data["total"]
    );

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
          "No content found to load: " +
            bookInfo[BooksStore.BOOK_TITLE] +
            " author: " +
            bookInfo[BooksStore.BOOK_AUTHOR] +
            ". The book skipped"
        );
        finalCallback.invoke(booksStorage, arrayBooksId, currenIndexBooks);
        return;
      }

      //Проверяем нужно ли запускать получение следующей порции данных
      var total_got = data["skip"] + data["limit"];
      if (data["total"] > total_got) {
        startProxyRequest(total_got);
      } else {
        // Полученs все файлы книги. Добавляем информацию в хранилище
        booksStorage.addFilesList(bookId, filesList);
        finalCallback.invoke(booksStorage, arrayBooksId, currenIndexBooks);
      }
    }
  }
}
