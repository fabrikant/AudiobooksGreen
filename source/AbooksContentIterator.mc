import Toybox.Lang;
import Toybox.Media;
import Toybox.Complications;
import Toybox.Application;

class AbooksContentIterator extends Media.ContentIterator {
  var books = null;
  var files = null;
  var currenInd = null;
  var resumePosition = null;
  var bookmartUnixTime = null;

  // **************************************************************************
  // В качестве праметров может прийти
  // null - Автоматический запуск. Пробуем найти закладку для первой книги
  // в плейлисте, и если находим стартуем с закладки
  // Массив. Втрой член массива - СтартСЗакладки
  // [idBook, false] - нужно запустить книгу сначала
  // [idBook, true] - нужно поискать закладку и запустить с неё.
  // Если закладки нет, запускаем книгу сначала
  //
  // При этом подразумевается, что требуемые книги уже есть в плейлисте
  // об этом нужно позаботиться до того, как вызывать  Media.startPlayback()
  function initialize(params) {
    logger.debug("AbooksContentIterator(" + params + ")");
    ContentIterator.initialize();

    resumePosition = null;
    currenInd = 0;

    var booksStorage = new BooksStore();
    books = booksStorage.booksOnDevice;
    files = booksStorage.getPlaylistFiles();

    logger.debug("В плейлисте файлов: " + files.size());
    //В этом есть смысл, если плейлист не пустой
    if (!(files instanceof Lang.Array) or files.size() == 0) {
      return;
    }

    // По умолчанию принимем за нужную книгу - первую в списке
    // и считаем, что нужно продолжать с закладки по этой книге
    var bookIdForResume = files[currenInd][BooksStore.BOOK_ID];
    var needToBookmark = true;

    // Уточняем id книги возможно какая-то книга
    // сохранена в качестве текущей
    // Если она есть и в плейлисте, берем её
    var currentBookId = Application.Storage.getValue(BooksStore.CURRENT_BOOK);
    if (currentBookId != null) {
      // Нужно проверить, есть ли данная книга в плейлисте
      var playlist = Application.Storage.getValue(BooksStore.PLAYLIST);
      if (playlist instanceof Lang.Array) {
        if (playlist.indexOf(currentBookId) >= 0) {
          // Книга есть в плейлисте
          bookIdForResume = currentBookId;
        }
      }
    }

    // Уточняем id книги и нужность заклади
    if (params instanceof Lang.Array) {
      bookIdForResume = params[0];
      needToBookmark = params[1];
    }

    // Нам известен id книги с которой нужно начать.
    // Независимо от того, есть закладка для этой
    // книги или нет, сдвигаем текущий индекс на первый
    // файл книги
    for (var i = 0; i < files.size(); i++) {
      if (files[i][BooksStore.BOOK_ID] == bookIdForResume) {
        currenInd = i;
        logger.debug(
          "Установлен текущий индекс: " +
            currenInd +
            " для книги с id: " +
            bookIdForResume
        );
        break;
      }
    }

    // Мы на первом файле нужной книги
    // Проверяем нужно ли переходить на закладку
    // Переходим если нужно.
    if (needToBookmark) {
      var bookmark = booksStorage.getBookmark(bookIdForResume);

      if (bookmark instanceof Lang.Array) {
        // есть закладка для книги
        // сдвигаем текущий индекс
        // запоминаем позицию
        currenInd += bookmark[0];
        resumePosition = bookmark[1];
        bookmartUnixTime = bookmark[2];
      }
    }

    logger.debug(
      "currenInd=" + currenInd + "; resumePosition=" + resumePosition
    );
  }

  // **************************************************************************
  function getContent(ind, position) {
    logger.debug("Поиск контента по индексу: " + ind);
    if (ind >= files.size() or ind < 0) {
      logger.debug("Недопустимое значение индекса");
      return null;
    }
    var file = files[ind];

    var contRef = new Media.ContentRef(
      file[BooksStore.FILE_CONTENT_ID],
      Media.CONTENT_TYPE_AUDIO
    );

    var mediaContent = Media.getCachedContentObj(contRef);
    var metadata = mediaContent.getMetadata();

    // Если задана позиция, начинаем воспроизведение с неё
    if (position != null) {
      //Откат в зависимости от того, как давно на паузе.
      var positionOfset =
        ContentProcessor.calculatePositionOffset(bookmartUnixTime);
      position -= positionOfset;
      if (position < 0) {
        position = 0;
      }
      mediaContent = new Media.ActiveContent(contRef, metadata, position);
    }

    logger.debug("Обнаружен контент: " + metadata.album + " " + metadata.title);
    return mediaContent;
  }

  // **************************************************************************
  function fixIndex(ind) {
    if (ind < 0) {
      return 0;
    } else if (ind >= files.size()) {
      return files.size() - 1;
    } else {
      return ind;
    }
  }

  // **************************************************************************
  function setAlbumArt() {
    if (
      files instanceof Lang.Array and
      currenInd >= 0 and
      currenInd < files.size()
    ) {
      var bookId = files[currenInd][BooksStore.BOOK_ID];
      var coverId = BooksStore.getCoverKey(bookId);
      var bitmap = Application.Storage.getValue(coverId);
      if (bitmap != null) {
        Media.setAlbumArt(bitmap);
      }
    }
  }

  // **************************************************************************
  // Обновляем информацию о воспроизведении для других приложений
  function updateComplications(isPlaying) {
    if (isPlaying) {
      var bookId = files[currenInd][BooksStore.BOOK_ID];
      var bookInfo = books[bookId];

      var contRef = new Media.ContentRef(
        files[currenInd][BooksStore.FILE_CONTENT_ID],
        Media.CONTENT_TYPE_AUDIO
      );

      var mediaContent = Media.getCachedContentObj(contRef);
      var metadata = mediaContent.getMetadata();

      var title = metadata.album;
      var author = metadata.artist;
      var chapter = metadata.title;
      if (title.equals("")) {
        title = bookInfo[BooksStore.BOOK_TITLE];
      }
      if (author.equals("")) {
        author = bookInfo[BooksStore.BOOK_AUTHOR];
      }
      if (chapter.equals("")) {
        var filename = files[currenInd][BooksStore.FILE_NAME];
        chapter = filename.substring(0, filename.length() - 4);
      }

      if (Application.Properties.getValue("translitComplications")) {
        title = ContentProcessor.translitText(title);
        author = ContentProcessor.translitText(author);
        chapter = ContentProcessor.translitText(chapter);
      } else {
        // Сократим длину при необходимости
        var maxLenght = Application.Properties.getValue(LENGHT_COMPLICATIONS);
        if (maxLenght > 0) {
          title = title.substring(0, maxLenght);
          author = author.substring(0, maxLenght);
          chapter = chapter.substring(0, maxLenght);
        }
      }
      try {
        Complications.updateComplication(0, { :value => title });
        Complications.updateComplication(1, { :value => author });
        Complications.updateComplication(2, { :value => chapter });
      } catch (ex) {
        logger.warning("1. " + ex.getErrorMessage());
      }
    } else {
      try {
        // Воспроизведение остановлено
        Complications.updateComplication(0, { :value => null });
        Complications.updateComplication(1, { :value => null });
        Complications.updateComplication(2, { :value => null });
      } catch (ex) {
        logger.warning("2. " + ex.getErrorMessage());
      }
    }
  }

  // **************************************************************************
  function createPlayerBookmark(playbackPosition) {
    // Фиксируем закладку
    BooksStore.createPlayerBookmark(files[currenInd], playbackPosition);
    // Фиксируем id текущей воспроизводимой книги, чтобы
    // продолжить воспроизведение с неё
    BooksStore.updateCurrentBook(files[currenInd][BooksStore.BOOK_ID]);
  }

  // **************************************************************************
  // Determine if the the current track can be skipped.
  function canSkip() as Boolean {
    return true;
  }

  // **************************************************************************
  // Get the current media content playback profile
  function getPlaybackProfile() as PlaybackProfile? {
    return new AbooksPlaybackProfile();
  }

  // **************************************************************************
  // Get the current media content object.
  function get() as Content? {
    logger.debug("get(" + currenInd + ")");
    currenInd = fixIndex(currenInd);
    var content = getContent(currenInd, resumePosition);
    resumePosition = null;
    return content;
  }

  // **************************************************************************
  // Get the next media content object.
  function next() as Content? {
    logger.debug("next(" + currenInd + ")");
    currenInd = fixIndex(currenInd + 1);
    return getContent(currenInd, null);
  }

  // **************************************************************************
  // Get the previous media content object.
  function previous() as Content? {
    logger.debug("previous(" + currenInd + ")");
    currenInd = fixIndex(currenInd - 1);
    return getContent(currenInd, null);
  }

  // **************************************************************************
  // Get the next media content object without incrementing the iterator.
  function peekNext() as Content? {
    logger.debug("peekNext(" + currenInd + ")");
    return getContent(fixIndex(currenInd + 1), null);
  }

  // **************************************************************************
  // Get the previous media content object without decrementing the iterator.
  function peekPrevious() as Content? {
    logger.debug("peekPrevious(" + currenInd + ")");
    return getContent(fixIndex(currenInd - 1), null);
  }

  // **************************************************************************
  // Determine if playback is currently set to shuffle.
  function shuffling() as Boolean {
    return false;
  }
}
