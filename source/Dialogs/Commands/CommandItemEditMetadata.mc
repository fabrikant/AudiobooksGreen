import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemEditMetadata extends CommandItemAbstract {
  function initialize(ownerItemWeak) {
    CommandItemAbstract.initialize(
      Rez.Strings.editMetadata,
      null,
      null,
      Rez.Drawables.editMetadata,
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
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
      ContentProcessor.setMetadataFromBookDescription(bookId);
    }
  }
}
