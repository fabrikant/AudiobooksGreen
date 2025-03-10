import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemLogout extends CommandtemAbstract {
  function initialize() {
    CommandtemAbstract.initialize(
      Rez.Strings.logout,
      null,
      null,
      Rez.Drawables.logout,
      null
    );
    setNewSubLabel();
  }

  function notSetString() {
    return "<<not set>>";
  }

  function setNewSubLabel() {
    var sublabel = Application.Storage.getValue(SID);
    if (sublabel == null) {
      sublabel = notSetString();
    }
    setSubLabel(sublabel);
  }

  function onMenuUpdate() {
    setNewSubLabel();
  }

  function command() {
    BooksExtraModule.removeAuthorization(null, null);
    setSubLabel(notSetString());
  }
}
