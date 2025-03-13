import Toybox.Lang;
import Toybox.Communications;

class ProgressAPI extends BooksAPI {
  var finalCallback = null;
  var booksStorage = null;
  var bookKeys = null;
  var token = null;
  var serverProgress = null;

  //***************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.finalCallback = finalCallback;
    self.booksStorage = booksStorage;
    BooksAPI.initialize();
  }

  //***************************************************************************
  function start() {
    bookKeys = booksStorage.booksOnDevice.keys();
    if (bookKeys.size() == 0) {
      logger.debug("Нет книг на устройстве. Пропуск синхронизации закладок");
      finalCallback.invoke(booksStorage);
      return;
    }

    var authorisationProcessor = new BooksAuthorisationAPI(
      self.method(:onAuthorisation)
    );
    authorisationProcessor.start();
  }

  function onAuthorisation(token) {
    self.token = token;
    serverProgress = [];
    getBookProgressFromServer(0);
  }

  function getBookProgressFromServer(keyIndex) {
    if (keyIndex < bookKeys.size()) {
      var bookId = bookKeys[keyIndex];
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
      logger.debug("Прогресс по всем книгам получен");
      finalCallback.invoke(booksStorage);
    }
  }

  function onGetBookProgressFromServer(code, data, keyIndex) {
    if (code == 200) {
      // logger.debug(data);
      var bookId = bookKeys[keyIndex];
      var currentProgress = data["currentTime"].toLong();
      var progressTime = data["lastUpdate"].toLong();
      var serverBookmark = ContentProcessor.createBookmarkArrayForBook(
        bookId,
        currentProgress,
        progressTime
      );
      
      logger.debug("bookId: " + bookId + " progress " + serverBookmark);
      if (serverBookmark instanceof Lang.Array){}
    }
    keyIndex += 1;
    getBookProgressFromServer(keyIndex);
  }
}

// // **************************************************************************
//   function start() {
//     if (License.isFullVersion()) {
//       var authentificator = new BooksAuthentificationAPI(
//         self.method(:onAutorisation)
//       );
//       authentificator.start();
//     } else {
//       logger.debug("Пропущена синхронизация закладок в бесплатной версии");
//       finalCallback.invoke(booksStorage);
//     }
//   }

//   // **************************************************************************
//   function onAutorisation() {
//     sid = Application.Storage.getValue(SID);
//     bookKeys = booksStorage.booksOnDevice.keys();
//     if (bookKeys.size() == 0) {
//       logger.debug("Нет книг на устройстве. Пропуск синхронизации закладок");
//       finalCallback.invoke(booksStorage);
//       return;
//     }

//     var url = books_proxy_url + "/litres_get_bookmarks/";
//     var context = { URL => url };
//     var data = {
//       "sid" => sid,
//       "arts" => arrayToStringArray(bookKeys),
//     };
//     logger.debug("Запрос закладок: " + data);
//     Communications.makeWebRequest(
//       url,
//       data,
//       createOptions(sid, context),
//       self.method(:onGettingBookmarks)
//     );
//   }

//   // **************************************************************************
//   //   {
//   //   "success": true,
//   //   "arts": [
//   //     {
//   //       "68859369": [
//   //         "9",
//   //         "65",
//   //         1740412521
//   //       ]
//   //     },
//   //     {
//   //       "69465952": [
//   //         "0",
//   //         "120",
//   //         1740470208
//   //       ]
//   //     }
//   //   ]
//   // }
//   function onGettingBookmarks(code, data, context) {
//     if (code == 200) {
//       // Успешно пытаемся распарсить ответ
//       if (data["success"] == null or data["success"] != true) {
//         logger.error(
//           "Ошбка при получении закладок: " +
//             data["code"] +
//             " " +
//             data["message"]
//         );
//         finalCallback.invoke(booksStorage);
//         return;
//       }

//       logger.debug("Получены закладки: " + data);

//       var webBooksId = [];
//       var bookmarksToUpload = [];

//       // Перебираем полученные с сервера закладки
//       // определяем какие нужно записать на устройство
//       // формироуем первоначальный список закладок для
//       // выгрузки на сервер
//       for (var i = 0; i < data["arts"].size(); i++) {
//         var bookmarkObj = data["arts"][i];

//         var bookId = bookmarkObj.keys()[0];
//         var serverBookmark = arrayToNumberArray(bookmarkObj[bookId]);
//         bookId = bookId.toNumber();
//         webBooksId.add(bookId);

//         var deviceBookmark = booksStorage.getBookmark(bookId);

//         if (deviceBookmark == null) {
//           // Записываем закладку на устройство
//           booksStorage.saveBookmark(bookId, serverBookmark);
//         } else {
//           //Нужно сравнить время. Кто позднее, тот актуальнее
//           logger.debug(
//             "Время закладок server: " +
//               serverBookmark[2] +
//               " device: " +
//               deviceBookmark[2]
//           );

//           if (deviceBookmark[2] > serverBookmark[2]) {
//             //добавляем закладку к выгружаемым

//             bookmarksToUpload.add(
//               createBookmarkUploadItem(
//                 bookId,
//                 deviceBookmark[0],
//                 deviceBookmark[1]
//               )
//             );
//             logger.debug(
//               "Закладка для отправки на сервер: " +
//                 bookId +
//                 " " +
//                 deviceBookmark
//             );
//           } else if (deviceBookmark[2] < serverBookmark[2]) {
//             // Записываем закладку на устройство
//             booksStorage.saveBookmark(bookId, serverBookmark);
//           }
//         }
//       }

//       // Перебираем все закладки на устройстве и если их нет в списке
//       // webBooksId, будем отправлять на сервер
//       for (var i = 0; i < bookKeys.size(); i++) {
//         var bookId = bookKeys[i];
//         if (webBooksId.indexOf(bookId) < 0) {
//           var deviceBookmark = booksStorage.getBookmark(bookId);
//           if (deviceBookmark != null) {
//             bookmarksToUpload.add(
//               createBookmarkUploadItem(
//                 bookId,
//                 deviceBookmark[0],
//                 deviceBookmark[1]
//               )
//             );
//             logger.debug(
//               "Закладка для отправки на сервер: " +
//                 bookId +
//                 " " +
//                 deviceBookmark
//             );
//           }
//         }
//       }

//       if (bookmarksToUpload.size() > 0) {
//         sendBookmarks(bookmarksToUpload);
//       } else {
//         logger.debug("Нет закладок для выгрузки на сервер");
//         finalCallback.invoke(booksStorage);
//         return;
//       }
//     } else {
//       logger.error("Код: " + code + " url: " + context[URL]);
//       finalCallback.invoke(booksStorage);
//       return;
//     }
//   }

//   // **************************************************************************
//   // Отправляем закладки на сервер
//   // В принципе нам не нужен ответ. Успех или неуспех ничего не меняет
//   // получаем ответ только для логов
//   // {
//   //   "sid": "string",
//   //   "arts": [
//   //     {
//   //       "art": "string",
//   //       "file": "string",
//   //       "time_start": "string",
//   //       "percent": "string"
//   //     }
//   //   ]
//   // }
//   function sendBookmarks(bookmarksToUpload) {
//     var url = books_proxy_url + "/litres_set_bookmarks/";
//     var context = { URL => url };
//     var data = {
//       "sid" => sid,
//       "arts" => bookmarksToUpload,
//     };
//     Communications.makeWebRequest(
//       url,
//       data,
//       createOptions(sid, context),
//       self.method(:onSettingBookmark)
//     );

//     finalCallback.invoke(booksStorage);
//     return;
//   }

//   // **************************************************************************
//   function onSettingBookmark(code, data, context) {
//     if (code == 200) {
//       logger.debug("Результат " + context[URL] + " " + data);
//     } else {
//       logger.error("code: " + code + " url " + context[URL]);
//     }
//   }

//   // **************************************************************************
//   function createBookmarkUploadItem(bookId, fileIndex, position) {
//     var percent = ContentProcessor.calculateProcentOfProgress(
//       bookId,
//       fileIndex,
//       position
//     );

//     return {
//       "art" => bookId.toString(),
//       "file" => fileIndex.toString(),
//       "time_start" => position.toString(),
//       "percent" => percent.toString(),
//     };
//   }

//   // **************************************************************************
//   function createOptions(sid, context) {
//     return {
//       :method => Communications.HTTP_REQUEST_METHOD_POST,
//       :headers => {
//         "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
//       },
//       :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
//       :context => context,
//     };
//   }
