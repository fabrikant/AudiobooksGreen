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
    var error = getAuthorizationProprtiesError();
    if (error != null) {
      WatchUi.pushView(new InfoView(error), null, WatchUi.SLIDE_IMMEDIATE);
      return;
    }

    // Показываем прогрессбар, чтобы пользователю было
    // не так скучно ждать авторизацию и получение папок
    WatchUi.pushView(
      new ProgressBarWithCallback(
        Application.loadResource(Rez.Strings.progressMessageProcessing),
        null,
        self.method(:startGettingFolders)
      ),
      null,
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  function startGettingFolders() {
    //Выбрираем лучший прокси
    var booksApi = new BooksAPI();
    booksApi.chooseBestProxy(self.method(:onChooseBestProxy));
  }
  //После выбора прокси начинаем получение папок
  function onChooseBestProxy() {
    JWTools.beforeAuthentication();
    var getter = new BooksPlaylistsAPI(self.method(:onGetBooksFolders));
    getter.start();
  }

  function onGetBooksFolders(folderList) {
    WatchUi.switchToView(
      new FolderSelectionMenu(self.method(:onChangeBooksFolder), folderList),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  function onChangeBooksFolder(folderInfo) {
    Application.Storage.setValue(BOOKS_FOLDER, folderInfo);
    setSubLabel(folderInfo[BOOKS_FOLDER_NAME]);
  }
}
