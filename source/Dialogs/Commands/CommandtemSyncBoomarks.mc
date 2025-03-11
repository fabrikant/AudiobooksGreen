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
    // BookmarksGUI.startSync();
  }
}
