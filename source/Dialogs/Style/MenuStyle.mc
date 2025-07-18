import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;

class MenuStyle extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.style,
      :theme => Style.getMenuTheme(),
    });

    addItem(
      new PropertiesBooleanItem(
        Rez.Strings.defaultPlayerColors,
        "defaultPlayerColors"
      )
    );

    var devSettings = System.getDeviceSettings();
    if (devSettings.requiresBurnInProtection){
      addItem(new CommandItemMenuTheme());  
    }

    addItem(new ItemPropertyColor("textColor", Rez.Strings.textColor));
    addItem(
      new ItemPropertyColor(
        "menuBackgroundColor",
        Rez.Strings.menuBackgroundColor
      )
    );
    addItem(
      new ItemPropertyColor(
        "menuItemBackgroundColor",
        Rez.Strings.menuItemBackgroundColor
      )
    );
    addItem(
      new ItemPropertyColor("backgroundColor", Rez.Strings.backgroundColor)
    );

    addItem(
      new ItemPropertyColor(
        "highlightFillColor",
        Rez.Strings.highlightFillColor
      )
    );
    addItem(
      new ItemPropertyColor("foregroundColor", Rez.Strings.foregroundColor)
    );
    addItem(
      new ItemPropertyColor(
        "highlightBorderColor",
        Rez.Strings.highlightBorderColor
      )
    );
    addItem(
      new ItemPropertyColor(
        "progressBarBackgroundColor",
        Rez.Strings.progressBarBackgroundColor
      )
    );
    addItem(
      new ItemPropertyColor(
        "progressBarForegroundColor",
        Rez.Strings.progressBarForegroundColor
      )
    );

    addItem(new CommandItemSetDefaultColors());
  }
}
