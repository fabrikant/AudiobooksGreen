import Toybox.Media;
import Toybox.Graphics;
import Toybox.Application;

class AbooksPlaybackProfile extends Media.PlaybackProfile {
  function initialize() {
    playbackControls = [
      PLAYBACK_CONTROL_SKIP_FORWARD,
      PLAYBACK_CONTROL_SKIP_BACKWARD,
      PLAYBACK_CONTROL_NEXT,
      PLAYBACK_CONTROL_VOLUME,
      PLAYBACK_CONTROL_PREVIOUS,
      PLAYBACK_CONTROL_PLAYBACK,
      // PLAYBACK_CONTROL_SOURCE,
      // PLAYBACK_CONTROL_LIBRARY,
      // PLAYBACK_CONTROL_SHUFFLE,
      // PLAYBACK_CONTROL_REPEAT,
      // PLAYBACK_CONTROL_RATING,
    ];

    attemptSkipAfterThumbsDown = false;
    playbackNotificationThreshold = 5;
    if (!Application.Properties.getValue("defaultPlayerColors")) {
      playerColors = new AbooksColors();
    }
    requirePlaybackNotification = true;
    if (Media.PlaybackProfile has :skipBackwardTimeDelta) {
      skipBackwardTimeDelta = 30;
      skipForwardTimeDelta = 30;
      skipPreviousThreshold = 5;
    }
  }
}
