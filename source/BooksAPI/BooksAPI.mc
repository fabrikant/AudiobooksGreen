import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

enum {
  BOOKS_FOLDER = "folder",
  BOOKS_FOLDER_ID = "folder_id",
  BOOKS_FOLDER_NAME = "folder_name",

  // ключи по которым хранятся имя
  // пользователя и пароль
  LOGIN = "login",
  PASSWORD = "password",
  SERVER = "server",
  TOKEN = "token",
  LENGHT_COMPLICATIONS = "lenghtComplications",

  URL = "url",
  FILE_INDEX = "file_index",
}

// **************************************************************************
function getAuthorizationProprtiesError() {
  var result = null;
  var serverUrl = Application.Properties.getValue(SERVER);
  var serverCheckString = "https://";
  if (
    !serverUrl
      .substring(0, serverCheckString.length())
      .equals(serverCheckString)
  ) {
    logger.error(Application.loadResource(Rez.Strings.checkServerAdress));
    return Application.loadResource(Rez.Strings.checkServerAdress);
  }

  var login = Application.Properties.getValue(LOGIN);
  var password = Application.Properties.getValue(PASSWORD);
  var token = Application.Properties.getValue(TOKEN);
  if (token.equals("") and (login.equals("") or password.equals(""))) {
    logger.error(Application.loadResource(Rez.Strings.setLoginAndPassword));
    return Application.loadResource(Rez.Strings.setLoginAndPassword);
  }
  return result;
}

//*****************************************************************************
//Общий функционал
class BooksAPI {
  var server_url = null;
  var api_url = null;
  // const books_proxy_url = "https://fv.n-drive.cf";
  const books_proxy_url = "https://cdn.nextdriver.ru";

  function initialize() {
    server_url = Application.Properties.getValue(SERVER);
    api_url = server_url;
    var lastSymb = server_url.substring(
      server_url.length() - 1,
      server_url.length()
    );
    if (lastSymb.equals("/")) {
      api_url += "api";
      server_url = server_url.substring(0, server_url.length() - 1);
    } else {
      api_url += "/api";
    }
  }

  // **************************************************************************
  function arrayToStringArray(arr) {
    if (arr instanceof Lang.Array) {
      var result = [];
      for (var i = 0; i < arr.size(); i++) {
        result.add(arr[i].toString());
      }
      return result;
    } else {
      return arr;
    }
  }

  // **************************************************************************
  function arrayToNumberArray(arr) {
    if (arr instanceof Lang.Array) {
      var result = [];
      for (var i = 0; i < arr.size(); i++) {
        result.add(arr[i].toNumber());
      }
      return result;
    } else {
      return arr;
    }
  }

  // **************************************************************************
  // Обработка ошибок
  function onError(msgArray) {
    WatchUi.pushView(new InfoView(msgArray), null, WatchUi.SLIDE_IMMEDIATE);
  }

  // **************************************************************************
  function getErrorMessage(code, data, description) {
    var msg = ["Код: " + code];
    if (!description.equals("")) {
      msg.add(description);
    }
    if (code < 0) {
      msg.add(WebRequest.getErrorDescription(code));
    } else if (data instanceof Lang.Dictionary) {
      msg.add(data.toString());
    } else if (data instanceof Lang.String) {
      msg.add(data);
    }
    return msg;
  }

  
}
