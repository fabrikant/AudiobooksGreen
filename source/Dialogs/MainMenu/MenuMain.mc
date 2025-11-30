import Toybox.Graphics;
import Toybox.WatchUi;

// **************************************************************************
class MenuMain extends WatchUi.Menu2 {
  function initialize() {
    //Пересканируем книги. Отметим полностью скачанные
    var booksStorage = new BooksStore();
    booksStorage.checkBooksDownloadComplete();
    Menu2.initialize({
      :title => Rez.Strings.menuMain,
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

    // Дополнительные функции
    addItem(new CommandMenuSettings());

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
