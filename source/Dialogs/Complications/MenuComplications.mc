import Toybox.Graphics;
import Toybox.WatchUi;

class MenuComplications extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.complications,
      :theme => Style.getMenuTheme(),
    });

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.translitComplications,
        "translitComplications",
        null
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.lenghtComplications,
        Application.Properties.getValue(LENGHT_COMPLICATIONS),
        LENGHT_COMPLICATIONS,
        null
      )
    );
  }
}
