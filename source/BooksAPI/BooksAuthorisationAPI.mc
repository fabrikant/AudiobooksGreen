import Toybox.Communications;
import Toybox.Application;

class BooksAuthorisationAPI extends BooksAPI {
  var finalCallback = null;

  function initialize(callback) {
    if (callback == null) {
      finalCallback = self.method(:doNothing);
    } else {
      self.finalCallback = callback;
    }
    BooksAPI.initialize();
  }

  function doNothing(params) {}

  function start() {
    logger.debug("Начало авторизации");
    var token = Application.Properties.getValue(TOKEN);
    if (token.equals("")) {
      logger.debug("Токен не задан. Требуется авторизация на сервере");
      var login = Application.Properties.getValue(LOGIN);
      var password = Application.Properties.getValue(PASSWORD);

      if (login.equals("")) {
        logger.error("Не задано имя пользователя");
        finalCallback.invoke(null);
        return;
      }
      if (password.equals("")) {
        logger.error("Не задан пароль");
        finalCallback.invoke(null);
        return;
      }

      var url = server_url + "/login";
      var callback = self.method(:onNativeLogin);
      var params = { "username" => login, "password" => password };

      var headers = {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      };

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_POST,
        :headers => headers,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :context => { URL => url },
      };
      WebRequest.makeWebRequest(url, params, options, callback);
    } else {
      logger.debug("Пропущена авторизация. Сохраненный токен: " + token);
      finalCallback.invoke(token);
      return;
    }
  }

  function onNativeLogin(code, data, context) {
    if (code == 200) {
      var token = data["user"]["accessToken"];
      if (token == null or token.equals("")) {
        logger.debug("В ответе отсутствуе ключ accessToken. Получаем ключ token");
        token = data["user"]["token"];
      }
      Application.Properties.setValue(TOKEN, token);
      finalCallback.invoke(token);
    } else if (code < 0) {
      logger.error(
        "Код: " +
          code +
          " " +
          getErrorDescription(code) +
          " url: " +
          context[URL]
      );
      logger.debug(
        "Слишком большой ответ. Пробуем авторизоваться через прокси"
      );
      var url = books_proxy_url + "/audiobookshelf/login";
      var callback = self.method(:onProxyLogin);
      var login = Application.Properties.getValue(LOGIN);
      var password = Application.Properties.getValue(PASSWORD);
      var params = {
        "server" => server_url,
        "login" => login,
        "password" => password,
      };

      var headers = {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
      };

      var options = {
        :method => Communications.HTTP_REQUEST_METHOD_GET,
        :headers => headers,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :context => { URL => url },
      };
      WebRequest.makeWebRequest(url, params, options, callback);
    } else {
      logger.error("Код: " + code + " url: " + context[URL]);
      finalCallback.invoke(null);
    }
  }

  function onProxyLogin(code, data, context) {
    var token = null;
    if (code == 200) {
      if (data instanceof Lang.Dictionary) {
        token = data["accessToken"];
        if (token == null or token.equals("")) {
          logger.debug("В ответе отсутствуе ключ accessToken. Получаем ключ token");
          token = data["token"];
        }
        Application.Properties.setValue(TOKEN, token);
      }
    } else {
      logger.debug("Не удалось авторизавться на сервере");
    }
    finalCallback.invoke(token);
  }
}
