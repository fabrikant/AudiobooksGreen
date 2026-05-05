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

  var lastMomentMeasurement = null;
  var lastBytesRecieve = null;
  var totalBytesRecieve = 0;

  // **************************************************************************
  function initialize(booksStorage, filesList) {
    self.booksStorage = booksStorage;
    self.filesList = filesList;
    self.totalBytesRecieve = 0.toLong();
    BooksAPI.initialize();
  }

  // **************************************************************************
  function calculateDownloadingSpeed(seconds, bytes) {
    if (seconds <= 0) {
      return (
        "0 " +
        Application.loadResource(Rez.Strings.downloadUnitB) +
        "/" +
        Application.loadResource(Rez.Strings.seconds)
      );
    }

    var speed = bytes.toFloat() / seconds;
    var format, resId;

    if (speed >= 1048576.0) {
      speed /= 1048576.0;
      format = "%.2f";
      resId = Rez.Strings.downloadUnitMB;
    } else if (speed >= 1024.0) {
      speed /= 1024.0;
      format = "%.1f";
      resId = Rez.Strings.downloadUnitKB;
    } else {
      format = "%d";
      resId = Rez.Strings.downloadUnitB;
    }

    return (
      speed.format(format) +
      " " +
      Application.loadResource(resId) +
      "/" +
      Application.loadResource(Rez.Strings.seconds)
    );
  }

  // **************************************************************************
  function calculateTotalDownload(bytesRecieve) {
    // В Monkey C используем Float для точности при делении
    totalBytesRecieve += bytesRecieve;
    var total = totalBytesRecieve.toFloat();
    var resId = null;

    if (total >= 1073741824) {
      // 1024 * 1024 * 1024
      total = total / 1073741824.0;
      resId = Rez.Strings.downloadUnitGB;
    } else if (total >= 1048576) {
      // 1024 * 1024
      total = total / 1048576.0;
      resId = Rez.Strings.downloadUnitMB;
    } else if (total >= 1024) {
      total = total / 1024.0;
      resId = Rez.Strings.downloadUnitKB;
    } else {
      resId = Rez.Strings.downloadUnitB;
    }

    // .format("%.2f") ограничивает вывод двумя знаками после запятой
    return total.format("%.2f") + " " + Application.loadResource(resId);
  }

  // **************************************************************************
  function downloadReport(bytesRecieve) {
    if (bytesRecieve == null) {
      return;
    }
    if (lastMomentMeasurement == null) {
      lastMomentMeasurement = Time.now();
      lastBytesRecieve = bytesRecieve;
    } else {
      var now = Time.now();
      var seconds = now.subtract(lastMomentMeasurement).value();
      if (seconds >= 30) {
        var bytes = bytesRecieve - lastBytesRecieve;
        if (bytes < 0) {
          bytes = bytesRecieve;
        }
        var captionSpeed =
          Application.loadResource(Rez.Strings.downloadSpeed) + ": ";
        var captionTotal =
          Application.loadResource(Rez.Strings.downloadTotal) + ": ";

        logger.info(
          captionSpeed +
            calculateDownloadingSpeed(seconds, bytes) +
            "   " +
            captionTotal +
            calculateTotalDownload(bytesRecieve)
        );
        lastMomentMeasurement = now;
        lastBytesRecieve = bytesRecieve;
      }
    }
  }

  // **************************************************************************
  function notifySyncProgress(bytesRecieve, byteSize) {
    downloadReport(bytesRecieve);

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
    logger.debug("Start downloading media files");

    var savedToken = JWTools.getToken();
    if (savedToken == null) {
      var authorisationProcessor = new BooksAuthorisationAPI(
        self.method(:onAuthorisation)
      );
      authorisationProcessor.start();
    } else {
      onAuthorisation(savedToken);
    }
  }

  // **************************************************************************
  function onAuthorisation(token) {
    self.token = token;
    if (token == null or token.equals("")) {
      var message =
        Application.loadResource(Rez.Strings.notSet) +
        " " +
        Application.loadResource(Rez.Strings.token);
      logger.finalizeLogging();
      Communications.notifySyncComplete(message);
      return;
    }

    if (filesList.size() > 0) {
      downloadedNumbers = 0;
      startLoadingFile(0);
    } else {
      booksStorage.checkBooksDownloadComplete();
      logger.finalizeLogging();
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

    WebRequest.makeWebRequest(url, {}, options, self.method(:onGettingFile));
  }

  // **************************************************************************
  function onGettingFile(code, data, context) {
    var fileIndex = context[FILE_INDEX];
    if (code == 200) {
      var filename = filesList[fileIndex][BooksStore.FILE_NAME];
      logger.info("The file has been downloaded: " + filename);
      booksStorage.onFileDownload(filesList[fileIndex], data.getId());
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
      logger.finalizeLogging();
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
    } else if (fileExtension.equals("m4a") or fileExtension.equals("m4b")) {
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
