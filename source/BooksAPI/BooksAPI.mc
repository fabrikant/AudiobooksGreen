import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

enum {
  // Ключи хранения идентификатора сессии
  // и времени последенего обновления идентификатора
  // и времени последеней авторизации
  SID = "sid",
  SID_TIME = "sid_time",
  AUTHORISATION_TIME = "auth_time",

  BOOKS_FOLDER = "folder",
  BOOKS_FOLDER_ID = "folder_id",
  BOOKS_FOLDER_NAME = "folder_name",

  // ключи по которым хранятся имя
  // пользователя и пароль
  LOGIN = "login",
  PASSWORD = "password",
  LENGHT_COMPLICATIONS = "lenghtComplications",

  URL = "url",
  CONTINUE_METHOD = "continue_method",
  ERROR_METHOD = "error_metod",
  FILES_LIST = "files_list",
  FILE_INDEX = "file_index",
  CODE = "code",
  DATA = "data",
  CONTEXT = "context",
}

//*****************************************************************************
//Общий функционал
class BooksAPI {
  const api_url = "https://api.litres.ru";
  // const books_proxy_url = "https://fv.n-drive.cf";
  const books_proxy_url = "https://cdn.nextdriver.ru";
  const website_url = "https://www.litres.ru";

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
  // Формирование заголовков запроса
  function commonHeaders(sid) {
    var headers = {
      "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
      "User-Agent"
      =>
      "Mozilla/5.0 (X11; Linux x86_64; rv:134.0) Gecko/20100101 Firefox/134.0",
      "app-id" => "115",
      "client-host" => "www.litres.ru",
    };
    if (sid != null) {
      headers["Session-Id"] = sid;
      headers["Cookie"] = "SID=" + sid;
    }
    return headers;
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
