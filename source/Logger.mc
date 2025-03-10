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

  private function sendLog(msg) {
    var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var formatMsg = Lang.format("$1$.$2$.$3$ $4$:$5$:$6$ - $7$", [
      timeInfo.day.format("%02d"),
      timeInfo.month.format("%02d"),
      timeInfo.year.format("%04d"),
      timeInfo.hour.format("%02d"),
      timeInfo.min.format("%02d"),
      timeInfo.sec.format("%02d"),
      msg,
    ]);

    System.println(formatMsg);
  }

  function debug(msg) {
    if (logLevel == DEBUG) {
      sendLog(msg);
    }
  }

  function info(msg) {
    if (logLevel <= INFO) {
      sendLog(msg);
    }
  }

  function warning(msg) {
    if (logLevel <= WARNING) {
      sendLog(msg);
    }
  }

  function error(msg) {
    if (logLevel <= ERROR) {
      sendLog(msg);
    }
  }
}
