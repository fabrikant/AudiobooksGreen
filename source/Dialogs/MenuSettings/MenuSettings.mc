import Toybox.Graphics;
import Toybox.WatchUi;

class MenuSettings extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.menuSettings,
      :theme => Style.getMenuTheme(),
    });

    addItem(new CommandItemMenuAuthorisation());

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.autosyncWhileCharging,
        "autosyncWhileCharging",
        null
      )
    );

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.autosyncProgress,
        "autosyncProgress",
        null
      )
    );

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.preferProxyRequests,
        "preferProxyRequests",
        null
      )
    );

    if (tgApiKey != null and !tgApiKey.equals("")) {
      addItem(new CommandMenuDebug());
    }

    // Прочие настройки
    if (Toybox.Graphics has :createBufferedBitmap) {
      addItem(new CommandItemMenuColors());
    }
    if (Toybox has :Complications) {
      addItem(new CommandItemMenuComplications());
    }
  }
}
