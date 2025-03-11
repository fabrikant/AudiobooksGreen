import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class FolderSelectionMenu extends WatchUi.Menu2 {
  var finalCallback = null;

  function initialize(finalCallback) {
    self.finalCallback = finalCallback;
    Menu2.initialize({
      :title => Rez.Strings.selectListMenuTitle,
      :theme => Style.getMenuTheme(),
    });

    // Проверяем, чтобы были заполнены логин и пароль и пробуем
    // получить перечень списков с книгами
    var login = Application.Properties.getValue(LOGIN);
    var password = Application.Properties.getValue(PASSWORD);

    if (
      login == null or
      login.equals("") or
      password == null or
      password.equals("")
    ) {
      logger.error("Не заданы имя пользователя и пароль");
      WatchUi.pushView(
        new InfoView(Rez.Strings.setLoginAndPassword),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
    } else {
      var getter = new BooksPlaylistsAPI(self.method(:onGetBooksFolders));
      getter.start();
    }
  }

  function onGetBooksFolders(folderList) {
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    if (folderList.size() == 0) {
      // Закрываем текущее меню
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      //  Выводим окно с ошибкой
      WatchUi.pushView(
        new InfoView(Application.loadResource(Rez.Strings.noFoldersFound)),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
    } else {
      for (var i = 0; i < folderList.size(); i++) {
        addItem(new FolderToSelectItem(finalCallback, folderList[i]));
      }
    }
  }
}
