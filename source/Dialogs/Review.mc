import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module Review {
  function getTokenIfItsOk() {
    if (itsOk()) {
      logger.info(
        "All conditions are met. Request a token to request a review."
      );
      WatchUi.makeReviewTokenRequest(new Lang.Method(Review, :onGettingToken));
    }
  }

  function onGettingToken(responseStatus, token) {
    logger.info(
      "Response received for review token request:: " + responseStatus
    );
    if (responseStatus == WatchUi.REVIEW_REQUEST_STATUS_GRANTED and itsOk()) {
      if (token != null) {
        logger.info(
          "The request has been approved. Launching a user review request."
        );
        Application.Storage.setValue(
          "lastReviewRequestTime",
          Toybox.Time.now().value()
        );
        Application.Storage.setValue("lastReviewVersion", getApp().version);

        WatchUi.startUserReview(token);
      }
    }
  }

  function itsOk() {
    if (
      !(WatchUi has :makeReviewTokenRequest) or
      !(WatchUi has :startUserReview)
    ) {
      return false;
    }

    logger.debug(
      "Starting to check the ability to request a review from a user"
    );

    //Если это первый запуск приложения, запоминаем время
    //Не нужно просить отзыв в день установки.
    //Пусть пользователь поработает с приложением.
    var nowUnixTime = Toybox.Time.now().value();

    var dateFirstStart = Application.Storage.getValue("dateTimeFirstStart");
    if (dateFirstStart == null) {
      logger.debug("Skipping the review request. First-time app launch");
      Application.Storage.setValue("dateTimeFirstStart", nowUnixTime);
      return;
    } else if (
      nowUnixTime <
      dateFirstStart + Time.Gregorian.SECONDS_PER_DAY * 4
    ) {
      logger.debug(
        "Skipping the review request. Less than 4 days have passed since I started using the app"
      );
      return;
    }

    //Если в плейлисте нет книг, возвможно у него что-то не так
    var booksKeys = Application.Storage.getValue(BooksStore.PLAYLIST);
    if (!(booksKeys instanceof Lang.Array) or booksKeys.size() == 0) {
      logger.debug(
        "Skipping the review request. There are no books in the playlist"
      );
      return false;
    }

    //Если спрашивали в последние 20 дней, не трогаем
    var lastReviewRequestTime = Application.Storage.getValue(
      "lastReviewRequestTime"
    );
    if (lastReviewRequestTime != null) {
      if (
        nowUnixTime <
        lastReviewRequestTime + Time.Gregorian.SECONDS_PER_DAY * 20
      ) {
        logger.debug(
          "Skipping the review request. Review requested less than 20 days ago"
        );
        return false;
      }
    }

    //Если спрашивали про ЭТУ версию, не спрашиваем
    var lastReviewVersion = Application.Storage.getValue("lastReviewVersion");
    var currentVersion = getApp().version;
    if (
      lastReviewVersion instanceof Lang.String and
      currentVersion instanceof Lang.String and
      lastReviewVersion.equals(currentVersion)
    ) {
      logger.debug(
        "Skipping the review request. A review version " +
          currentVersion +
          " has already been requested"
      );
      return false;
    }

    return true;
  }
}
