import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

class BooksSessionIdAPI extends BooksAPI {
  var finalCallback = null;

  function initialize(finalCallback) {
    self.finalCallback = finalCallback;
  }

  // Получаем SID если еще не получали
  // или получали давно
  function start() {
    var sid = Application.Storage.getValue(SID);
    if (sid == null or sid.equals("")) {
      logger.debug("Начало первого получения sid");
      startGettingSID();
    } else {
      var intervalDays = 7;
      var sid_time = new Time.Moment(
        Application.Storage.getValue(SID_TIME)
      );
      var now_time = Time.now();
      if (
        now_time.compare(sid_time) >=
        Time.Gregorian.SECONDS_PER_DAY * intervalDays
      ) {
        logger.debug("Начало обновления sid");
        startGettingSID();
      } else {
        logger.debug("Обновление sid не требуется");
        finalCallback.invoke(sid);
      }
    }
  }

  // **************************************************************************
  // Получение sid aka session-ID
  function startGettingSID() {
    var path = "/litres_sid";
    var url = books_proxy_url + path;

    var context = { URL => url };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };

    logger.debug("start: " + url);
    Communications.makeWebRequest(url, {}, options, self.method(:onGettingSID));
  }

  function onGettingSID(code, data, context) {
    if (code == 200) {
      var sid = data["sid"];
      Application.Storage.setValue(SID, sid);
      Application.Storage.setValue(SID_TIME, Time.now().value());
      logger.debug("Успешно получен sid: " + sid);
      finalCallback.invoke(sid);
    } else {
      var sid = Application.Storage.getValue(SID);
      if (sid == null) {
        onError(getErrorMessage(code, data, "Получение Session-ID"));
      } else {
        logger.warning(
          "Не удалось получить новый sid. Код ошибки: " +
            code +
            " Продолжаем использовать sid: " +
            sid
        );
        finalCallback.invoke(sid);
      }
    }
  }
}
