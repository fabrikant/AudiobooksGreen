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
    var token = Application.Properties.getValue(TOKEN);
    if (token.equals("")) {
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

      logger.debug("url: " + url);
      logger.debug(params);
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
      finalCallback.invoke(token);
      return;
    }
  }

  function onNativeLogin(code, data, context) {
    if (code == 200) {
      var token = data["user"]["token"];
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
    } else {
      logger.error("Код: " + code + " url: " + context[URL]);
      finalCallback.invoke(null);
    }
  }
}
