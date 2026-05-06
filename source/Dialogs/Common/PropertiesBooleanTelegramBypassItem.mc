import Toybox.WatchUi;
import Toybox.Application;

class PropertiesBooleanTelegramBypassItem extends PropertiesBooleanItem {
  function initialize(label, id, callback) {
    PropertiesBooleanItem.initialize(label, id, callback);
    setSubLabel({
      :enabled => Rez.Strings.useProxyForTelegramTrue,
      :disabled => Rez.Strings.useProxyForTelegramFalse,
    });
  }
}
