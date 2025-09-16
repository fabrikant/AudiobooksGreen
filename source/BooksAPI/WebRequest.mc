import Toybox.Communications;
import Toybox.Lang;

class WebRequestWrapper {
  hidden var finalCallback;
  hidden var context;
  hidden var url;

  function initialize(context) {
    self.context = context;
  }

  function start(url, params, options, callback) {
    self.finalCallback = callback;
    self.url = url;
    logger.warning(httpMethodString(options) + " url: " + url);
    Communications.makeWebRequest(
      url,
      params,
      options,
      self.method(:onWebResponse)
    );
  }

  function makeImageRequest(url, params, options, callback) {
    self.finalCallback = callback;
    self.url = url;
    Communications.makeImageRequest(
      url,
      params,
      options,
      self.method(:onWebResponse)
    );
  }

  function onWebResponse(code, data) {
    if (code < 200 or code > 299) {
      var errorMsg = "url: " + url + " response code: " + code;
      var codeDescription = WebRequest.getErrorDescription(code);

      if (!codeDescription.equals("")) {
        errorMsg += " (" + codeDescription + ")";
      }

      if (data instanceof Lang.String) {
        errorMsg += "\n " + data;
      } else if (data instanceof Lang.Dictionary) {
        errorMsg += "\n " + data.toString();
      }

      if (code == -402) {
        logger.warning(errorMsg);
      } else {
        logger.error(errorMsg);
      }
    } else {
      logger.info("url: " + url + " response code: " + code);
    }

    if (finalCallback instanceof Lang.Method) {
      if (context == :IMAGE_REQUEST) {
        finalCallback.invoke(code, data);
      } else {
        finalCallback.invoke(code, data, context);
      }
    }
  }

  function httpMethodString(options) {
    var result = "GET";
    if (options[:method] == Communications.HTTP_REQUEST_METHOD_POST) {
      result = "POST";
    } else if (options[:method] == Communications.HTTP_REQUEST_METHOD_DELETE) {
      result = "DELETE";
    }
    if (options[:method] == Communications.HTTP_REQUEST_METHOD_PUT) {
      result = "PUT";
    }
    return result;
  }
}

module WebRequest {
  function makeWebRequest(url, params, options, callback) {
    var context = null;
    // создаем новые опции, чтобы не испортить старые
    // возможно они будут использованы повторно
    var newOptions = {};
    var keys = options.keys();
    for (var i = 0; i < keys.size(); i++) {
      if (keys[i] == :context) {
        context = options[keys[i]];
      } else {
        newOptions[keys[i]] = options[keys[i]];
      }
    }
    var request = new WebRequestWrapper(context);
    request.start(url, params, newOptions, callback);
  }

  function makeImageRequest(url, params, options, callback) {
    var request = new WebRequestWrapper(:IMAGE_REQUEST);
    request.makeImageRequest(url, params, options, callback);
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
