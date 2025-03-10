import Toybox.WatchUi;

class ItemMainMenuPlaylist extends WatchUi.IconMenuItem {
  function initialize() {
    var rezDrawable = Rez.Drawables.playlist;
    IconMenuItem.initialize(
      Rez.Strings.playlist,
      null,
      null,
      new MenuItemDrawable(rezDrawable),
      {}
    );
  }

  function onSelectItem() {
    WatchUi.pushView(
      new BooksMenuPlaylist(),
      new SimpleMenuDelegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
  }
}
