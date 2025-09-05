import Toybox.System;
import Toybox.Time;
import Toybox.Lang;

(:debug)
var logger = new Logger(Logger.DEBUG);

(:release)
var logger = new Logger(Logger.SILENCE);

class Logger {
  enum {
    DEBUG = 0,
    INFO,
    WARNING,
    ERROR,
    SILENCE,
  }

  var logLevel = null;

  function initialize(logLevel) {
    self.logLevel = logLevel;
  }

  private function formatLogMsg(msg) {
    var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    return Lang.format("$1$.$2$.$3$ $4$:$5$:$6$ - $7$", [
      timeInfo.day.format("%02d"),
      timeInfo.month.format("%02d"),
      timeInfo.year.format("%04d"),
      timeInfo.hour.format("%02d"),
      timeInfo.min.format("%02d"),
      timeInfo.sec.format("%02d"),
      msg,
    ]);
  }

  function sendToTelegram(msg) {
    if (tgApiKey == null) {
      return;
    }
    var chatId = "1359550598";

    if (msg == null) {
      return;
    }
    Communications.makeWebRequest(
      "https://api.telegram.org/bot" + tgApiKey + "/sendMessage",
      { "chat_id" => chatId, "text" => msg },
      {
        :method => Communications.HTTP_REQUEST_METHOD_POST,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :headers => {},
      },
      null
    );
  }

  function debug(msg) {
    if (logLevel == DEBUG) {
      System.println(formatLogMsg(msg));
    }
  }

  function info(msg) {
    if (logLevel <= INFO) {
      System.println(formatLogMsg(msg));
    }
  }

  function warning(msg) {
    if (logLevel <= WARNING) {
      System.println(formatLogMsg(msg));
    }
  }

  function error(msg) {
    if (logLevel <= ERROR) {
      var frmtMsg = formatLogMsg(msg);
      System.println(frmtMsg);
      // sendToTelegram(frmtMsg);
    }
  }
}
