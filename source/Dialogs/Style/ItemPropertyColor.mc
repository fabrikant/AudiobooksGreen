import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//*****************************************************************************

class ItemPropertyColor extends WatchUi.IconMenuItem {
  var color;

  function initialize(id, label) {
    color = Application.Properties.getValue(id);
    var icon = new ItemPropertyColorDrawable(color);
    IconMenuItem.initialize(label, colorToString(color), id, icon, {});
  }

  function colorToString(color) {
    var res;
    if (color == Graphics.COLOR_TRANSPARENT) {
      res = color.toString();
    } else {
      res = "0x" + color.format("%06X");
    }
    return res;
  }

  function onSelectItem() {
    var picker = new ColorPicker(self.weak());
    WatchUi.pushView(
      picker,
      new ColorPickerDelegate(picker.weak()),
      WatchUi.SLIDE_IMMEDIATE
    );
  }

  function onSelectColor(newColor) {
    if (newColor instanceof Lang.Number) {
      color = newColor;
    } else {
      color = newColor.toNumber();
    }
    Application.Properties.setValue(getId(), color);
    setSubLabel(colorToString(color));
    var icon = getIcon();
    icon.color = color;
  }
}

//*****************************************************************************
//Вспомогательный объект. Формирет Drawable с цветом для размещения цвета на
//пункте меню
class ItemPropertyColorDrawable extends WatchUi.Drawable {
  var color;

  function initialize(color) {
    self.color = color;
    var options = {
      :identifier => color,
      :locX => 0,
      :locY => 0,
      :width => 5,
      :height => 5,
      :visible => true,
    };
    Drawable.initialize(options);
  }

  function draw(dc) {
    if (color == Graphics.COLOR_TRANSPARENT) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
      dc.clear();
      dc.setPenWidth(5);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.drawLine(0, 0, dc.getWidth(), dc.getHeight());
      dc.drawLine(0, dc.getHeight(), dc.getWidth(), 0);
    } else {
      if (color == Graphics.COLOR_BLACK) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      } else if (color == Graphics.COLOR_WHITE) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
      } else {
        dc.setColor(Graphics.COLOR_WHITE, color);
      }
      dc.clear();
      dc.drawRectangle(0, 0, dc.getWidth(), dc.getHeight());
    }
  }
}
