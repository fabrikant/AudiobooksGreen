import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;

class BooksAuthentificationAPI extends BooksAPI {
  var finalCallback = null;

  function initialize(finalCallback) {
    self.finalCallback = finalCallback;
  }

  // Если авторизация была недавно, пропускаем этот шаг
  function start() {
    var authUnixTime = Application.Storage.getValue(AUTHORISATION_TIME);

    if (authUnixTime == null) {
      // авторизации еще ни разу не было
      logger.debug("Начало первой авторизации");
      var sidGetter = new BooksSessionIdAPI(self.method(:startLogin));
      sidGetter.start();
    } else {
      // Авторизация когда-то была. Проверим как давно и
      // обновим при необходимости
      var intervalHours = 2;
      var auth_time = new Time.Moment(authUnixTime);
      var now_time = Time.now();
      if (
        now_time.compare(auth_time) >=
        Time.Gregorian.SECONDS_PER_HOUR * intervalHours
      ) {
        logger.debug("Начало обновления авторизации");
        var sidGetter = new BooksSessionIdAPI(self.method(:startLogin));
        sidGetter.start();
      } else {
        logger.debug("Авторизация актуальна. Обновление не требуется.");
        finalCallback.invoke();
      }
    }
  }

  function startLogin(sid) {
    logger.debug("Продолжение авторизации после получения sid");
    var path = "/foundation/api/auth/login";
    var url = api_url + path;
    var login = Application.Properties.getValue(LOGIN);
    var password = Application.Properties.getValue(PASSWORD);

    if (login == null or login.equals("")) {
      var msg = "Не задан логин";
      logger.error(msg);
      onError([msg]);
    }
    if (password == null or password.equals("")) {
      var msg = "Не задан пароль";
      logger.error(msg);
      onError([msg]);
    }

    var parameters = { "login" => login, "password" => password };
    var context = { URL => url };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :headers => commonHeaders(sid),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };

    logger.debug("start: " + url);
    Communications.makeWebRequest(
      url,
      parameters,
      options,
      self.method(:onLogin)
    );
  }

  function onLogin(code, data, context) {
    if (code == 200) {
      logger.debug("Успешная авторизация");
      Application.Storage.setValue(AUTHORISATION_TIME, Time.now().value());
      finalCallback.invoke();
    } else {
      onError(getErrorMessage(code, data, "Авторизация"));
    }
  }
}
