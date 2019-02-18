/**
 * User: Valeriy Bashtovoy
 * Date: 26.05.2014
 */
package org.motivateclock.utils
{

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import org.motivateclock.events.StorageEvent;

    [Event(name="complete", type="flash.events.Event")]
    public class Storage extends EventDispatcher
    {
        private var _file:File;
        private var _fileStream:FileStream;
        private var _data:String;

        public function Storage(file:File)
        {
            _file = file;
            _fileStream = new FileStream();
        }

        public function loadString():void
        {
            if (!isFileValid(_file))
            {
                return;
            }

            _data = "";

            _fileStream.addEventListener(ProgressEvent.PROGRESS, fileProgressHandler);
            _fileStream.addEventListener(Event.COMPLETE, stringLoadCompleteHandler);

            _fileStream.openAsync(_file, FileMode.READ);
        }

        public function loadObject():void
        {
            if (!isFileValid(_file))
            {
                return;
            }

            _fileStream.addEventListener(Event.COMPLETE, objectLoadCompleteHandler);
            _fileStream.openAsync(_file, FileMode.READ);
        }

        public function saveObject(data:Object, async:Boolean = true):void
        {
            if (async)
            {
                _fileStream.openAsync(_file, FileMode.WRITE);
            }
            else
            {
                _fileStream.open(_file, FileMode.WRITE);
            }

            _fileStream.writeObject(data);
            _fileStream.close();
        }

        public function saveString(data:String, fileMode:String = FileMode.WRITE, async:Boolean = true):void
        {
            if (async)
            {
                _fileStream.openAsync(_file, fileMode);
            }
            else
            {
                _fileStream.open(_file, fileMode);
            }

            _fileStream.writeUTFBytes(data);
            _fileStream.close();
        }

        private function isFileValid(file:File):Boolean
        {
            if (!file)
            {
                trace(this, "Warning: " + _file + " wasn't defined;");

                dispatchEvent(new StorageEvent(StorageEvent.ERROR));

                return false;
            }

            if (!file.exists)
            {
                trace(this, "Warning: " + _file.name + " isn't exist!");

                dispatchEvent(new StorageEvent(StorageEvent.ERROR));

                return false;
            }

            return true;
        }

        private function objectLoadCompleteHandler(event:Event):void
        {
            _fileStream.removeEventListener(Event.COMPLETE, objectLoadCompleteHandler);

            var data:Object = _fileStream.readObject();

            _fileStream.close();

            dispatchEvent(new StorageEvent(StorageEvent.COMPLETE, false, data));
        }

        private function stringLoadCompleteHandler(event:Event):void
        {
            _fileStream.removeEventListener(Event.COMPLETE, stringLoadCompleteHandler);

            _fileStream.close();

            dispatchEvent(new StorageEvent(StorageEvent.COMPLETE, false, _data));
        }

        private function fileProgressHandler(event:ProgressEvent):void
        {
            _data += _fileStream.readUTFBytes(_fileStream.bytesAvailable);//File.systemCharset
        }
    }
}
