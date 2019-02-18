/**
 * User: Valeriy Bashtovoy
 * Date: 07.06.2014
 */
package org.motivateclock.utils
{

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.utils.Timer;

    import org.motivateclock.events.DateWatcherEvent;
    import org.motivateclock.events.StorageEvent;

    [Event(name="change", type="org.motivateclock.events.DateWatcherEvent")]
    public class DateWatcher extends EventDispatcher
    {
        private static var _instance:DateWatcher;

        private static const DATE_FILE_NAME:String = "date.dat";
        // measures in min;
        private static const UPDATE_TIME:int = 60;

        private var _timer:Timer;
        private var _storage:Storage;
        private var _date:Date;

        public static function getInstance():DateWatcher
        {
            if (!_instance)
            {
                _instance = new DateWatcher(new PrivateClass());
            }

            return _instance;
        }

        public function DateWatcher(privateClass:PrivateClass)
        {
        }

        public function start():void
        {
            if (_storage)
            {
                return;
            }

            var file:File = File.applicationStorageDirectory.resolvePath(DATE_FILE_NAME);

            _storage = new Storage(file);
            _storage.addEventListener(StorageEvent.COMPLETE, loadCompleteHandler);

            if (file.exists)
            {
                _storage.loadObject();
            }
            else
            {
                _date = new Date();
                saveDate();
                dispatchEvent(new DateWatcherEvent(DateWatcherEvent.CHANGE));
            }

            _timer = new Timer(1000 * 60 * UPDATE_TIME);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler);
            _timer.start();
        }

        public function get currentDate():Boolean
        {
            return _date;
        }

        private function saveDate():void
        {
            _storage.saveObject(_date);
        }

        private function checkDate():void
        {
            var oldDate:String = _date.toDateString();
            var newDate:String = new Date().toDateString();

            if (oldDate == newDate)
            {
                return;
            }

            _date = new Date();

            saveDate();

            trace(this, "Date has been changed, current date is:", _date.toDateString());

            dispatchEvent(new DateWatcherEvent(DateWatcherEvent.CHANGE));
        }

        private function loadCompleteHandler(event:StorageEvent):void
        {
            _date = event.data as Date;

            if (!_date)
            {
                trace(this, "Warning! Date storage is broken. Has been created new date object;");
                _date = new Date();
            }

            checkDate();
        }

        private function timerHandler(event:TimerEvent):void
        {
            checkDate();
        }
    }
}

internal class PrivateClass
{
}
