import Toybox.Graphics;
import Toybox.WatchUi;

class MenuDebug extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.menuDebug,
      :theme => Style.getMenuTheme(),
    });

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
