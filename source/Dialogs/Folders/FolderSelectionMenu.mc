import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class FolderSelectionMenu extends WatchUi.Menu2 {
  var finalCallback = null;

  function initialize(finalCallback, folderList) {
    self.finalCallback = finalCallback;
    Menu2.initialize({
      :title => Rez.Strings.selectListMenuTitle,
      :theme => Style.getMenuTheme(),
    });
    for (var i = 0; i < folderList.size(); i++) {
      addItem(new FolderToSelectItem(finalCallback, folderList[i]));
    }
  }




}
