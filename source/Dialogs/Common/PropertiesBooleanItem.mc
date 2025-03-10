import Toybox.WatchUi;
import Toybox.Application;

class PropertiesBooleanItem extends WatchUi.ToggleMenuItem {
  var ownerItemWeak = null;

  function initialize(label, id) {
    var enabled = Application.Properties.getValue(id);
    ToggleMenuItem.initialize(label, "", id, enabled, {});
  }

  function onSelectItem() {
    Application.Properties.setValue(getId(), isEnabled());
  }
}
