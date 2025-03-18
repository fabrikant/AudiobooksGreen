import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

//*****************************************************************************
//Пункт меню - выбранная папкая (список в классификации литреса)
//со списком папок с книгами
class FolderSelectedItem extends WatchUi.IconMenuItem {
  function initialize(label, booksListInfo, id) {
    var sublabel = Rez.Strings.notSelected;
    if (booksListInfo instanceof Lang.Dictionary) {
      sublabel = booksListInfo[BOOKS_FOLDER_NAME];
    }
    IconMenuItem.initialize(
      label,
      sublabel,
      id,
      new MenuItemDrawable(Rez.Drawables.folder),
      {}
    );
  }

  function onSelectItem() {
    // Проверяем, чтобы были заполнены логин и пароль и пробуем
    // получить перечень списков с книгами
    var login = Application.Properties.getValue(LOGIN);
    var password = Application.Properties.getValue(PASSWORD);
    var token = Application.Properties.getValue(TOKEN);
    if (token.equals("") and (login.equals("") or password.equals(""))) {
      logger.error("Не заданы имя пользователя и пароль");
      WatchUi.pushView(
        new InfoView(Application.loadResource(Rez.Strings.setLoginAndPassword)),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
      return;
    }

    WatchUi.pushView(
      new FolderSelectionMenu(self.method(:onChangeBooksFolder)),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );

    // Показываем прогрессбар, чтобы пользователю было
    // не так скучно ждать авторизацию и получение папок
    WatchUi.pushView(
      new WatchUi.ProgressBar(
        Application.loadResource(Rez.Strings.progressMessageWhileOpenFolders),
        null
      ),
      null,
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  function onChangeBooksFolder(folderInfo) {
    Application.Storage.setValue(BOOKS_FOLDER, folderInfo);
    setSubLabel(folderInfo[BOOKS_FOLDER_NAME]);
  }
}
