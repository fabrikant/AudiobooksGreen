import Toybox.Communications;
import Toybox.Application;

class BooksPlaylistsAPI extends BooksAPI {
  var finalCallback = null;
  var token = null;

  //***************************************************************************
  function initialize(callback) {
    if (callback == null) {
      finalCallback = self.method(:doNothing);
    } else {
      self.finalCallback = callback;
    }
    BooksAPI.initialize();
  }

  //***************************************************************************
  function start() {
    logger.info("Start getting the list of playlists");

    var savedToken = JWTools.getToken();
    if (savedToken == null) {
      var authorisationProcessor = new BooksAuthorisationAPI(
        self.method(:onAuthorisation)
      );
      authorisationProcessor.start();
    } else {
      onAuthorisation(savedToken);
    }
  }

  //***************************************************************************
  function onAuthorisation(token) {
    self.token = token;
    if (token == null or token.equals("")) {
      logger.error(
        Application.loadResource(Rez.Strings.notSet) +
          " " +
          Application.loadResource(Rez.Strings.token) +
          " " +
          Application.loadResource(Rez.Strings.skipListPlaylists)
      );
      finalCallback.invoke([]);
      return;
    }

    if (preferProxy()) {
      startProxy();
    } else {
      startDirectly();
    }
  }

  //***************************************************************************
  function startDirectly() {
    // Пробуем получить список плейлистов без прокси
    logger.info("Start getting the list of playlists from the server");
    var url = api_url + "/playlists";
    var callback = self.method(:onDirectlyPlaylists);
    var headers = {
      "Authorization" => "Bearer " + token,
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => { URL => url },
    };
    WebRequest.makeWebRequest(url, null, options, callback);
  }

  //***************************************************************************
  function startProxy() {
    logger.info(
      "Start getting the list of playlists via proxy from the server"
    );
    var url = getProxyUrl() + "/audiobookshelf/playlists";
    var callback = self.method(:onProxyPlaylists);
    var params = { "server" => server_url };
    var headers = {
      "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
      "Authorization" => "Bearer " + token,
    };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => { URL => url },
    };
    WebRequest.makeWebRequest(url, params, options, callback);
  }

  //***************************************************************************
  function onDirectlyPlaylists(code, data, context) {
    if (code == 200) {
      var result = [];
      var playlists = data["playlists"];
      for (var i = 0; i < playlists.size(); i++) {
        result.add({
          BOOKS_FOLDER_ID => playlists[i]["id"],
          BOOKS_FOLDER_NAME => playlists[i]["name"],
        });
      }
      finalCallback.invoke(result);
      logger.info("The list of playlists was retrieved from the server.");
      return;
    } else if (code == -402) {
      //слишком большой ответ нужен запрос через прокси
      logger.warning(
        "Too big answer. Start getting the list of playlists via proxy"
      );
      startProxy();
      return;
    }
    logger.error("Failed to get the list of playlists from the server.");
    finalCallback.invoke([]);
  }

  //***************************************************************************
  function onProxyPlaylists(code, data, context) {
    var result = [];
    if (code == 200) {
      var playlists = data;
      for (var i = 0; i < playlists.size(); i++) {
        result.add({
          BOOKS_FOLDER_ID => playlists[i]["id"],
          BOOKS_FOLDER_NAME => playlists[i]["name"],
        });
      }
      logger.info("The list of playlists was retrieved via proxy.");
    } else {
      logger.error("Failed to get the list of playlists via proxy.");
    }

    logger.finalizeLogging();
    finalCallback.invoke(result);
  }
}
