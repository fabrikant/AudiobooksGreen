import Toybox.Lang;
import Toybox.Communications;
import Toybox.Time;

class ProgressAPI extends BooksAPI {
  var finalCallback = null;
  var booksStorage = null;
  var bookKeys = null;
  var token = null;
  var serverBookmarks = null;

  //***************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.finalCallback = finalCallback;
    self.booksStorage = booksStorage;
    BooksAPI.initialize();
  }

  //***************************************************************************
  function start() {
    logger.info("Start synchronizing playback progress");
    bookKeys = booksStorage.booksOnDevice.keys();
    if (bookKeys.size() == 0) {
      logger.info(
        "No books on device. Skipping playback progress synchronization"
      );
      finalCallback.invoke(booksStorage);
      return;
    }
    
    var savedToken = JWTools.getToken();
    if (savedToken == null) {
      var authorisationProcessor = new BooksAuthorisationAPI(
        self.method(:onAuthorisation)
      );
      authorisationProcessor.start();
    } else {
      onAuthorisation(savedToken);
    }
  }

  //***************************************************************************
  function onAuthorisation(token) {
    if (token == null or token.equals("")) {
      var message =
        Application.loadResource(Rez.Strings.notSet) +
        " " +
        Application.loadResource(Rez.Strings.token);
      logger.error(message + ". Playback progress sync missed");
      finalCallback.invoke(booksStorage);
      return;
    }
    self.token = token;
    serverBookmarks = {};
    getBookProgressFromServer(0);
  }

  //***************************************************************************
  function getBookProgressFromServer(keyIndex) {
    if (keyIndex < bookKeys.size()) {
      var bookId = bookKeys[keyIndex];
      logger.info("Start playback progress query for the book: " + bookId);
      var url = api_url + "/me/progress/" + bookId;
      WebRequest.makeWebRequest(
        url,
        null,
        {
          method => Communications.HTTP_REQUEST_METHOD_GET,
          :headers => {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            "Authorization" => "Bearer " + token,
          },
          :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
          :context => keyIndex,
        },
        self.method(:onGetBookProgressFromServer)
      );
    } else {
      logger.info("Completed receiving playback progress from server");
      bookmarksProcessing();
    }
  }

  //***************************************************************************
  function onGetBookProgressFromServer(code, data, keyIndex) {
    var bookId = bookKeys[keyIndex];
    if (code == 200) {
      var currentProgress = data["currentTime"].toLong();
      var progressTime = data["lastUpdate"].toLong() / 1000;
      var serverBookmark = ContentProcessor.bookmarkFromAbsolutePosition(
        bookId,
        currentProgress,
        progressTime
      );

      if (serverBookmark instanceof Lang.Array) {
        logger.info(
          "Playback progress received for the book: " +
            bookId +
            " progress " +
            serverBookmark
        );
        serverBookmarks[bookId] = serverBookmark;
      }
    } else {
      logger.info("Unable to get progress for the book: " + bookId);
    }
    keyIndex += 1;
    getBookProgressFromServer(keyIndex);
  }

  //***************************************************************************
  function bookmarksProcessing() {
    // Работаем с закладками на устройстве и полученными с сервера
    // готовим данные для передачи на сервер

    var webBooksId = [];
    var bookmarksToUpload = [];
    var serverBookmarksKeys = serverBookmarks.keys();

    // Перебираем полученные с сервера закладки
    // определяем какие нужно записать на устройство
    // формируем первоначальный список закладок для
    // выгрузки на сервер
    for (var i = 0; i < serverBookmarksKeys.size(); i++) {
      var bookId = serverBookmarksKeys[i];
      var serverBookmark = serverBookmarks[bookId];
      webBooksId.add(bookId);

      var deviceBookmark = booksStorage.getBookmark(bookId);

      if (deviceBookmark == null) {
        // Записываем закладку на устройство
        booksStorage.saveBookmark(bookId, serverBookmark);
      } else {
        var momentDevice = new Time.Moment(deviceBookmark[2]);
        var momentServer = new Time.Moment(serverBookmark[2]);
        if (momentDevice.greaterThan(momentServer)) {
          //добавляем закладку к выгружаемым
          bookmarksToUpload.add(
            createBookmarkUploadItem(
              bookId,
              deviceBookmark[0],
              deviceBookmark[1]
            )
          );
          logger.debug(
            "Added playback progress for the book id: " +
              bookId +
              " for uploading to the server:" +
              deviceBookmark
          );
        } else if (momentServer.greaterThan(momentDevice)) {
          // Записываем закладку на устройство
          booksStorage.saveBookmark(bookId, serverBookmark);
        }
      }
    }

    // Перебираем все закладки на устройстве и если их нет в списке
    // webBooksId, будем отправлять на сервер
    for (var i = 0; i < bookKeys.size(); i++) {
      var bookId = bookKeys[i];
      if (webBooksId.indexOf(bookId) < 0) {
        var deviceBookmark = booksStorage.getBookmark(bookId);
        if (deviceBookmark != null) {
          bookmarksToUpload.add(
            createBookmarkUploadItem(
              bookId,
              deviceBookmark[0],
              deviceBookmark[1]
            )
          );
          logger.debug(
            "Added playback progress for the book id: " +
              bookId +
              " for uploading to the server:" +
              deviceBookmark
          );
        }
      }
    }

    if (bookmarksToUpload.size() > 0) {
      sendBookmarks(bookmarksToUpload);
    } else {
      logger.info("No playback progress information to upload to server");
      finalCallback.invoke(booksStorage);
      return;
    }
  }

  //***************************************************************************
  function sendBookmarks(bookmarksToUpload) {
    logger.info("Start uploading playback progress by books to the server");
    var url = getProxyUrl() + "/audiobookshelf/set_progress";

    var data = {
      "server" => server_url,
      "token" => token,
      "items" => bookmarksToUpload,
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
    };
    WebRequest.makeWebRequest(
      url,
      data,
      options,
      self.method(:onSendBookmarks)
    );

    finalCallback.invoke(booksStorage);
    return;
  }

  // **************************************************************************
  function onSendBookmarks(code, data, context) {
    logger.debug(
      "Result of uploading playback progress. code: " + code + " data" + data
    );
  }

  // **************************************************************************
  function createBookmarkUploadItem(bookId, fileIndex, position) {
    var percent = ContentProcessor.calculateProcentOfProgress(
      bookId,
      fileIndex,
      position
    );

    var absolutePosition = ContentProcessor.absolutePositionFromBookmark(
      bookId,
      fileIndex,
      position
    );

    return {
      "libraryItemId" => bookId.toString(),
      "currentTime" => absolutePosition,
      "progress" => percent.toFloat() / 100,
    };
  }
}
