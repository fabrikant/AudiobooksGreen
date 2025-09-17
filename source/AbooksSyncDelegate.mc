import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Media;
import Toybox.Time;
import Toybox.Application;

class AbooksSyncDelegate extends Communications.SyncDelegate {
  // **************************************************************************
  function initialize() {
    SyncDelegate.initialize();
  }

  // **************************************************************************
  //Старт синхронизации
  function onStartSync() as Void {
    var folderId = null;
    var folderInfo = Application.Storage.getValue(BOOKS_FOLDER);
    if (folderInfo != null) {
      folderId = folderInfo[BOOKS_FOLDER_ID];
    }
    if (folderId == null) {
      var message = Application.loadResource(Rez.Strings.syncFolderNotSelected);
      logger.error(message);
      logger.finalizeLogging();
      Communications.cancelAllRequests();
      Communications.notifySyncComplete(message);
      return;
    }

    JWTools.beforeAuthentication();
    var folderGetter = new BooksPlaylistAPI(
      self.method(:onGettingFolder),
      folderId
    );
    folderGetter.start();
  }

  // **************************************************************************
  //Получили список книг в папке на сайте
  //определяем что нужно грузить
  function onGettingFolder(booksList) {
    // На устройстве могут быть полнстью и частично загруженные книги
    // 1. Нужно определить, какие книги из тех, что есть на устройстве
    // удалены на сервере и удалить их на устройстве
    // 2. Добавить в список новые книги с сервера
    // 3. Пройтись по каждой книге и загрузить обложки
    // 4. Пройтись по каждой книге и получить список файлов
    // 5. Записать новые списки файлов
    // 6. Пройти по всем спискам файлов и определить ЕДИНЫЙ список файлов к загрузке
    // 7. Скачать файлы

    var booksStorage = new BooksStore();
    booksStorage.addNewBooks(booksList);
    booksStorage.removeOldBooks(booksList);

    // Старт загрузки обложек
    var coverDownloader = new BookCoversDownloaderAPI(
      self.method(:onCoversDownload),
      booksStorage
    );
    coverDownloader.start();
  }

  // **************************************************************************
  // После загрузки обложек, загружаем список файлов
  function onCoversDownload(booksStorage) {
    var idsToDownload = booksStorage.getIdsToDownload();
    startLoadingFileList(booksStorage, idsToDownload, 0);
  }

  // **************************************************************************
  // Начинаем грузить очередную книгу
  // Получаем информацию о файлах
  function startLoadingFileList(booksStorage, idsToDownload, index) {

    while (index < idsToDownload.size()) {
      var finalCallback = self.method(:onLoadFileList);
      var bookLoader = new BookFileListAPI(
        finalCallback,
        booksStorage,
        idsToDownload,
        index
      );
      //Пытаемся избежать лишней рукурсии. Если много книг, вылетает Error: Stack Overflow Error
      if (bookLoader.fileListRecieved()){
        index +=1;
      }else{
        bookLoader.start();
        return;
      }
    }
    logger.debug("Lists of files for all books were received");
    startProgressSync(booksStorage);
  }

  // **************************************************************************
  // Получили информацию о книге
  function onLoadFileList(booksStorage, idsToDownload, index) {
    index += 1;
    startLoadingFileList(booksStorage, idsToDownload, index);
  }

  // **************************************************************************
  // Получили информацию обо всех книгах
  function startProgressSync(booksStorage) {
    // Загружаем прогресс по книгам
    var progress = new ProgressAPI(self.method(:onProgressSync), booksStorage);
    progress.start();
  }

  // **************************************************************************
  // После синхронизации закладок, скачиваем контент
  function onProgressSync(booksStorage) {
    var filesToDownload = booksStorage.getFilesToDownload();
    var downloader = new BookFilesDownloaderAPI(booksStorage, filesToDownload);
    downloader.start();
  }

  // **************************************************************************
  // Called by the system to determine if the app needs to be synced.
  function isSyncNeeded() as Boolean {
    var result = false;
    if (
      getApp().manualSyncStarted or
      Application.Properties.getValue("autosyncWhileCharging")
    ) {
      result = true;
    }
    getApp().manualSyncStarted = false;
    return result;
  }

  // Called when the user chooses to cancel an active sync.
  function onStopSync() as Void {
    Communications.cancelAllRequests();
    Communications.notifySyncComplete(null);
    logger.finalizeLogging();
  }
}
