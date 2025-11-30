import Toybox.Graphics;
import Toybox.WatchUi;

class MenuExtraSettings extends WatchUi.Menu2 {
  function initialize() {
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
      addItem(
        new PropertiesBooleanItem(
          Rez.Strings.telegramDebug,
          "telegramDebug",
          logger.method(:reloadSettings)
        )
      );

      addItem(
        new PickerItem(
          Rez.Strings.telegramChatId,
          Application.Properties.getValue("telegramChatId"),
          "telegramChatId",
          logger.method(:reloadSettings)
        )
      );

      addItem(new LogLevelPicker());
    }
  }
}
