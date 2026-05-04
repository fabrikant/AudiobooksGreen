import Toybox.WatchUi;

class ItemMainMenuAllBooks extends WatchUi.IconMenuItem {
  function initialize() {
    var rezDrawable = Rez.Drawables.serverBooks;
    IconMenuItem.initialize(
      Rez.Strings.allBooks,
      null,
      null,
      new MenuItemDrawable(rezDrawable),
      {}
    );
  }

  function onSelectItem() {
    AllBooks.createAllBooksMenu();
  }
}
