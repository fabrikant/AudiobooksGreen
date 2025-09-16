import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

class MenuLogLevels extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.logLevel,
      :theme => Style.getMenuTheme(),
    });
    addItem(
      new WatchUi.MenuItem(Rez.Strings.SILENCE, null, logger.SILENCE, null)
    );
    addItem(new WatchUi.MenuItem(Rez.Strings.ERROR, null, logger.ERROR, null));
    addItem(
      new WatchUi.MenuItem(Rez.Strings.WARNING, null, logger.WARNING, null)
    );
    addItem(new WatchUi.MenuItem(Rez.Strings.INFO, null, logger.INFO, null));
    addItem(new WatchUi.MenuItem(Rez.Strings.DEBUG, null, logger.DEBUG, null));

    var value = Application.Properties.getValue("logLevel");
    var index = findItemById(value);
    if (index >= 0) {
      setFocus(index);
    }
  }
}

class MenuLogLevelDelegate extends WatchUi.Menu2InputDelegate {
  var ownerWeak = null;

  function initialize(ownerWeak) {
    self.ownerWeak = ownerWeak;
    Menu2InputDelegate.initialize();
  }

  function onSelect(item) {
    System.println(item.getId());
    Application.Properties.setValue("logLevel", item.getId());
    logger.reloadSettings(null, null);
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    if (ownerWeak.stillAlive()) {
      var owner = ownerWeak.get();
      owner.setNewSublabel();
    }
  }
}

class LogLevelPicker extends WatchUi.MenuItem {
  function initialize() {
    var val = Application.Properties.getValue("logLevel");
    var subLabel = subLabelByValue(val);
    MenuItem.initialize(Rez.Strings.logLevel, subLabel, null, null);
  }

  private function subLabelByValue(val) {
    var subLabel = Rez.Strings.SILENCE;
    if (val == logger.ERROR) {
      subLabel = Rez.Strings.ERROR;
    } else if (val == logger.WARNING) {
      subLabel = Rez.Strings.WARNING;
    } else if (val == logger.INFO) {
      subLabel = Rez.Strings.INFO;
    } else if (val == logger.DEBUG) {
      subLabel = Rez.Strings.DEBUG;
    }
    return subLabel;
  }

  function setNewSublabel() {
    var val = Application.Properties.getValue("logLevel");
    setSubLabel(subLabelByValue(val));
    logger.reloadSettings("logLevel", val);
  }

  function onSelectItem() {
    var menu = new MenuLogLevels();
    var deleg = new MenuLogLevelDelegate(weak());
    WatchUi.pushView(menu, deleg, WatchUi.SLIDE_IMMEDIATE);
  }
}
