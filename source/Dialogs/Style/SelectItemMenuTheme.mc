import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class SelectItemMenuTheme extends WatchUi.MenuItem {
  var ownerItemWeak = null;

  //*****************************************************************************
  function initialize(ownerItemWeak, label, id) {
    self.ownerItemWeak = ownerItemWeak;
    MenuItem.initialize(label, null, id, {});
  }

  //*****************************************************************************
  function onSelectItem() {
    Application.Properties.setValue("MENU_THEME", getId());
    var ownerItem = null;
    if (ownerItemWeak != null and ownerItemWeak.stillAlive()) {
      ownerItem = ownerItemWeak.get();
      ownerItem.setSubLabel(getLabel());
    }
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
