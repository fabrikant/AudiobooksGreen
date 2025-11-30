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

  function start() {
    if (preferProxy()) {
      startProxyLogin();
    } else {
      startDirectlyLogin();
    }
  }

  function startDirectlyLogin() {
    logger.debug("Start directly authorization");
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
      var callback = self.method(:onDirectlyLogin);
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

  function startProxyLogin() {
    logger.debug("Start proxy authorization");
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
  }

  function onDirectlyLogin(code, data, context) {
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
      startProxyLogin();
    } else {
      logger.error(Application.loadResource(Rez.Strings.filedLogin));
      filedLoginMessage(code, data);
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
      finalCallback.invoke(token);
    } else {
      logger.error(Application.loadResource(Rez.Strings.filedLogin));
      filedLoginMessage(code, data);
    }
  }

  function filedLoginMessage(code, data) {
    var msg = [];
    if (code == 401) {
      msg.add(Application.loadResource(Rez.Strings.invalidLoginOrPassword));
    } else if (code < 0) {
      msg.add("code " + code);
      msg.add(WebRequest.getErrorDescription(code));
    } else {
      msg.add("code " + code);
      if (data != null and !data.equals("")) {
        msg.add(data.toString());
      } else {
        msg.add(Application.loadResource(Rez.Strings.filedLogin));
      }
    }

    WatchUi.switchToView(new InfoView(msg), null, WatchUi.SLIDE_IMMEDIATE);
  }
}
