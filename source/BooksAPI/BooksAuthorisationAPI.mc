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
    logger.debug("Start authorization");
    var token = Application.Properties.getValue(TOKEN);
    if (token.equals("")) {
      logger.debug("Token not set. Server authorization required.");
      var login = Application.Properties.getValue(LOGIN);
      var password = Application.Properties.getValue(PASSWORD);

      if (login.equals("")) {
        logger.error(Application.loadResource(Rez.Strings.setLogin));
        finalCallback.invoke(null);
        return;
      }
      if (password.equals("")) {
        logger.error(Application.loadResource(Rez.Strings.setPassword));
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
      logger.debug("No authorization required. A stored token was found.");
      finalCallback.invoke(token);
      return;
    }
  }

  function onNativeLogin(code, data, context) {
    if (code == 200) {
      var token = data["user"]["accessToken"];
      if (token == null or token.equals("")) {
        logger.info(
          "The response does not contain the accessToken key. Token will be used"
        );
        token = data["user"]["token"];
      }
      Application.Properties.setValue(TOKEN, token);
      finalCallback.invoke(token);
    } else if (code == -402) {
      logger.warning("Too big answer. Let's try to login via proxy");
      var url = getProxyUrl() + "/audiobookshelf/login";
      var callback = self.method(:onProxyLogin);
      var login = Application.Properties.getValue(LOGIN);
      var password = Application.Properties.getValue(PASSWORD);
      var params = {
        "server" => server_url,
        "login" => login,
        "password" => password,
      };

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
      logger.error(Application.loadResource(Rez.Strings.filedLogin));
      finalCallback.invoke(null);
    }
  }

  function onProxyLogin(code, data, context) {
    var token = null;
    if (code == 200) {
      if (data instanceof Lang.Dictionary) {
        token = data["accessToken"];
        if (token == null or token.equals("")) {
          logger.info(
            "The response does not contain the accessToken key. Token will be used"
          );
          token = data["token"];
        }
        Application.Properties.setValue(TOKEN, token);
      }
    } else {
      logger.error(Application.loadResource(Rez.Strings.filedLogin));
    }
    finalCallback.invoke(token);
  }
}
