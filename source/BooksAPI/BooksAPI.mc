import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;

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
    server_url = sanitazeServerName(server_url);
    api_url = server_url + "/api";
  }

  // **************************************************************************
  function sanitazeServerName(name) {
    if (name == null or name.equals("")) {
      return "";
    }
    var lastSymb = name.substring(name.length() - 1, name.length());
    if (lastSymb.equals("/")) {
      return name.substring(0, name.length() - 1);
    }
    return name;
  }

  // **************************************************************************
  function chooseBestProxy(finalCallback) {
    var extraProxy = sanitazeServerName(Application.Properties.getValue(PROXY));
    if (!extraProxy.equals("")) {
      books_proxy_url = extraProxy;
      logger.info("The user's own proxy [" + extraProxy + "] is selected");
      finalCallback.invoke();
    } else {
      if (BUILT_IN_PROXYS.size() > 1) {
        // Если задано несколько прокси, нужно случайным образом перемешать массив
        // и выбрать первый попавшийся живой прокси.
        // Проверять скорость отклика до каждого смысла нет, так как
        // 1. Продолжительность проверки съедает все плюсы
        // 2. Точность замеров времени - 1 секунда

        logger.info("Getting started choosing the proxy server");

        var shuffledArray = [];
        for (var i = 0; i < BUILT_IN_PROXYS.size(); i++) {
          shuffledArray.add(sanitazeServerName(BUILT_IN_PROXYS[i]));
        }

        shuffledArray = shuffleArray(shuffledArray);
        startCheckProxy({
          :proxyNames => shuffledArray,
          :index => 0,
          :callback => finalCallback,
        });
      } else if (BUILT_IN_PROXYS.size() > 0) {
        books_proxy_url = sanitazeServerName(BUILT_IN_PROXYS[0]);
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
  function shuffleArray(arr) {
    var n = arr.size();
    Math.srand(System.getTimer());
    for (var i = n - 1; i > 0; i--) {
      // Выбираем случайный индекс от 0 до i включительно
      var j = Math.rand() % (i + 1);

      // Меняем местами arr[i] и arr[j]
      var temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
    logger.debug("shufled proxies: " + arr);
    return arr;
  }

  // **************************************************************************
  function startCheckProxy(context) {
    if (context[:index] <= context[:proxyNames].size()) {
      var url = context[:proxyNames][context[:index]] + "/";
      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :context => context,
      };

      WebRequest.makeWebRequest(url, {}, options, self.method(:onCheckProxy));
    } else {
      //Серверы кончились, нчего не выбрали. Это ошибка
      var msg = "No working proxies found";
      logger.error(msg);
      logger.finalizeLogging();
      WatchUi.pushView(new InfoView(msg), null, WatchUi.SLIDE_IMMEDIATE);
    }
  }

  // **************************************************************************
  function onCheckProxy(code, data, context) {
    if (code == 200) {
      // Cервер ответил. Берем его
      books_proxy_url = context[:proxyNames][context[:index]];
      logger.info("Proxy server [" + books_proxy_url + "] selected");
      context[:callback].invoke();
    } else {
      // Ошибка. Проверяем следующий сервер
      logger.error(
        "Proxy check failed [" + context[:proxyNames][context[:index]] + "]"
      );
      context[:index] += 1;
      startCheckProxy(context);
    }
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
        logger.finalizeLogging();
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
  function preferProxy() {
    return Application.Properties.getValue("preferProxyRequests");
  }

  //***************************************************************************
  function doNothing(params) {}

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
