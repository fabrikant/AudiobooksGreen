import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemSync extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
      Rez.Strings.startSync,
      null,
      null,
      Rez.Drawables.syncWifi,
      null
    );
  }

  function command() {
    if (Communications has :startSync2) {
      Communications.startSync2({
        :message => Application.Properties.getValue(SERVER),
      });
    } else {
      Communications.startSync();
    }
  }
}
