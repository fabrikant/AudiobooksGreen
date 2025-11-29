import Toybox.Media;
import Toybox.Graphics;
import Toybox.Application;

module Style {
  const coverOffset = 5;

  function getMenuTheme() {
    return Application.Properties.getValue("MENU_THEME");
  }

  function getFonts() {
    return {
      :font => Graphics.FONT_TINY,
      :fontAuthor => Graphics.FONT_TINY,
      :fontExtra => Graphics.FONT_XTINY,
    };
  }

  function coverSize() {
    var fonts = getFonts();
    return (
      2 * Graphics.getFontHeight(fonts[:font]) +
      Graphics.getFontDescent(fonts[:font]) +
      Graphics.getFontHeight(fonts[:fontAuthor]) -
      2 * coverOffset
    );
  }
}

class AbooksColors extends Media.PlayerColors {
  var menuItemBackgroundColor = null;
  var menuBackgroundColor = null;

  function initialize() {
    backgroundColor = Application.Properties.getValue("backgroundColor");
    //Активаня кнопка в карусели
    highlightFillColor = Application.Properties.getValue("highlightFillColor");
    textColor = Application.Properties.getValue("textColor");
    // Кнопка плей и закраска полосок возле кнопок
    foregroundColor = Application.Properties.getValue("foregroundColor");
    //Похоже это маленкие рисочки вокруг экрана
    highlightBorderColor = Application.Properties.getValue(
      "highlightBorderColor"
    );
    progressBarBackgroundColor = Application.Properties.getValue(
      "progressBarBackgroundColor"
    );
    progressBarForegroundColor = Application.Properties.getValue(
      "progressBarForegroundColor"
    );

    menuItemBackgroundColor = Application.Properties.getValue(
      "menuItemBackgroundColor"
    );
    menuBackgroundColor = Application.Properties.getValue(
      "menuBackgroundColor"
    );
  }

  function setDefaultColors() {
    var backgroundColor = 0x000000;
    Application.Properties.setValue("backgroundColor", backgroundColor);
    Application.Properties.setValue(
      "highlightFillColor",
      0x00AA00
    );
    Application.Properties.setValue("textColor", 0xFFFFFF);
    Application.Properties.setValue("foregroundColor", 0x00AA00);
    Application.Properties.setValue(
      "highlightBorderColor",
      0x00AA00
    );
    Application.Properties.setValue(
      "progressBarBackgroundColor",
      0xFFFFFF
    );
    Application.Properties.setValue(
      "progressBarForegroundColor",
      0xFFFFFF
    );
    Application.Properties.setValue("menuItemBackgroundColor", backgroundColor);
    Application.Properties.setValue("menuBackgroundColor", backgroundColor);
  }
}
