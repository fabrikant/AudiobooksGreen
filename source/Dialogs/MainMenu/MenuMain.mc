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

  
}
