import Toybox.Graphics;
import Toybox.WatchUi;

// **************************************************************************
class MenuMain extends WatchUi.Menu2 {
  
  function initialize() {
    //Пересканируем книги. Отметим полностью скачанные
    var booksStorage = new BooksStore();
    booksStorage.checkBooksDownloadComplete();
    Menu2.initialize({
      :title => Rez.Strings.settings,
      :theme => Style.getMenuTheme(),
    });

    // Порядок пунктов меню меняется в зависимости от того
    // были ли введены логин пароль и папка для синхронизации
    // если нет, показываем их сверху
   
    var folderAdded = false;
    var login = Application.Properties.getValue(LOGIN);
    var password = Application.Properties.getValue(PASSWORD);
    var folder = Application.Storage.getValue(BOOKS_FOLDER);

    // Имя пользователя и пароль
    if (
      login == null or
      login.equals("") or
      password == null or
      password.equals("")
    ) {
      addAuthItems();
    }


    // Папка на сервере
    if (folder == null or folder.equals("")) {
      addFolderItem();
      folderAdded = true;
    }

    // Списки книг
    addBooksItems();

    // Папка на сервере
    if (!folderAdded) {
      addFolderItem();
    }

    // Прочие настройки
    addItem(new CommandtemMenuColors());
    addItem(new CommandtemMenuComplications());
    addItem(new CommandtemMenuAuthorisation());
   

    // О программе
    addItem(new CommandtemShowAboutView());
  }

  function addBooksItems() {
    addItem(new CommandtemResumeCurrentBook());
    addItem(new CommandtemSync());
    addItem(new CommandtemSyncBoomarks());
    addItem(new ItemMainMenuPlaylist());
    addItem(new ItemMainMenuDownloaded());
    addItem(new ItemMainMenuAllBooks());
  }

  function addFolderItem() {
    addItem(
      new FolderSelectedItem(
        Rez.Strings.booksFolder,
        Application.Storage.getValue(BOOKS_FOLDER),
        BOOKS_FOLDER
      )
    );
  }

  function addAuthItems() {
    var onChangeCallback = new Lang.Method(
      BooksExtraModule,
      :removeAuthorization
    );
    addItem(
      new PickerItem(
        Rez.Strings.login,
        Application.Properties.getValue(LOGIN),
        LOGIN,
        onChangeCallback
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.password,
        Application.Properties.getValue(PASSWORD),
        PASSWORD,
        onChangeCallback
      )
    );
  }
}
