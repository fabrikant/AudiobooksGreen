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
  PROXY = "proxy",
  TOKEN = "token",
  LENGHT_COMPLICATIONS = "lenghtComplications",

  URL = "url",
  FILE_INDEX = "file_index",
}

var books_proxy_url = null;

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
  function chooseBestProxy(finalCallback) {
    var extraProxy = Application.Properties.getValue(PROXY);
    if (!extraProxy.equals("")) {
      books_proxy_url = extraProxy;
      logger.info("The user's own proxy [" + extraProxy + "] is selected");
      finalCallback.invoke();
    } else {
      if (BUILT_IN_PROXYS.size() > 1) {
        logger.info("Getting started choosing the best proxy server");
        var context = {
          :callback => finalCallback,
          :ind => 0,
          :indexBest => 0,
          :durationBest => 9999999,
          :startTime => Time.now(),
        };
        startChooseProxy(context);
      } else if (BUILT_IN_PROXYS.size() > 0) {
        books_proxy_url = BUILT_IN_PROXYS[0];
        logger.info("Proxy server [" + books_proxy_url + "] selected");
        finalCallback.invoke();
      } else {
        // Неоткуда брать прокси. Это ошибка
        // отправляем её в runtime
        var msg = "Proxy url not specified. Unable to work.";
        logger.error(msg);
        WatchUi.pushView(new InfoView(msg), null, WatchUi.SLIDE_IMMEDIATE);
      }
    }
  }

  // **************************************************************************
  function startChooseProxy(context) {
    if (context[:ind] >= BUILT_IN_PROXYS.size()) {
      books_proxy_url = BUILT_IN_PROXYS[context[:indexBest]];
      logger.info("Proxy server [" + books_proxy_url + "] selected");
      context[:callback].invoke();
      return;
    }

    var url = BUILT_IN_PROXYS[context[:ind]] + "/";

    context[URL] = url;
    context[:startTime] = Time.now();
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };

    WebRequest.makeWebRequest(url, {}, options, self.method(:onGettingProxy));
  }

  // **************************************************************************
  function onGettingProxy(code, data, context) {
    if (code == 200) {
      var duration = Time.now()
        .subtract(context[:startTime])
        .value();
      logger.info("Current delay: " + duration);
      if (duration < context[:durationBest]) {
        context[:durationBest] = duration;
        context[:indexBest] = context[:ind];
      }
    }
    context[:ind] += 1;
    context[:startTime] = Time.now();
    startChooseProxy(context);
  }

  // **************************************************************************
  function getProxyUrl() {
    if (books_proxy_url == null) {
      var extraProxy = Application.Properties.getValue(PROXY);
      if (!extraProxy.equals("")) {
        books_proxy_url = extraProxy;
      } else if (BUILT_IN_PROXYS.size() > 0) {
        books_proxy_url = BUILT_IN_PROXYS[0];
      } else {
        // Неоткуда брать прокси. Это ошибка
        // отправляем её в runtime
        var msg = "Proxy url not specified. Unable to work.";
        logger.error(msg);
        WatchUi.pushView(new InfoView(msg), null, WatchUi.SLIDE_IMMEDIATE);
      }
    }
    return books_proxy_url;
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
    var msg = ["Code: " + code];
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
