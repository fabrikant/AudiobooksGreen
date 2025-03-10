import Toybox.Application;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

class ColorPicker extends WatchUi.View {
  var parent_weak;
  var color, box_index;
  var bitmap, boxes, zero_point;
  const rows = 8;

  function initialize(parent_weak) {
    View.initialize();
    self.parent_weak = parent_weak;

    if (parent_weak.stillAlive()) {
      var obj = parent_weak.get();
      if (obj != null) {
        self.color = obj.color;
      }
    }
    createBitmap();
    box_index = null;
  }

  function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.drawBitmap(zero_point[0], zero_point[1], bitmap.get());

    if (color != null) {
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      var font = Graphics.FONT_SMALL;
      var color_str = null;
      if (color == Graphics.COLOR_TRANSPARENT) {
        color_str = color.toString();
      } else {
        color_str = "0x" + color.format("%06X");
      }

      var x = dc.getWidth() / 2;
      var y = zero_point[1] - Graphics.getFontHeight(font);
      dc.drawText(x, y, font, color_str, Graphics.TEXT_JUSTIFY_CENTER);
    }

    if (box_index == null) {
      box_index = colorToIndex(color);
    }

    var box = boxes[box_index][:box];
    dc.setPenWidth(3);
    var frame_color = farameColor();
    dc.setColor(frame_color, frame_color);
    dc.drawRectangle(
      box[:x1] + zero_point[0],
      box[:y1] + zero_point[1],
      box[:x2] - box[:x1],
      box[:y2] - box[:y1]
    );
  }

  function farameColor() {
    if (color == Graphics.COLOR_TRANSPARENT) {
      return Graphics.COLOR_GREEN;
    } else {
      if (
        1.0 -
          (0.299 * ((color & 0xff0000) >> 16) +
            0.587 * ((color & 0x00ff00) >> 8) +
            0.114 * (color & 0x0000ff)) /
            255.0 <
        0.5
      ) {
        return Graphics.COLOR_BLACK;
      } else {
        return Graphics.COLOR_WHITE;
      }
    }
  }

  function colorToIndex(color) {
    for (var i = 0; i < boxes.size(); i++) {
      if (boxes[i][:color] == color) {
        return i;
      }
    }
  }

  function indexToColor(index) {
    return boxes[index][:color];
  }

  function createBitmap() {
    boxes = [];
    var dev_screen_size = System.getDeviceSettings().screenHeight;
    var side_size = Math.floor(
      Math.sqrt((dev_screen_size * dev_screen_size) / 2)
    );
    var segment_size = Math.floor(side_size / rows).toNumber();
    side_size = segment_size * rows;

    var zero = (dev_screen_size - side_size) / 2;
    zero_point = [zero, zero];

    var x_count = 0;
    var y_count = 0;

    self.bitmap = Graphics.createBufferedBitmap({
      :width => side_size,
      :height => side_size + 2 * segment_size,
    });
    var dc = bitmap.get().getDc();

    var values = [0x00, 0x55, 0xaa, 0xff];
    for (var i = 0; i < values.size(); i++) {
      for (var j = 0; j < values.size(); j++) {
        for (var k = 0; k < values.size(); k++) {
          var curren_color = (values[i] << 16) + (values[j] << 8) + values[k];
          var x = x_count * segment_size;
          var y = y_count * segment_size;
          dc.setColor(curren_color, curren_color);
          dc.fillRectangle(x, y, segment_size, segment_size);

          boxes.add({
            :color => curren_color,
            :box => {
              :x1 => x,
              :y1 => y,
              :x2 => x + segment_size,
              :y2 => y + segment_size,
            },
          });
          if ((x_count + 1) % rows == 0) {
            x_count = 0;
            y_count += 1;
          } else {
            x_count += 1;
          }
          if (y_count >= rows) {
            break;
          }
        }
      }
    }
    for (var i = 0; i < rows; i++) {
      boxes.add({
        :color => Graphics.COLOR_TRANSPARENT,
        :box => {
          :x1 => segment_size * 3,
          :y1 => side_size,
          :x2 => side_size - segment_size * 3,
          :y2 => dc.getHeight(),
        },
      });
    }

    var box = boxes[boxes.size() - 1][:box];
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
    dc.setClip(box[:x1], box[:y1], box[:x2] - box[:x1], box[:y2] - box[:y1]);
    dc.fillRectangle(
      box[:x1],
      box[:y1],
      box[:x2] - box[:x1],
      box[:y2] - box[:y1]
    );
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.setPenWidth(5);
    dc.drawLine(box[:x1], box[:y1], box[:x2], box[:y2]);
    dc.drawLine(box[:x2], box[:y1], box[:x1], box[:y2]);
  }

  function onClick(clickEvent) {
    var coords = clickEvent.getCoordinates();
    coords[0] -= zero_point[0];
    coords[1] -= zero_point[1];
    for (var i = 0; i < boxes.size(); i++) {
      var box = boxes[i][:box];
      if (
        coords[0] >= box[:x1] &&
        coords[0] < box[:x2] &&
        coords[1] >= box[:y1] &&
        coords[1] < box[:y2]
      ) {
        box_index = i;
        color = boxes[i][:color];
        WatchUi.requestUpdate();
        break;
      }
    }
  }

  function onKey(keyEvent) {
    var key = keyEvent.getKey();
    if (key == WatchUi.KEY_ESC) {
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    } else if (key == WatchUi.KEY_ENTER) {
      if (parent_weak.stillAlive()) {
        var obj = parent_weak.get();
        if (obj != null) {
          obj.onSelectColor(color);
        }
      }
      WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    } else if (key == WatchUi.KEY_UP) {
      //Go right
      box_index += 1;
      if (box_index % rows == 0) {
        box_index -= rows;
      }
      color = boxes[box_index][:color];
      WatchUi.requestUpdate();
    } else if (key == WatchUi.KEY_DOWN) {
      //Go Down
      box_index += rows;
      if (box_index >= boxes.size()) {
        box_index = box_index % rows;
      }
      color = boxes[box_index][:color];
      WatchUi.requestUpdate();
    }
  }
}

///////////////////////////////////////////////////////////////////////////////
//Delegate
class ColorPickerDelegate extends WatchUi.InputDelegate {
  var picker_weak;

  function initialize(picker_weak) {
    InputDelegate.initialize();
    self.picker_weak = picker_weak;
  }

  function onKey(keyEvent) {
    if (picker_weak.stillAlive()) {
      var obj = picker_weak.get();
      if (obj != null) {
        obj.onKey(keyEvent);
      }
    }
    return true;
  }

  function onTap(clickEvent) {
    if (picker_weak.stillAlive()) {
      var obj = picker_weak.get();
      if (obj != null) {
        obj.onClick(clickEvent);
      }
    }
    return true;
  }
}
