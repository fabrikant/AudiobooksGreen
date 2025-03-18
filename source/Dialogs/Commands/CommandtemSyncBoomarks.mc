import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemSyncBoomarks extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
      Rez.Strings.startBookmarksSync,
      null,
      null,
      Rez.Drawables.syncBluetooth,
      null
    );
  }

  function command() {
    var error = getAuthorizationProprtiesError();
    if (error != null) {
      WatchUi.pushView(new InfoView(error), null, WatchUi.SLIDE_IMMEDIATE);
      return;
    }

    // Показываем прогрессбар, чтобы пользователю было
    // не так скучно ждать авторизацию и получение папок
    WatchUi.pushView(
      new WatchUi.ProgressBar(
        Application.loadResource(Rez.Strings.progressMessageSyncBookmarks),
        null
      ),
      null,
      WatchUi.SLIDE_IMMEDIATE
    );

    var booksStorage = new BooksStore();
    var syncAgent = new ProgressAPI(self.method(:onSync), booksStorage);
    syncAgent.start();
  }

  function onSync(booksStorage) {
    //Закрываем прогрессбар
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
