import Toybox.WatchUi;


class ProgressBarWithCallback extends WatchUi.ProgressBar{
    function initialize(label, value, callback){
        WatchUi.ProgressBar.initialize(label, value);
        callback.invoke();
    }

}