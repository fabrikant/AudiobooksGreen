import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
// Получение списка списков книг
// T.e. пользователь в личном кабинете может завести несколько
// списков с книгами. Здесь мы получаем перечень ээтих списков
class BooksFoldersAPI extends BooksAPI {
  var finalCallback = null;
  var path = "";

  function initialize(finalCallback) {
    self.finalCallback = finalCallback;
    path = "/foundation/api/users/me/folders";
  }

  function start() {
    var authentificator = new BooksAuthentificationAPI(
      self.method(:startGettingListofLists)
    );
    authentificator.start();
  }

  //Продолжаем после авторизации
  function startGettingListofLists() {
    var url = api_url + path;
    var sid = Application.Storage.getValue(SID);
    var context = { URL => url };
    var headers = commonHeaders(sid);
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };

    logger.debug("start: " + url);
    Communications.makeWebRequest(
      url,
      {},
      options,
      self.method(:onGettingFolders)
    );
  }

  function onGettingFolders(code, data, context) {
    if (code == 200) {
      logger.debug("Получен список папок");
      var folders = [];
      var content = data["payload"];
      if (content != null) {
        content = content["data"];
        if (content != null and content instanceof Toybox.Lang.Array) {
          for (var i = 0; i < content.size(); i++) {
            folders.add({
              BOOKS_FOLDER_ID => content[i]["folder_id"],
              BOOKS_FOLDER_NAME => content[i]["title"],
            });
          }
        }
      }
      finalCallback.invoke(folders);
    } else {
      var msg = data;
      if (data instanceof Lang.Dictionary) {
        if (data["error"] != null and data["error"]["title"] != null) {
          msg = data["error"]["title"];
        }
      }
      // Закрываем окно прогресса
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      // Закрываем список с выбором папки
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      // выводим ошибку
      onError(getErrorMessage(code, msg, ""));
    }
  }
}
