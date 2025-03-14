import Toybox.System;
import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Media;

//*****************************************************************************
// Получение информации о книге
// и загрузка файлов
class BookFilesDownloaderAPI extends BooksAPI {
  var booksStorage = null;

  var filesList = null;
  var downloadedNumbers = null;
  var token = null;

  // **************************************************************************
  function initialize(booksStorage, filesList) {
    self.booksStorage = booksStorage;
    self.filesList = filesList;
    BooksAPI.initialize();
  }

  // **************************************************************************
  function notifySyncProgress(bytesRecieve, byteSize) {
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
    logger.debug("Начало загрузки файлов");
    var authorisationProcessor = new BooksAuthorisationAPI(
      self.method(:onAuthorisation)
    );
    authorisationProcessor.start();
  }

  // **************************************************************************
  function onAuthorisation(token) {
    self.token = token;
    if (token == null or token.equals("")) {
      var message =
        Application.loadResource(Rez.Strings.notSet) +
        " " +
        Application.loadResource(Rez.Strings.token);
      Communications.notifySyncComplete(message);
      return;
    }

    if (filesList.size() > 0) {
      downloadedNumbers = 0;
      startLoadingFile(0);
    } else {
      booksStorage.checkBooksDownloadComplete();
      Communications.notifySyncComplete(null);
    }
  }

  // **************************************************************************
  function startLoadingFile(fileIndex) {
    var url = getFileUrl(fileIndex);
    var context = { URL => url, FILE_INDEX => fileIndex };
    var headers = { "Authorization" => "Bearer " + token };
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :headers => headers,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
      :mediaEncoding => getEncoding(fileIndex),
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
    }
  }

  // **************************************************************************
  function getEncoding(fileIndex) {
    // По умолчанию думаем, что это mp3
    var encoding = Toybox.Media.ENCODING_MP3;
    var filename = filesList[fileIndex][BooksStore.FILE_NAME];
    var filnameLenght = filename.length();
    var fileExtension = filename.substring(filnameLenght - 3, filnameLenght);
    fileExtension = fileExtension.toLower();

    if (fileExtension.equals("mp3")) {
      encoding = Media.ENCODING_MP3;
    } else if (fileExtension.equals("m4a")) {
      encoding = Media.ENCODING_M4A;
    } else if (fileExtension.equals("wav")) {
      encoding = Media.ENCODING_WAV;
    } else if (fileExtension.equals("adts")) {
      encoding = Media.ENCODING_ADTS;
    }

    return encoding;
  }

  // **************************************************************************
  function getFileUrl(fileIndex) {
    var url =
      server_url +
      "/api/items/" +
      filesList[fileIndex][BooksStore.BOOK_ID] +
      "/file/" +
      filesList[fileIndex][BooksStore.FILE_ID] +
      "/download";
    return url;
  }
}
