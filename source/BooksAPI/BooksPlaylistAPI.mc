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
        logger.debug(bookObj);
        result.add({
          BooksStore.BOOK_ID => bookObj["id"],
          BooksStore.BOOK_TITLE => bookObj["media"]["metadata"]["title"],
          BooksStore.BOOK_AUTHOR => bookObj["media"]["metadata"]["authors"][0][
            "name"
          ],
          BooksStore.BOOK_COVER_URL => bookObj["media"]["coverPath"],
        });
      }

      logger.debug(result);
      finalCallback.invoke(result);
      return;
    } else if (code == -402) {
      //слишком большой ответ нужен запрос через прокси

      var url = books_proxy_url + "/audiobookshelf/playlist";
      var callback = self.method(:onProxyPlaylist);
      var params = {
        "server" => server_url,
        "token" => token,
        "playlist_id" => playlistId,
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
          BooksStore.BOOK_COVER_URL => bookObj["cover"],
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
