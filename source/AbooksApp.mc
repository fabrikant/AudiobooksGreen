import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;

class AbooksApp extends Application.AudioContentProviderApp {
  
  const version = "2025.03.15.01";
  
  var SyncWasStartedOnThisChargeCycle = false;

  function initialize() {
    AudioContentProviderApp.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) {
    Local.setSettings();
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) {}

  // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
  function getContentDelegate(arg as PersistableType) {
    return new AbooksContentDelegate(arg);
  }

  // Get a delegate that communicates sync status to the system for syncing media content to the device
  function getSyncDelegate() as Communications.SyncDelegate? {
    return new AbooksSyncDelegate();
  }

  // Get the initial view for configuring playback
  function getPlaybackConfigurationView() {
    return [new MenuMain(), new SimpleMenuDelegate()];
  }

  // Get the initial view for configuring sync
  function getSyncConfigurationView() {
    // Одна и та же вьюшка будет возвращаться и для настройки синхронизации
    // и для настройки плейбэка.
    // Такое ощущение, что в реальной жизни getSyncConfigurationView()
    // не вызывается
    return [new MenuMain(), new SimpleMenuDelegate()];
    // return [new AbooksConfigureSyncView(), new SimpleMenuDelegate()];
  }

  function getProviderIconInfo() {
    return new Toybox.Media.ProviderIconInfo(
      // Rez.Drawables.logo10,
      Rez.Drawables.logoComplications,
      Toybox.Graphics.COLOR_DK_BLUE
    );
  }
}

function getApp() as AbooksApp {
  return Application.getApp() as AbooksApp;
}
