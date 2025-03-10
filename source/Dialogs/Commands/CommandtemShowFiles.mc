import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemShowFiles extends CommandtemAbstract {
  function initialize(ownerItemWeak) {
    CommandtemAbstract.initialize(
      Rez.Strings.showFiles,
      null,
      null,
      Rez.Drawables.showFiles,
      ownerItemWeak
    );
  }

  function command() {
    var bookId = null;
    var ownerItem = null;

    if (ownerItemWeak != null and ownerItemWeak.stillAlive()) {
      ownerItem = ownerItemWeak.get();
      bookId = ownerItem.getId();
    }

    if (bookId != null) {
      var files = Application.Storage.getValue(bookId);
      if (files instanceof Lang.Array and files.size() > 0) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.pushView(
          new FilesMenu(ownerItemWeak),
          new SimpleMenuDelegate(),
          WatchUi.SLIDE_IMMEDIATE
        );
        return;
      }
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
