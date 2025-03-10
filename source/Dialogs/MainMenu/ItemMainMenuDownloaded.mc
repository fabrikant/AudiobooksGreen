import Toybox.WatchUi;

class ItemMainMenuDownloaded extends WatchUi.IconMenuItem {
  function initialize() {
    var rezDrawable = Rez.Drawables.deviceBooks;
    IconMenuItem.initialize(
      Rez.Strings.content,
      null,
      null,
      new MenuItemDrawable(rezDrawable),
      {}
    );
  }

  function onSelectItem() {
    WatchUi.pushView(
      new BooksMenuDownloaded(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
