import Toybox.Graphics;
import Toybox.WatchUi;

class MenuAuthorization extends WatchUi.Menu2 {
  function initialize() {
    Menu2.initialize({
      :title => Rez.Strings.authorisation,
      :theme => Style.getMenuTheme(),
    });

    addItem(
      new PickerItem(
        Rez.Strings.login,
        Application.Properties.getValue(LOGIN),
        LOGIN,
        null
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.password,
        Application.Properties.getValue(PASSWORD),
        PASSWORD,
        null
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.server,
        Application.Properties.getValue(SERVER),
        SERVER,
        null
      )
    );
    addItem(
      new PickerItem(
        Rez.Strings.proxy,
        Application.Properties.getValue(PROXY),
        PROXY,
        null
      )
    );
    // addItem(
    //   new PickerItem(
    //     Rez.Strings.token,
    //     Application.Properties.getValue(TOKEN),
    //     TOKEN,
    //     null
    //   )
    // );
  }
}
