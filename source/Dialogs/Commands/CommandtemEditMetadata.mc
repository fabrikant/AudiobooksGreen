import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemEditMetadata extends CommandtemAbstract {
  function initialize(ownerItemWeak) {
    CommandtemAbstract.initialize(
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
