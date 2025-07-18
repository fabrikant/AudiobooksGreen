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

    var folderAdded = false;
    var folder = Application.Storage.getValue(BOOKS_FOLDER);

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
    if (Toybox.Graphics has :createBufferedBitmap) {
      addItem(new CommandItemMenuColors());
    }
    if (Toybox has :Complications) {
      addItem(new CommandItemMenuComplications());
    }
    addItem(new CommandItemMenuAuthorisation());

    // Дополнительные функции
    addItem(new CommandMenuExtraSettings());

    // О программе
    addItem(new CommandItemShowAboutView());
  }

  function addBooksItems() {
    addItem(new CommandItemResumeCurrentBook());
    addItem(new CommandItemSync());
    addItem(new CommandItemSyncBoomarks());
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
}
