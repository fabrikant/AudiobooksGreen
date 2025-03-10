import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

module BookmarksGUI {
  function startSync() {
    // Показываем прогрессбар, чтобы пользователю было
    // не так скучно ждать авторизацию и получение папок
    WatchUi.pushView(
      new WatchUi.ProgressBar(
        Application.loadResource(Rez.Strings.progressMessageSyncBookmarks),
        null
      ),
      null,
      WatchUi.SLIDE_IMMEDIATE
    );

    var booksStorage = new BooksStore();
    var callback = new Lang.Method(BookmarksGUI, :onSync);
    var syncAgent = new BookmarksAPI(callback, booksStorage);
    syncAgent.start();
  }

  function onSync(booksStorage) {
    //Закрываем прогрессбар
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}

class BookmarksAPI extends BooksAPI {
  var finalCallback = null;
  var booksStorage = null;
  var sid = null;
  var keyIndex = null;
  var bookKeys = null;

  // **************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.finalCallback = finalCallback;
    self.booksStorage = booksStorage;
  }

  // **************************************************************************
  function start() {
    var authentificator = new BooksAuthentificationAPI(
      self.method(:onAutorisation)
    );
    authentificator.start();
  }

  // **************************************************************************
  function onAutorisation() {
    sid = Application.Storage.getValue(SID);
    bookKeys = booksStorage.booksOnDevice.keys();
    if (bookKeys.size() == 0) {
      logger.debug("Нет книг на устройстве. Пропуск синхронизации закладок");
      finalCallback.invoke(booksStorage);
      return;
    }

    var url = books_proxy_url + "/litres_get_bookmarks/";
    var context = { URL => url };
    var data = {
      "sid" => sid,
      "arts" => arrayToStringArray(bookKeys),
    };
    logger.debug("Запрос закладок: " + data);
    Communications.makeWebRequest(
      url,
      data,
      createOptions(sid, context),
      self.method(:onGettingBookmarks)
    );
  }

  // **************************************************************************
  //   {
  //   "success": true,
  //   "arts": [
  //     {
  //       "68859369": [
  //         "9",
  //         "65",
  //         1740412521
  //       ]
  //     },
  //     {
  //       "69465952": [
  //         "0",
  //         "120",
  //         1740470208
  //       ]
  //     }
  //   ]
  // }
  function onGettingBookmarks(code, data, context) {
    if (code == 200) {
      // Успешно пытаемся распарсить ответ
      if (data["success"] == null or data["success"] != true) {
        logger.error(
          "Ошбка при получении закладок: " +
            data["code"] +
            " " +
            data["message"]
        );
        finalCallback.invoke(booksStorage);
        return;
      }

      logger.debug("Получены закладки: " + data);

      var webBooksId = [];
      var bookmarksToUpload = [];

      // Перебираем полученные с сервера закладки
      // определяем какие нужно записать на устройство
      // формироуем первоначальный список закладок для
      // выгрузки на сервер
      for (var i = 0; i < data["arts"].size(); i++) {
        var bookmarkObj = data["arts"][i];

        var bookId = bookmarkObj.keys()[0];
        var serverBookmark = arrayToNumberArray(bookmarkObj[bookId]);
        bookId = bookId.toNumber();
        webBooksId.add(bookId);

        var deviceBookmark = booksStorage.getBookmark(bookId);

        if (deviceBookmark == null) {
          // Записываем закладку на устройство
          booksStorage.saveBookmark(bookId, serverBookmark);
        } else {
          //Нужно сравнить время. Кто позднее, тот актуальнее
          logger.debug(
            "Время закладок server: " +
              serverBookmark[2] +
              " device: " +
              deviceBookmark[2]
          );

          if (deviceBookmark[2] > serverBookmark[2]) {
            //добавляем закладку к выгружаемым

            bookmarksToUpload.add(
              createBookmarkUploadItem(
                bookId,
                deviceBookmark[0],
                deviceBookmark[1]
              )
            );
            logger.debug(
              "Закладка для отправки на сервер: " +
                bookId +
                " " +
                deviceBookmark
            );
          } else if (deviceBookmark[2] < serverBookmark[2]) {
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
              "Закладка для отправки на сервер: " +
                bookId +
                " " +
                deviceBookmark
            );
          }
        }
      }

      if (bookmarksToUpload.size() > 0) {
        sendBookmarks(bookmarksToUpload);
      } else {
        logger.debug("Нет закладок для выгрузки на сервер");
        finalCallback.invoke(booksStorage);
        return;
      }
    } else {
      logger.error("Код: " + code + " url: " + context[URL]);
      finalCallback.invoke(booksStorage);
      return;
    }
  }

  // **************************************************************************
  // Отправляем закладки на сервер
  // В принципе нам не нужен ответ. Успех или неуспех ничего не меняет
  // получаем ответ только для логов
  // {
  //   "sid": "string",
  //   "arts": [
  //     {
  //       "art": "string",
  //       "file": "string",
  //       "time_start": "string",
  //       "percent": "string"
  //     }
  //   ]
  // }
  function sendBookmarks(bookmarksToUpload) {
    var url = books_proxy_url + "/litres_set_bookmarks/";
    var context = { URL => url };
    var data = {
      "sid" => sid,
      "arts" => bookmarksToUpload,
    };
    Communications.makeWebRequest(
      url,
      data,
      createOptions(sid, context),
      self.method(:onSettingBookmark)
    );

    finalCallback.invoke(booksStorage);
    return;
  }

  // **************************************************************************
  function onSettingBookmark(code, data, context) {
    if (code == 200) {
      logger.debug("Результат " + context[URL] + " " + data);
    } else {
      logger.error("code: " + code + " url " + context[URL]);
    }
  }

  // **************************************************************************
  function createBookmarkUploadItem(bookId, fileIndex, position) {
    var percent = ContentProcessor.calculateProcentOfProgress(
      bookId,
      fileIndex,
      position
    );

    return {
      "art" => bookId.toString(),
      "file" => fileIndex.toString(),
      "time_start" => position.toString(),
      "percent" => percent.toString(),
    };
  }

  // **************************************************************************
  function createOptions(sid, context) {
    return {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      },
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };
  }

  // **************************************************************************
  // //Формат: 2025-02-18T13:11:27+03:00
  // function strToUnixTime(strDate) {
  //   if (
  //     strDate == null or
  //     (strDate instanceof Lang.String and strDate.equals(""))
  //   ) {
  //     return null;
  //   }

  //   var options = {
  //     :year => strDate.substring(0, 4).toNumber(),
  //     :month => strDate.substring(5, 7).toNumber(),
  //     :day => strDate.substring(8, 10).toNumber(),
  //     :hour => strDate.substring(11, 13).toNumber(),
  //     :minute => strDate.substring(14, 16).toNumber(),
  //     :second => strDate.substring(17, 19).toNumber(),
  //   };
  //   var moment = Gregorian.moment(options);
  //   var timeZoneStr = strDate.substring(19, null);
  //   if (timeZoneStr instanceof Lang.String and timeZoneStr.length() == 6) {
  //     var timeZoneSeconds =
  //       timeZoneStr.substring(0, 3).toNumber() * Gregorian.SECONDS_PER_HOUR +
  //       timeZoneStr.substring(4, null).toNumber() *
  //         Gregorian.SECONDS_PER_MINUTE;

  //     var duration = new Time.Duration(-timeZoneSeconds);
  //     moment = moment.add(duration);
  //   }
  //   logger.debug("Парсинг даты: " + strDate + " => " + moment.value());
  //   return moment.value();
  // }
}
