import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;

class BooksMenuAll extends BooksMenuAbstract {
  var booksOnServer = null;
  var folderId = null;

  // **************************************************************************
  function initialize() {
    BooksMenuAbstract.initialize(Rez.Strings.allBooks);
    //Запускаем запрос к серверу
    booksOnServer = [];
    checkBooksOnServer();
  }

  // **************************************************************************
  function checkBooksOnServer() {
    var folderInfo = Application.Storage.getValue(BOOKS_FOLDER);
    if (folderInfo == null) {
      return;
    }

    folderId = folderInfo[BOOKS_FOLDER_ID];
    if (folderId == null) {
      return;
    }

    setTitle(new CustomMenuTitle(Rez.Strings.progressMessageProcessing));

    //Выбрираем лучший прокси
    var booksApi = new BooksAPI();
    booksApi.chooseBestProxy(self.method(:onChooseBestProxy));
  }

  // **************************************************************************
  //После выбора лучшего прокси
  function onChooseBestProxy() {
    logger.debug("Start receiving books information");
    var folderGetter = new BooksPlaylistAPI(
      self.method(:onGettingFolder),
      folderId
    );
    folderGetter.start();
  }

  // **************************************************************************
  function onGettingFolder(booksList) {
    logger.debug(
      "Information about books has been retrieved. The number of books in the playlist is: " +
        booksList.size()
    );

    //Запоминаем идентификаторы книг, которые присутствуют на сервере
    for (var i = 0; i < booksList.size(); i++) {
      booksOnServer.add(booksList[i]["book_id"]);
    }

    //Добавляем новые книги в коллекцию,
    //но не удаляем старые
    var booksStorage = new BooksStore();
    booksStorage.addNewBooks(booksList);

    logger.debug("Start receiving covers");
    // Старт загрузки обложек
    var coverDownloader = new BookCoversDownloaderAPI(
      self.method(:onCoversDownload),
      booksStorage
    );
    coverDownloader.start();
  }

  // **************************************************************************
  function onCoversDownload(booksStorage) {
    logger.debug("Covers has been retrieved");
    setTitle(new CustomMenuTitle(Rez.Strings.allBooks));

    if (booksStorage.booksOnDevice.keys().size() == 0) {
      //Список пустой, ничего не делаем
      logger.finalizeLogging();
      return;
    }

    //В списке что-то есть. Нужно найти и удалить
    //Пустой элемент списка, прежде чем добавлять нормальные элементы
    var findedItemIndex = findItemById(:empty);
    if (findedItemIndex >= 0) {
      logger.debug("Removing an empty list element");
      deleteItem(findedItemIndex);
    }

    //Получили список книг. В нем содержатся все книги,
    //которые есть на устройстве и книги, которые есть на сервере
    //Нужно добавить в меню недостающие пункты с книгами и
    //отметить их статус относительно устройства и сервера

    var booksOnDevice = booksStorage.booksOnDevice;
    var booksKeys = booksOnDevice.keys();

    for (var i = 0; i < booksKeys.size(); i++) {
      var book_id = booksKeys[i];
      findedItemIndex = findItemById(book_id);
      if (findedItemIndex < 0) {
        var filesDescription = getFilesDescription(book_id, booksStorage);
        var item = new BookItem(
          book_id,
          weak(),
          booksOnDevice[book_id],
          filesDescription,
          fonts
        );
        addItem(item);
        logger.debug(
          "The book [" +
            book_id +
            "] " +
            booksOnDevice[book_id][BooksStore.BOOK_TITLE] +
            " has been added to the list. "
        );
        item.setServerStatus(boookRepresentsOnServer(book_id, booksOnServer));
      } else {
        var item = getItem(findedItemIndex);
        item.setServerStatus(boookRepresentsOnServer(book_id, booksOnServer));
      }
    }
    logger.finalizeLogging();
  }

  // **************************************************************************
  function boookRepresentsOnServer(book_id, booksOnServer) {
    if (booksOnServer.indexOf(book_id) < 0) {
      return false;
    } else {
      return true;
    }
  }

  // **************************************************************************
  function getFilesDescription(bookId, booksStorage) {
    var files = booksStorage.getFileList(bookId);
    var result = "--/--";
    if (files != null and files instanceof Lang.Array and files.size() > 0) {
      var downloaded = 0;
      for (var i = 0; i < files.size(); i++) {
        if (files[i][booksStorage.FILE_CONTENT_ID] != null) {
          downloaded += 1;
        }
      }
      if (downloaded == null) {
        downloaded = "--";
      }
      return "" + downloaded + "/" + files.size();
    }
    return result;
  }

  // **************************************************************************
  function getBooksArray(books) {
    var result = [];
    var booksKeys = books.keys();
    for (var i = 0; i < booksKeys.size(); i++) {
      result.add(booksKeys[i]);
    }
    return result;
  }

  // **************************************************************************
  function getAvailableСommands(ownerItemWeak) {
    return [];
  }
}
