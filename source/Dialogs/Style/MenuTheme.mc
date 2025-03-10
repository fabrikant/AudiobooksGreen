import Toybox.Graphics;
import Toybox.WatchUi;

class MenuTheme extends WatchUi.Menu2 {
  function initialize(ownerItemWeak) {
    Menu2.initialize({
      :title => Rez.Strings.MENU_THEME,
      :theme => Style.getMenuTheme(),
    });

    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_DEFAULT,
        WatchUi.MENU_THEME_DEFAULT
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_BLUE,
        WatchUi.MENU_THEME_BLUE
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_CYAN,
        WatchUi.MENU_THEME_CYAN
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_GREEN,
        WatchUi.MENU_THEME_GREEN
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_YELLOW,
        WatchUi.MENU_THEME_YELLOW
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_ORANGE,
        WatchUi.MENU_THEME_ORANGE
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_RED,
        WatchUi.MENU_THEME_RED
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_PINK,
        WatchUi.MENU_THEME_PINK
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_PURPLE,
        WatchUi.MENU_THEME_PURPLE
      )
    );
    addItem(
      new SelectItemMenuTheme(
        ownerItemWeak,
        Rez.Strings.MENU_THEME_GREEN_YELLOW,
        WatchUi.MENU_THEME_GREEN_YELLOW
      )
    );

    var value = Application.Properties.getValue("MENU_THEME");
    var index = findItemById(value);
    if (index >= 0) {
      setFocus(index);
    }
  }
}
