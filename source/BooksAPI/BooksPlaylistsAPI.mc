import Toybox.Communications;
import Toybox.Application;

class BooksPlaylistsAPI extends BooksAPI {
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
    var authorisationProcessor = new BooksAuthorisationAPI(
      self.method(:onAuthorisation)
    );
    authorisationProcessor.start();
  }

  function onAuthorisation(token) {
    logger.debug("token: " + token);
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

  function onNativePlaylists(code, data, context) {
    
    if (code == 200) {
    } else if (code == -402) {
      //слишком большой ответ нужен запрос через прокси
    } else if (code < 0) {
      logger.error(
        "Код: " +
          code +
          " " +
          getErrorDescription(code) +
          " url: " +
          context[URL]
      );
    }else{
      logger.error("Код: " + code + " url: " + context[URL]);
    }

    logger.debug(data);
  }

  //     if (code == 200) {
  //       var token = data["token"];
  //       Application.Properties.setValue(TOKEN, token);
  //       finalCallback.invoke(token);
  //     } else {
  //       logger.error("Код: " + code + " url: " + context[URL]);
  //       finalCallback.invoke(null);
  //     }
  //   }
}
