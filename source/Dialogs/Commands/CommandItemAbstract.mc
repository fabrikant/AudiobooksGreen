import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandItemAbstract extends WatchUi.IconMenuItem {
  var ownerItemWeak = null;

  //*****************************************************************************
  function initialize(label, subLabel, id, bitmapRez, ownerItemWeak) {
    self.ownerItemWeak = ownerItemWeak;
    var drawable = new MenuItemDrawable(bitmapRez);
    IconMenuItem.initialize(label, subLabel, id, drawable, {});
  }

  //*****************************************************************************
  function onSelectItem() {
    command();
  }

  //*****************************************************************************
  function command() {}

  //*****************************************************************************
  function onMenuUpdate() {}
}
