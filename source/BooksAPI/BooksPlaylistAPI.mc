import Toybox.Communications;
import Toybox.Application;

class BooksPlaylistAPI extends BooksAPI {
  var finalCallback = null;
  var token = null;
  var playlistId = null;

  //***************************************************************************
  function initialize(callback, playlistId) {
    if (callback == null) {
      finalCallback = self.method(:doNothing);
    } else {
      self.finalCallback = callback;
    }
    self.playlistId = playlistId;
    BooksAPI.initialize();
  }

  //***************************************************************************
  function doNothing(params) {}

  //***************************************************************************
  function start() {
    logger.info(
      "Start getting a list of books from a playlist with ID: " + playlistId
    );

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
          "\n" +
          Application.loadResource(Rez.Strings.skipListBooks)
      );
      finalCallback.invoke([]);
      return;
    }

    logger.info("Start getting the list of books directly from the server");
    // Пробуем получить список книг без прокси
    var url = api_url + "/playlists/" + playlistId;
    var callback = self.method(:onNativePlaylist);
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
  function onNativePlaylist(code, data, context) {
    if (code == 200) {
      var result = [];
      var books = data["items"];
      for (var i = 0; i < books.size(); i++) {
        var bookObj = books[i]["libraryItem"];
        var authorName = "";
        var authorsArray = bookObj["media"]["metadata"]["authors"];
        if (
          authorsArray instanceof Toybox.Lang.Array and
          authorsArray.size() > 0
        ) {
          authorName = authorsArray[0]["name"];
        }
        result.add({
          BooksStore.BOOK_ID => bookObj["id"],
          BooksStore.BOOK_TITLE => bookObj["media"]["metadata"]["title"],
          BooksStore.BOOK_AUTHOR => authorName,
        });
      }

      finalCallback.invoke(result);
      logger.info("The list of books was received directly from the server.");
      return;
    } else if (code == -402) {
      //слишком большой ответ нужен запрос через прокси
      logger.warning("Too big answer. Getting the list of books via proxy.");
      var url = getProxyUrl() + "/audiobookshelf/playlist";
      var callback = self.method(:onProxyPlaylist);
      var params = {
        "server" => server_url,
        "playlist_id" => playlistId,
      };
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
      return;
    }
    finalCallback.invoke([]);
  }

  //***************************************************************************
  function onProxyPlaylist(code, data, context) {
    var result = [];
    if (code == 200) {
      var books = data;
      for (var i = 0; i < books.size(); i++) {
        var bookObj = books[i];
        result.add({
          BooksStore.BOOK_ID => bookObj["id"],
          BooksStore.BOOK_TITLE => bookObj["title"],
          BooksStore.BOOK_AUTHOR => bookObj["author"],
        });
      }
    }
    logger.info("The list of books was received via proxy");
    finalCallback.invoke(result);
  }
}
