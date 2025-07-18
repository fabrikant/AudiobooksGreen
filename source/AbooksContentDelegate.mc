import Toybox.Lang;
import Toybox.Media;
import Toybox.Application;
import Toybox.System;

// This class handles events from the system's media
// player. getContentIterator() returns an iterator
// that iterates over the songs configured to play.
class AbooksContentDelegate extends Media.ContentDelegate {
  var contenIterator = null;
  var startParams = null;

  function initialize(startParams) {
    self.startParams = startParams;
    ContentDelegate.initialize();
  }

  // Returns an iterator that is used by the system to play songs.
  // A custom iterator can be created that extends Media.ContentIterator
  // to return only songs chosen in the sync configuration mode.
  function getContentIterator() as ContentIterator ? {
    contenIterator = new AbooksContentIterator(startParams);
    return contenIterator;
  }

  // Respond to a user ad click
  function onAdAction(adContext as Object) as Void {}

  // Respond to a thumbs-up action
  function onThumbsUp(contentRefId as Object) as Void {}

  // Respond to a thumbs-down action
  function onThumbsDown(contentRefId as Object) as Void {}

  // Respond to a command to turn shuffle on or off
  function onShuffle() as Void {}

  // Handles a notification from the system that an event has
  // been triggered for the given song
  function onSong(contentRefId as Object, songEvent as SongEvent,
                  playbackPosition as Number or PlaybackPosition) as Void {
    logger.debug("onSong(contentRefId=" + contentRefId + ", songEvent=" +
                 songEvent + ", playbackPosition=" + playbackPosition + ")");

    // Запоминаем позицию воспроизведения
    if (contenIterator instanceof AbooksContentIterator) {
      if (songEvent != SONG_EVENT_START) {
        contenIterator.createPlayerBookmark(playbackPosition);
      }

      if (songEvent == SONG_EVENT_START or
          songEvent == SONG_EVENT_PLAYBACK_NOTIFY or
          songEvent == SONG_EVENT_RESUME) {
        contenIterator.setAlbumArt();
        contenIterator.updateComplications(true);
      }

      if (songEvent == SONG_EVENT_STOP or songEvent == SONG_EVENT_PAUSE) {
        contenIterator.updateComplications(false);
        // Пробуем синхронизировать прогресс
        var devSet = System.getDeviceSettings();
        if (devSet.connectionAvailable) {
          if (Application.Properties.getValue("autosyncProgress")) {
            var booksStorage = new BooksStore();
            var bookmarksDownloader =
                new ProgressAPI(self.method(
                                    : onBookmarksDownload),
                                booksStorage);
            bookmarksDownloader.start();
          }
        }
      }
    }
  }

  function onBookmarksDownload(bookStorage) as Void {
    logger.info("Завершена синхронизация прогресса");
  }
}
