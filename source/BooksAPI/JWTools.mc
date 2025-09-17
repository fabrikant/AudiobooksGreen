import Toybox.System;
import Toybox.Application;

module JWTools {
  function beforeAuthentication() {
    //Если в настройках заданы имя пользователя и пароль, очищаем токен
    //для того чтобы инициализировать логин
    if (loginIsSet()) {
      Application.Properties.setValue(TOKEN, "");
      logger.debug("Cleared token to initialize new authentication");
    }
  }

  //   function logout() {
  //     if (loginIsSet()) {
  //         Application.Properties.setValue(TOKEN, "");
  //     }
  //   }

  function loginIsSet() {
    var login = Application.Properties.getValue(LOGIN);
    var password = Application.Properties.getValue(PASSWORD);
    return !login.equals("") and !password.equals("");
  }

  function getToken() {
    var res = Application.Properties.getValue(TOKEN);
    if (res.equals("")) {
      res = null;
    }else{
      logger.debug("No authorization required. A stored token was found.");
    }
    return res;
  }

}
