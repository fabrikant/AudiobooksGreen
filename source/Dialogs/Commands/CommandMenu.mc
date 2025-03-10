import Toybox.WatchUi;
import Toybox.Application;

class CommandMenu extends WatchUi.Menu2 {
  function initialize(title, ownerItemWeak, commands) {
    Menu2.initialize({ :title => title, :theme => Style.getMenuTheme() });

    for (var i = 0; i < commands.size(); i++) {
      addItem(commands[i]);
    }
  }
}
