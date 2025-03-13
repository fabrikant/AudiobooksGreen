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
  function doNothing(params) {}

  //***************************************************************************
  function start() {
    var authorisationProcessor = new BooksAuthorisationAPI(
      self.method(:onAuthorisation)
    );
    authorisationProcessor.start();
  }

  //***************************************************************************
  function onAuthorisation(token) {
    self.token = token;
    if (token == null) {
      finalCallback.invoke([]);
      return;
    }

    // Пробуем получить список плейлистов без прокси
    var url = api_url + "/playlists";
    var callback = self.method(:onNativePlaylists);
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
  function onNativePlaylists(code, data, context) {
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
      return;
    } else if (code == -402) {
      //слишком большой ответ нужен запрос через прокси

      var url = books_proxy_url+"/audiobookshelf/playlists";
      var callback = self.method(:onProxyPlaylists);
      var params = { "server" => server_url, "token" => token };
      logger.debug(params);
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
      return;
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
    }
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
    }
    finalCallback.invoke(result);
  }
}
