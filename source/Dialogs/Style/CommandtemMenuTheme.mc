import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Application;

class CommandtemMenuTheme extends CommandtemAbstract {
  function initialize() {
    var value = Application.Properties.getValue("MENU_THEME");
    var sublabel = getSublabel(value);

    CommandtemAbstract.initialize(
      Rez.Strings.MENU_THEME,
      sublabel,
      null,
      Rez.Drawables.list,
      null
    );
  }

  function getSublabel(value) {
    if (value == WatchUi.MENU_THEME_DEFAULT) {
      return Rez.Strings.MENU_THEME_DEFAULT;
    } else if (value == WatchUi.MENU_THEME_BLUE) {
      return Rez.Strings.MENU_THEME_BLUE;
    } else if (value == WatchUi.MENU_THEME_CYAN) {
      return Rez.Strings.MENU_THEME_CYAN;
    } else if (value == WatchUi.MENU_THEME_GREEN) {
      return Rez.Strings.MENU_THEME_GREEN;
    } else if (value == WatchUi.MENU_THEME_YELLOW) {
      return Rez.Strings.MENU_THEME_YELLOW;
    } else if (value == WatchUi.MENU_THEME_ORANGE) {
      return Rez.Strings.MENU_THEME_ORANGE;
    } else if (value == WatchUi.MENU_THEME_RED) {
      return Rez.Strings.MENU_THEME_RED;
    } else if (value == WatchUi.MENU_THEME_PINK) {
      return Rez.Strings.MENU_THEME_PINK;
    } else if (value == WatchUi.MENU_THEME_PURPLE) {
      return Rez.Strings.MENU_THEME_PURPLE;
    } else if (value == WatchUi.MENU_THEME_GREEN_YELLOW) {
      return Rez.Strings.MENU_THEME_GREEN_YELLOW;
    }
    return Rez.Strings.MENU_THEME_DEFAULT;
  }

  function command() {
    WatchUi.pushView(
      new MenuTheme(weak()),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
