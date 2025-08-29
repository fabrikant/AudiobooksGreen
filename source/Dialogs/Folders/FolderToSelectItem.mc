import Toybox.WatchUi;
import Toybox.Lang;

//*****************************************************************************
//Пункт подменю - выбор плейлиста
//
class FolderToSelectItem extends WatchUi.MenuItem {
  var finalCallback = null;

  function initialize(finalCallback, folderInfo) {
    self.finalCallback = finalCallback;

    MenuItem.initialize(
      folderInfo[BOOKS_FOLDER_NAME],
      "",
      folderInfo[BOOKS_FOLDER_ID],
      {}
    );
  }

  function onSelectItem() {
    finalCallback.invoke({
      BOOKS_FOLDER_NAME => getLabel(),
      BOOKS_FOLDER_ID => getId(),
    });
    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
  }
}
