import Toybox.Application;

module BooksExtraModule {
  function removeAuthorization(propKey, propValue) {
    logger.debug("Авторизация сброшена");
    Application.Storage.deleteValue(SID);
    Application.Storage.deleteValue(SID_TIME);
    Application.Storage.deleteValue(AUTHORISATION_TIME);
  }
}
