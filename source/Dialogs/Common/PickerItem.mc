import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

//*****************************************************************************
//Пункт меню ввода текста
class PickerItem extends WatchUi.MenuItem {
  var onChangeCallback = null;

  function initialize(label, sublabel, id, onChangeCallback) {
    self.onChangeCallback = onChangeCallback;
    if (sublabel == null) {
      sublabel = "";
    }
    MenuItem.initialize(label, sublabel.toString(), id, {});
  }

  function onSelectItem() {
    if (WatchUi has :TextPicker) {
      var propValue = Application.Properties.getValue(getId());
      WatchUi.pushView(
        new WatchUi.TextPicker(propValue),
        new TextDelegate(self.weak()),
        WatchUi.SLIDE_IMMEDIATE
      );
    }
  }

  function onSetText(value) {
    var sublabel = getSubLabel();
    if (sublabel != null and !sublabel.equals(value)) {
      // Проверим тип свойства. Возможно полученное значение
      // нужно преобразовать.
      var propValue = Application.Properties.getValue(getId());
      if (propValue instanceof Lang.Number) {
        var numbValue = value.toNumber();
        if (numbValue instanceof Lang.Number) {
          setSubLabel(value);
          Application.Properties.setValue(getId(), numbValue);
        }
      } else {
        setSubLabel(value);
        Application.Properties.setValue(getId(), value);
      }
      if (
        onChangeCallback != null and
        onChangeCallback instanceof Lang.Method
      ) {
        onChangeCallback.invoke(getId(), value);
      }
    }
  }
}

//*****************************************************************************
//Делегат ввода текста
class TextDelegate extends WatchUi.TextPickerDelegate {
  var parent_week;

  function initialize(parent_week) {
    self.parent_week = parent_week;
    TextPickerDelegate.initialize();
  }

  function onTextEntered(text, changed) {
    if (changed && parent_week.stillAlive()) {
      var obj = parent_week.get();
      obj.onSetText(text);
    }
  }

  function onCancel() {
    //screenMessage = "Canceled";
  }
}
