import Toybox.Graphics;
import Toybox.WatchUi;

class MenuAuthorization extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.authorisation,
      :theme => Style.getMenuTheme(),
    });

    var onChangeCallback = new Lang.Method(
      BooksExtraModule,
      :removeAuthorization
    );

    addItem(
      new PickerItem(
        Rez.Strings.login,
        Application.Properties.getValue(LOGIN),
        LOGIN,
        onChangeCallback
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.password,
        Application.Properties.getValue(PASSWORD),
        PASSWORD,
        onChangeCallback
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.server,
        Application.Properties.getValue(SERVER),
        PASSWORD,
        onChangeCallback
      )
    );

    
  }
}
