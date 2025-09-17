import Toybox.System;
import Toybox.Time;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Communications;

var logger = new Logger(Logger.SILENCE);

class Logger extends Lang.Object {
  enum {
    DEBUG = 0,
    INFO,
    WARNING,
    ERROR,
    SILENCE,
  }

  private var chatId = "";
  private var logLevel = null;
  private var tgDebug = false;
  private var tgMessages = "";
  private var lastTgMessagesTime = 0;

  function initialize(logLevel) {
    self.logLevel = logLevel;
  }

  function reloadSettings(propName, propValue) {
    self.logLevel = Application.Properties.getValue("logLevel");
    self.tgDebug = Application.Properties.getValue("telegramDebug");
    self.chatId = Application.Properties.getValue("telegramChatId");
    if (
      propName != null and
      propValue != null and
      propName.equals("telegramDebug") and
      propValue
    ) {
      Communications.openWebPage(tgBotURL, null, null);
    }
  }

  private function formatLogMsg(msg, msgLevel) {
    var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    var isWebRequest = false;

    // Если последнее сообщение начинается с GET, DELETE, PUT или POST,
    // не отправляем сообщение в телеграм. Часы плохо реагируют, если
    // активны сразу 2 web запроса
    if (
      tgDebug and
      msg instanceof Lang.String and
      (msg.substring(0, 3).equals("GET") or
        msg.substring(0, 4).equals("POST") or
        msg.substring(0, 3).equals("PUT") or
        msg.substring(0, 6).equals("DELETE"))
    ) {
      isWebRequest = true;
    }

    var frmtMsg = Lang.format("$1$.$2$.$3$ $4$:$5$:$6$ - $7$ - $8$", [
      timeInfo.day.format("%02d"),
      timeInfo.month.format("%02d"),
      timeInfo.year.format("%04d"),
      timeInfo.hour.format("%02d"),
      timeInfo.min.format("%02d"),
      timeInfo.sec.format("%02d"),
      msgLevel,
      msg,
    ]);

    return { :msg => frmtMsg, :isWebRequest => isWebRequest };
  }

  private function sendToTelegram() {
    Communications.makeWebRequest(
      "https://api.telegram.org/bot" + tgApiKey + "/sendMessage",
      { "chat_id" => chatId, "text" => tgMessages },
      {
        :method => Communications.HTTP_REQUEST_METHOD_POST,
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :headers => {},
      },
      null
    );
    tgMessages = "";
  }

  private function processMessage(msgDict) {
    System.println(msgDict[:msg]);

    if (
      tgDebug and
      tgApiKey != null and
      !tgApiKey.equals("") and
      !chatId.equals("")
    ) {
      // Добавляем текущее сообщение к порции сообщений для отправки
      tgMessages = tgMessages + "\n" + msgDict[:msg];

      // Проверяем не пора ли отправить сообщения в телеграм:
      // Отправляем не чаще чем 1 раз в 20 секунд
      if (!msgDict[:isWebRequest]) {
        var now = Time.now().value();
        if (lastTgMessagesTime + 20 <= now) {
          sendToTelegram();
          lastTgMessagesTime = now;
        }
      } else {
        System.println("Пропущено сообщение");
      }
    }
  }

  function finalizeLogging() {
    if (
      tgDebug and
      tgApiKey != null and
      !tgApiKey.equals("") and
      !chatId.equals("") and
      !tgMessages.equals("")
    ) {
      sendToTelegram();
    }
    tgMessages = "";
  }

  function debug(msg) {
    if (logLevel == DEBUG) {
      processMessage(formatLogMsg(msg, "DEBUG"));
    }
  }

  function info(msg) {
    if (logLevel <= INFO) {
      processMessage(formatLogMsg(msg, "INFO"));
    }
  }

  function warning(msg) {
    if (logLevel <= WARNING) {
      processMessage(formatLogMsg(msg, "WARNING"));
    }
  }

  function error(msg) {
    if (logLevel <= ERROR) {
      processMessage(formatLogMsg(msg, "ERROR"));
    }
  }
}
