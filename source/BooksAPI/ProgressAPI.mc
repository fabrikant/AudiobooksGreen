class ProgressAPI extends BooksAPI {
  var finalCallback = null;
  var booksStorage = null;

  //***************************************************************************
  function initialize(finalCallback, booksStorage) {
    self.finalCallback = finalCallback;
    self.booksStorage = booksStorage;
    BooksAPI.initialize();
  }

  //***************************************************************************
  function start() {
    logger.debug("Синхронизация прогресса не реализована");
    finalCallback.invoke(booksStorage);
  }
}
