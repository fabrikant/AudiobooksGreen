import Toybox.Graphics;
import Toybox.WatchUi;

class MenuExtraSettings extends WatchUi.Menu2 {
  function initialize() {

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.autosyncProgress,
        "autosyncProgress"
      )
    );
  }
}
