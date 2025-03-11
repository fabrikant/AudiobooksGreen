import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

enum {
  BOOKS_FOLDER = "folder",
  BOOKS_FOLDER_ID = "folder_id",
  BOOKS_FOLDER_NAME = "folder_name",

  // ключи по которым хранятся имя
  // пользователя и пароль
  LOGIN = "login",
  PASSWORD = "password",
  SERVER = "server",
  TOKEN = "token",
  LENGHT_COMPLICATIONS = "lenghtComplications",

  URL = "url",
  FILE_INDEX = "file_index",
}

//*****************************************************************************
//Общий функционал
class BooksAPI {
  var server_url = null;
  var api_url = null;
  // const books_proxy_url = "https://fv.n-drive.cf";
  const books_proxy_url = "https://cdn.nextdriver.ru";

  function initialize() {
    server_url = Application.Properties.getValue(SERVER);
    api_url = server_url;
    var lastSymb = server_url.substring(
      server_url.length() - 1,
      server_url.length()
    );
    if (lastSymb.equals("/")) {
      api_url += "api";
      server_url = server_url.substring(0,server_url.length() - 1);
    } else {
      api_url += "/api";
    }
    logger.debug(server_url);
    logger.debug(api_url);
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
  // Обработка ошибок
  function onError(msgArray) {
    logger.error("onError: " + msgArray);
    WatchUi.pushView(new InfoView(msgArray), null, WatchUi.SLIDE_IMMEDIATE);
  }

  // **************************************************************************
  function getErrorMessage(code, data, description) {
    var msg = ["Код: " + code];
    if (!description.equals("")) {
      msg.add(description);
    }
    if (code < 0) {
      msg.add(getErrorDescription(code));
    } else if (data instanceof Lang.Dictionary) {
      msg.add(data.toString());
    } else if (data instanceof Lang.String) {
      msg.add(data);
    }
    return msg;
  }

  // **************************************************************************
  function getErrorDescription(code) {
    if (code == 0) {
      return "An unknown error has occurred.";
    } else if (code == -1) {
      return "A generic BLE error has occurred.";
    } else if (code == -2) {
      return "We timed out waiting for a response from the host.";
    } else if (code == -3) {
      return "We timed out waiting for a response from a server.";
    } else if (code == -4) {
      return "Response contained no data.";
    } else if (code == -5) {
      return "The request was cancelled at the request of the system.";
    } else if (code == -101) {
      return "Too many requests have been made.";
    } else if (code == -102) {
      return "Serialized input data for the request was too large.";
    } else if (code == -103) {
      return "Send failed for an unknown reason.";
    } else if (code == -104) {
      return "No BLE connection is available.";
    } else if (code == -200) {
      return "Request contained invalid http header fields.";
    } else if (code == -201) {
      return "Request contained an invalid http body.";
    } else if (code == -202) {
      return "Request used an invalid http method.";
    } else if (code == -300) {
      return "Request timed out before a response was received.";
    } else if (code == -400) {
      return "Response body data is invalid for the request type.";
    } else if (code == -401) {
      return "Response contained invalid http header fields.";
    } else if (code == -402) {
      return "Serialized response was too large.";
    } else if (code == -403) {
      return "Ran out of memory processing network response.";
    } else if (code == -1000) {
      return "Filesystem too full to store response data.";
    } else if (code == -1001) {
      return "Indicates an https connection is required for the request.";
    } else if (code == -1002) {
      return "Content type given in response is not supported or does not match what is expected.";
    } else if (code == -1003) {
      return "Http request was cancelled by the system.";
    } else if (code == -1004) {
      return "Connection was lost before a response could be obtained.";
    } else if (code == -1005) {
      return "Downloaded media file was unable to be read.";
    } else if (code == -1006) {
      return "Downloaded image file was unable to be processed.";
    } else if (code == -1007) {
      return "HLS content could not be downloaded. Most often occurs when requested and provided bit rates do not match.";
    }
    return "";
  }
}
