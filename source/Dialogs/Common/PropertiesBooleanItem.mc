import Toybox.WatchUi;
import Toybox.Application;

class PropertiesBooleanItem extends WatchUi.ToggleMenuItem {
  
  var callback = null;

  function initialize(label, id, callback) {
    self.callback = callback;
    var enabled = Application.Properties.getValue(id);
    ToggleMenuItem.initialize(label, "", id, enabled, {});
  }

  function onSelectItem() {
    Application.Properties.setValue(getId(), isEnabled());
    if (callback instanceof Toybox.Lang.Method){
      callback.invoke(getId(), isEnabled());
    }
  }
}
