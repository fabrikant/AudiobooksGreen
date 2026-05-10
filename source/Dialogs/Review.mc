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
        "Request a token to request a review."
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

    // logger.debug("Начало проверки возможности запросить отзыв у пользователя");

    //Если это первый запуск приложения, запоминаем время
    //Не нужно просить отзыв в день установки.
    //Пусть пользователь поработает с приложением.
    var nowUnixTime = Toybox.Time.now().value();

    var dateFirstStart = Application.Storage.getValue("dateTimeFirstStart");
    if (dateFirstStart == null) {
      // logger.debug("Отзыв не запрашиваем. Первый запуск приложения");
      Application.Storage.setValue("dateTimeFirstStart", nowUnixTime);
      return;
    } else if (
      nowUnixTime <
      dateFirstStart + Time.Gregorian.SECONDS_PER_DAY * 4
    ) {
      // logger.debug(
      //   "Отзыв не запрашиваем. Прошло меньше 4 дней после начала использования"
      // );
      return;
    }

    //Если в плейлисте нет книг, возвможно у него что-то не так
    var booksKeys = Application.Storage.getValue(BooksStore.PLAYLIST);
    if (!(booksKeys instanceof Lang.Array) or booksKeys.size() == 0) {
      // logger.debug("Отзыв не запрашиваем. Нет книг в плейлисте");
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
        // logger.debug("Отзыв не запрашиваем. Спрашивали недавно");
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
      // logger.debug(
      //   "Отзыв не запрашиваем. Спрашивали про верисю " + currentVersion
      // );
      return false;
    }

    return true;
  }
}
