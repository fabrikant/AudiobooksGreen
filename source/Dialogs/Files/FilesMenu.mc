import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

class FilesMenu extends WatchUi.CustomMenu {
  var bookItemWeak = null;
  var fonts = null;

  // **************************************************************************
  function initialize(bookItemWeak) {
    self.bookItemWeak = bookItemWeak;

    fonts = Style.getFonts();

    var itemHeight =
      4 * Graphics.getFontHeight(fonts[:fontExtra]) +
      Graphics.getFontDescent(fonts[:fontExtra]);

    var colors = new AbooksColors();
    CustomMenu.initialize(itemHeight, colors.menuBackgroundColor, {
      :theme => Style.getMenuTheme(),
      :titleItemHeight => itemHeight / 2,
      :title => new CustomMenuTitle(Rez.Strings.fileList),
    });

    if (bookItemWeak.stillAlive()) {
      var bookItem = bookItemWeak.get();
      var bookId = bookItem.getId();

      var files = Application.Storage.getValue(bookId);
      if (files instanceof Lang.Array) {
        for (var i = 0; i < files.size(); i++) {
          addItem(new FileItem(bookItemWeak, files[i]));
        }
      }
    }
  }
}
