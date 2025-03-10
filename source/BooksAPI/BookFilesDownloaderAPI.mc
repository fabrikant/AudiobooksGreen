import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
// Получение информации о книге
// и загрузка файлов
class BookFilesDownloaderAPI extends BooksAPI {
  var booksStorage = null;

  var filesList = null;
  var downloadedNumbers = null;
  var sid = null;

  // **************************************************************************
  function initialize(booksStorage, filesList) {
    self.booksStorage = booksStorage;
    self.filesList = filesList;
  }

  // **************************************************************************
  function notifySyncProgress(bytesRecieve, byteSize) {

    // Отчитываемся, что процесс синхронизации еще живой
    // и не рухнул с ошибкой
    AbooksSyncDelegate.registerSyncStatus(false);

    if (filesList == null or filesList.size() == 0) {
      return;
    }

    var percentPerFile = 100.0 / filesList.size();
    var percentageOfDownloadedFiles = percentPerFile * downloadedNumbers;

    var percentageOfCurrentFile = 0;
    if (
      bytesRecieve instanceof Lang.Number and
      byteSize instanceof Lang.Number and
      byteSize > 0 and
      bytesRecieve > 0
    ) {
      var partOfCurrentFule = bytesRecieve.toDouble() / byteSize;
      percentageOfCurrentFile = partOfCurrentFule * percentPerFile;
    }

    var percents = (
      percentageOfDownloadedFiles + percentageOfCurrentFile
    ).toNumber();
    var percetnsOfFullDownloadedFiles = (
      percentPerFile *
      (downloadedNumbers + 1)
    ).toNumber();
    if (percents > percetnsOfFullDownloadedFiles) {
      percents = percetnsOfFullDownloadedFiles;
    }
    if (percents < 0) {
      percents = 0;
    }
    if (percents >= 100) {
      percents = 100;
    }
    Communications.notifySyncProgress(percents);
  }

  // **************************************************************************
  function start() {
    sid = Application.Storage.getValue(SID);
    if (filesList.size() > 0) {
      downloadedNumbers = 0;
      startLoadingFile(0);
    } else {
      booksStorage.checkBooksDownloadComplete();
      Communications.notifySyncComplete(null);
      AbooksSyncDelegate.registerSyncStatus(true);
    }
  }

  // **************************************************************************
  function startLoadingFile(fileIndex) {
    var url = getFileUrl(fileIndex);
    var context = { URL => url, FILE_INDEX => fileIndex };
    var headers = commonHeaders(sid);
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
      :mediaEncoding => Toybox.Media.ENCODING_MP3,
      :context => context,
      :fileDownloadProgressCallback => self.method(:notifySyncProgress),
    };

    logger.debug("start: " + url);
    Communications.makeWebRequest(
      url,
      {},
      options,
      self.method(:onGettingFile)
    );
  }

  // **************************************************************************
  function onGettingFile(code, data, context) {
    // Отчитываемся, что процесс синхронизации еще живой
    // и не рухнул с ошибкой
    AbooksSyncDelegate.registerSyncStatus(false);

    var fileIndex = context[FILE_INDEX];
    if (code == 200) {
      var filename = filesList[fileIndex][BooksStore.FILE_NAME];
      logger.info("Загружен файл: " + filename);
      booksStorage.onFileDownload(filesList[fileIndex], data.getId());
    } else {
      logger.error("Код: " + code + " url: " + context[URL]);
    }

    downloadedNumbers += 1;

    // Независимо от результата загрузки текущего файла,
    // Пробуем грузить следующий.
    var newIndex = fileIndex + 1;
    if (newIndex < filesList.size()) {
      startLoadingFile(newIndex);
    } else {
      // Все файлы загружены
      booksStorage.checkBooksDownloadComplete();
      Communications.notifySyncComplete(null);
      AbooksSyncDelegate.registerSyncStatus(true);
    }
  }

  // **************************************************************************
  // "https://subscription.litres.ru/download_book_subscr/" ?????
  function getFileUrl(fileIndex) {
    var url = "https://www.litres.ru/download_book/";
    if (filesList[fileIndex][BooksStore.URL_SUBSCRIPTION]) {
      url = "https://www.litres.ru/download_book_subscr/";
    }
    url +=
      filesList[fileIndex][BooksStore.BOOK_ID] +
      "/" +
      filesList[fileIndex][BooksStore.FILE_ID] +
      "/" +
      filesList[fileIndex][BooksStore.FILE_NAME];
    return url;
  }

  // **************************************************************************
  function createOptions(sid, context) {
    return {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => commonHeaders(sid),
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :context => context,
    };
  }
}
