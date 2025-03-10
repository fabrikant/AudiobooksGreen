import Toybox.WatchUi;

class SimpleConfirmation extends WatchUi.ConfirmationDelegate {
  var callback = null;
  var context = null;

  function initialize(params) {
    callback = params[:callback];
    context = params[:context];
    ConfirmationDelegate.initialize();
  }

  function onResponse(response) {
    if (response == WatchUi.CONFIRM_YES) {
      callback.invoke(context);
    }
  }
}
