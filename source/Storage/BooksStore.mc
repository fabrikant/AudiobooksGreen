import Toybox.Application;
import Toybox.Media;
import Toybox.Lang;
import Toybox.Time;

class BooksStore {
  enum {
    BOOKS_ON_DEVICE = "books",
    CURRENT_BOOK = "current",
    PLAYLIST = "playlist",
    BOOK_ID = "book_id",
    BOOK_TITLE = "title",
    BOOK_AUTHOR = "author",
    BOOK_DOWNLOADED = "downloaded",
    BOOK_COVER_URL = "cover_url",
    BOOK_COVER_CONTENT_ID = "cover",
    FILE_NAME = "filename",
    FILE_ID = "fileId",
    FILE_CONTENT_ID = "contentId",
    DURATION = "duration",
    BOOKMARK = "bookmark",
    URL_SUBSCRIPTION = "subscr",
  }

  var booksOnDevice = null;

  // **************************************************************************
  function initialize() {
    booksOnDevice = Application.Storage.getValue(BOOKS_ON_DEVICE);
    if (booksOnDevice == null) {
      booksOnDevice = {};
    }
  }

  // **************************************************************************
  //Формирует идентификатор для хранения обложки в Storage
  function getCoverKey(bookId) {
    return BOOK_COVER_CONTENT_ID + bookId;
  }

  // **************************************************************************
  // Возвращает массив ТОЛЬКО c id книг, которые нужно грузить
  function getIdsToDownload() {
    var keys = booksOnDevice.keys();
    var result = [];
    for (var i = 0; i < keys.size(); i++) {
      if (!booksOnDevice[keys[i]][BOOK_DOWNLOADED]) {
        result.add(keys[i]);
      }
    }
    return result;
  }

  // **************************************************************************
  // Возвращает массив словарей c id книг, и ФАЙЛОВ которые нужно грузить
  function getFilesToDownload() {
    var result = [];
    var bookIds = getIdsToDownload();
    for (var i = 0; i < bookIds.size(); i++) {
      var currentFileList = Application.Storage.getValue(bookIds[i]);
      // Добавляем в список файлов информацию о том, с какого url качать
      // Подписка или басплатный (купленный контент)
      var subscr = booksOnDevice[bookIds[i]][URL_SUBSCRIPTION];
      if (subscr == null) {
        subscr = true;
      }
      if (currentFileList != null) {
        for (var j = 0; j < currentFileList.size(); j++) {
          if (currentFileList[j][FILE_CONTENT_ID] == null) {
            var item = {
              BOOK_ID => bookIds[i],
              FILE_ID => currentFileList[j][FILE_ID],
              FILE_NAME => currentFileList[j][FILE_NAME],
              URL_SUBSCRIPTION => subscr,
            };
            result.add(item);
            logger.debug("Добавлен файл для загрузки: " + item);
          }
        }
      }
    }
    return result;
  }

  // **************************************************************************
  // Добавляет информацию о книге в хранилище
  function addBookIfNotExist(bookInfo) {
    var bookId = bookInfo[BOOK_ID];
    if (booksOnDevice[bookId] == null) {
      booksOnDevice[bookId] = { BOOK_DOWNLOADED => false };
      var keys = bookInfo.keys();
      for (var i = 0; i < keys.size(); i++) {
        booksOnDevice[bookId][keys[i]] = bookInfo[keys[i]];
      }
      Application.Storage.setValue(BOOKS_ON_DEVICE, booksOnDevice);
      logger.debug("Сохранена информация о книге: " + booksOnDevice[bookId]);
    }
  }

  // **************************************************************************
  // Добавляет информацию о книгах по полученному массиву
  function addNewBooks(booksList) {
    for (var i = 0; i < booksList.size(); i++) {
      addBookIfNotExist(booksList[i]);
    }
  }

  // **************************************************************************
  // Удаляет книги с идентификаторами, которых НЕТ в переданном списке
  // Т.е. получаем актуальные данные с сайта о том какие книги сейчас
  // содержатся в плейлисте. И удаляем с устройства все книги, которых
  // там нет.
  function removeOldBooks(booksList) {
    //Список на сайте
    var idsForSave = [];
    for (var i = 0; i < booksList.size(); i++) {
      idsForSave.add(booksList[i][BOOK_ID]);
    }

    // Список на устройстве
    var idsOnDevice = booksOnDevice.keys();

    // Список для удаления
    var idsToRemove = [];
    for (var i = 0; i < idsOnDevice.size(); i++) {
      if (idsForSave.indexOf(idsOnDevice[i]) < 0) {
        idsToRemove.add(idsOnDevice[i]);
      }
    }

    // Удаляем книги с устройства
    for (var i = 0; i < idsToRemove.size(); i++) {
      var idToRemove = idsToRemove[i];
      removeBook(idToRemove);
    }
    removeInvalidContent();
  }

  // **************************************************************************
  // Удаляем книгу
  function removeBook(idToRemove) {
    logger.debug("Начало удаления книги: " + booksOnDevice[idToRemove]);

    // Удаляем книгу из плейлиста
    removeFromPlaylist(idToRemove);

    // Удаляем закладку
    Application.Storage.deleteValue(BOOKMARK + idToRemove);

    // Возможно данная книга отмечена текущей прослушиваемой
    // если это так, удаляем ссылку
    var currentBookId = Application.Storage.getValue(CURRENT_BOOK);
    if (currentBookId == idToRemove) {
      Application.Storage.deleteValue(CURRENT_BOOK);
    }

    var files = Application.Storage.getValue(idToRemove);
    if (files != null) {
      // Удяляем скачанный контент
      for (var j = 0; j < files.size(); j++) {
        if (files[j][FILE_CONTENT_ID] != null) {
          var contentRef = new Media.ContentRef(
            files[j][FILE_CONTENT_ID],
            Media.CONTENT_TYPE_AUDIO
          );
          Media.deleteCachedItem(contentRef);
          logger.debug("Удален скачанный контент: " + files[j]);
        }
      }

      // Удяляем список файлов книги
      Application.Storage.deleteValue(idToRemove);
      logger.debug("Удален список файлов: " + idToRemove);
    }

    // Удаляем обложку
    var coverKey = getCoverKey(idToRemove);
    Application.Storage.deleteValue(coverKey);
    logger.debug("Удалена обложка: " + coverKey);

    // Удаляем из списка книг
    if (booksOnDevice[idToRemove] != null) {
      booksOnDevice.remove(idToRemove);
      Application.Storage.setValue(BOOKS_ON_DEVICE, booksOnDevice);
      logger.debug("Удалена информация о книге: " + idToRemove);
    }
  }

  // **************************************************************************
  // Удаляем мусор
  // Удаляем весь контент, который не привязан ни к какой книге
  function removeInvalidContent() {
    // Удаление поврежденного контента
    var iterator = Media.getContentRefIter({
      :contentType => Media.CONTENT_TYPE_INVALID,
      :shuffle => false,
    });
    if (iterator != null) {
      var ref = iterator.next();
      while (ref != null) {
        var id = ref.getId();
        Media.deleteCachedItem(ref);
        logger.debug("Удален поврежденный фрагмент id:" + id);
        ref = iterator.next();
      }
    }

    var validFiles = [];
    var bookKeys = booksOnDevice.keys();

    // Получаем идентификаторы контента, которые
    // связаны с книгами
    for (var i = 0; i < bookKeys.size(); i++) {
      var bookId = bookKeys[i];
      var files = Application.Storage.getValue(bookId);
      if (files instanceof Lang.Array and files.size() > 0) {
        for (var j = 0; j < files.size(); j++) {
          if (files[j][FILE_CONTENT_ID] != null) {
            validFiles.add(files[j][FILE_CONTENT_ID]);
          }
        }
      }
    }

    // Перебираем все идентификаторы контента и удаляем
    // контент, который не привязан ни к одной книге
    // Такого быть не должно, но на всякий случай.
    if (validFiles.size() > 0) {
      iterator = Media.getContentRefIter({
        :contentType => Media.CONTENT_TYPE_AUDIO,
        :shuffle => false,
      });
      if (iterator != null) {
        var ref = iterator.next();
        while (ref != null) {
          var id = ref.getId();
          if (validFiles.indexOf(id) < 0) {
            Media.deleteCachedItem(ref);
            logger.debug("Удален файл не присоединенный к книге id:" + id);
          }
          ref = iterator.next();
        }
      }
    }
  }

  // **************************************************************************
  function addFilesList(bookId, filesList) {
    var files = Application.Storage.getValue(bookId);
    if (files == null and filesList instanceof Lang.Array) {
      Application.Storage.setValue(bookId, filesList);
    }
  }

  // **************************************************************************
  function getFileList(bookId) {
    return Application.Storage.getValue(bookId);
  }

  // **************************************************************************
  function fileIsDownloaded(bookId, fileInfo) {
    var result = false;
    var files = Application.Storage.getValue(bookId);

    for (var i = 0; i < files.size(); i++) {
      if (files[i][FILE_ID].equals(fileInfo[FILE_ID])) {
        result = files[i][FILE_CONTENT_ID] != null;
        break;
      }
    }
    return result;
  }

  // **************************************************************************
  function onFileDownload(fileInfo, contentId) {
    var bookId = fileInfo[BOOK_ID];
    var files = Application.Storage.getValue(bookId);
    for (var i = 0; i < files.size(); i++) {
      if (files[i][FILE_ID].equals(fileInfo[FILE_ID])) {
        files[i][FILE_CONTENT_ID] = contentId;
        Application.Storage.setValue(bookId, files);
        logger.debug("Записана информация о скачаном файле: " + files[i]);
        return;
      }
    }
  }

  // **************************************************************************
  function checkBooksDownloadComplete() {
    logger.debug("Начало проверки книг по окончанию загрузки файлов");
    var keys = booksOnDevice.keys();
    for (var j = 0; j < keys.size(); j++) {
      var bookDuration = 0;
      var bookId = keys[j];
      var bookInfo = booksOnDevice[bookId];
      var bookDescr = bookInfo[BOOK_TITLE] + " (" + bookId + ")";
      if (
        bookInfo[BOOK_DOWNLOADED] == null or
        bookInfo[BOOK_DOWNLOADED] == false
      ) {
        logger.debug("Проверка книги: " + bookDescr);

        var complete = true;
        var files = Application.Storage.getValue(bookId);
        if (files instanceof Lang.Array and files.size() > 0) {
          for (var i = 0; i < files.size(); i++) {
            bookDuration += files[i][DURATION];
            if (files[i][FILE_CONTENT_ID] == null) {
              logger.debug(
                "Обнаружен не загруженный файл: " + files[i][FILE_NAME]
              );
              complete = false;
              break;
            }
          }
        } else {
          logger.debug("Нет сведений о файлах");
          complete = false;
        }

        if (complete) {
          booksOnDevice[bookId][BOOK_DOWNLOADED] = true;
          booksOnDevice[bookId][DURATION] = bookDuration;
          logger.info("Книга помечена как загруженная: " + bookDescr);
        }
      } else {
        logger.debug("Книга загружена ранее: " + bookDescr);
      }
    }
    Application.Storage.setValue(BOOKS_ON_DEVICE, booksOnDevice);
  }

  // **************************************************************************
  function addToPlaylist(bookId) {
    var playlist = Application.Storage.getValue(PLAYLIST);
    if (playlist == null) {
      playlist = [bookId];
      logger.debug("Создан плейлист с книгой: " + bookId);
    } else {
      if (playlist.indexOf(bookId) < 0) {
        playlist.add(bookId);
        logger.debug("В плейлист добавлена книга: " + bookId);
      }
    }
    Application.Storage.setValue(PLAYLIST, playlist);
  }

  // **************************************************************************
  function removeFromPlaylist(bookId) {
    var playlist = Application.Storage.getValue(PLAYLIST);
    if (playlist instanceof Lang.Array) {
      playlist.removeAll(bookId);
      logger.debug("Из плейлиста удалена книга: " + bookId);
    }
    Application.Storage.setValue(PLAYLIST, playlist);
  }

  // **************************************************************************
  function getPlaylistFiles() {
    var result = [];
    var playlist = Application.Storage.getValue(PLAYLIST);

    if (playlist instanceof Lang.Array) {
      for (var i = 0; i < playlist.size(); i++) {
        var bookId = playlist[i];
        var files = Application.Storage.getValue(bookId);

        if (files instanceof Lang.Array) {
          for (var j = 0; j < files.size(); j++) {
            var file = files[j];
            var newFile = {
              BOOK_ID => bookId,
              FILE_NAME => file[FILE_NAME],
              FILE_CONTENT_ID => file[FILE_CONTENT_ID],
            };

            result.add(newFile);
          }
        }
      }
    }
    return result;
  }

  // **************************************************************************
  function prettyDuration(seconds) {
    var result = "";

    var remain = seconds;
    var hours = remain / Time.Gregorian.SECONDS_PER_HOUR;

    remain %= Time.Gregorian.SECONDS_PER_HOUR;
    var min = remain / Time.Gregorian.SECONDS_PER_MINUTE;

    remain %= Time.Gregorian.SECONDS_PER_MINUTE;
    var sec = remain % Time.Gregorian.SECONDS_PER_MINUTE;

    if (hours > 0) {
      result = Lang.format("$1$$2$ $3$$4$", [
        hours.format("%02d"),
        Application.loadResource(Rez.Strings.hours),
        min.format("%02d"),
        Application.loadResource(Rez.Strings.minutes),
      ]);
    } else {
      result = Lang.format("$1$$2$ $3$$4$", [
        min.format("%02d"),
        Application.loadResource(Rez.Strings.minutes),
        sec.format("%02d"),
        Application.loadResource(Rez.Strings.seconds),
      ]);
    }

    return result;
  }

  // **************************************************************************
  // [ИндексВМассивеФайловКниги, ПозицияВСекундах, UnixTimeСозданияЗакладки]
  function saveBookmark(bookId, bookmarkItem) {
    var storageId = BOOKMARK + bookId;
    var old_bookmark = Application.Storage.getValue(storageId);
    if (
      old_bookmark == null or
      old_bookmark[0] != bookmarkItem[0] or
      old_bookmark[1] != bookmarkItem[1]
    ) {
      // Записываем только при изменении
      logger.debug(
        "Записана закладка bookId: " + bookId + " - " + bookmarkItem
      );
      Application.Storage.setValue(storageId, bookmarkItem);
    }
  }

  // **************************************************************************
  function getBookmark(bookId) {
    return Application.Storage.getValue(BOOKMARK + bookId);
  }

  // **************************************************************************
  // Сохраняется как массив
  // [ИндексВМассивеФайловКниги, ПозицияВСекундах, UnixTimeСозданияЗакладки]
  function createPlayerBookmark(fileInfo, position) {
    var bookId = fileInfo[BOOK_ID];
    var contentId = fileInfo[FILE_CONTENT_ID];
    // var fileIndex = null;
    var files = Application.Storage.getValue(bookId);
    if (files instanceof Lang.Array) {
      for (var i = 0; i < files.size(); i++) {
        if (files[i][FILE_CONTENT_ID] == contentId) {
          var now = Time.now();
          var newBookmark = [i, position, now.value()];
          BooksStore.saveBookmark(bookId, newBookmark);
        }
      }
    }
  }

  // **************************************************************************
  function updateCurrentBook(bookId) {
    var currentBookId = Application.Storage.getValue(CURRENT_BOOK);
    if (currentBookId != bookId) {
      logger.debug("Установлена текущая книга: " + bookId);
      Application.Storage.setValue(CURRENT_BOOK, bookId);
    }
  }
}
