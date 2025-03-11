import Toybox.Communications;
import Toybox.Lang;

class WebRequestWrapper {
  hidden var finalCallback; // function always takes 3 arguments
  hidden var context; // this is the 3rd argument
  hidden var url;

  function initialize(context) {
    self.context = context;
  }

  function start(url, params, options, callback) {
    self.finalCallback = callback;
    self.url = url;
    logger.debug("start url: " + url);
    Communications.makeWebRequest(
      url,
      params,
      options,
      self.method(:onWebResponse)
    );
  }

  function onWebResponse(code, data) {
    logger.debug("code: " + code + " url: " + url);
    if (finalCallback instanceof Lang.Method) {
      finalCallback.invoke(code, data, context);
    }
  }
}

module WebRequest {
  function makeWebRequest(url, params, options, callback) {
    var context = null;
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
}
