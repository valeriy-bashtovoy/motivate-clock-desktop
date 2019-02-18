package org.motivateclock.model.icons
{

    import com.adobe.images.PNGEncoder;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.interfaces.IProcess;

    /**
     * @author: Valeriy Bashtovoy
     */
    public class IconManager extends EventDispatcher
    {

        public static var instance:IconManager;
        private static var isSingleton:Boolean = false;
        private var _initialized:Boolean = false;
        private var _xmlIconCollection:XML;
        private var _fileStream:FileStream;
        private var _iconNum:int = 0;

        public static function getInstance():IconManager
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new IconManager();
                isSingleton = false;
            }

            return instance;
        }

        public function IconManager()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + " is singletone, use getInstance();");
            }
        }

        public function init():void
        {
            if (_initialized)
            {
                return;
            }

            _initialized = true;
            load();
        }

        public function getIcon(process:IProcess):Icon
        {
            //trace(this, "getIcon(", process, ")");

            var icon:Icon;

            if (!process)
            {
                return null;
            }

            switch (process.type)
            {
                case ProcessTypeEnum.BROWSER:
                case ProcessTypeEnum.APP:
                    icon = getAppIcon(process.path);
                    break;
                case ProcessTypeEnum.SITE:
                    icon = getSiteIcon(process.path);
                    break;
            }

            return icon;
        }

        public function getSiteIcon(path:String):Icon
        {
            if (path.search(/:/i) != -1)
            {
                return null;
            }

            var icon:Icon = new Icon();
            icon.path = "https://www.google.com/s2/favicons?domain=" + path;

            return icon;
        }

        public function getAppIcon(path:String):Icon
        {
            var iconPath:String = _xmlIconCollection.*.(@PROCESS == path).@ICON;
            var icon:Icon = new Icon();
            var xmlIcon:XML;

            if (iconPath != "")
            {
                icon.path = iconPath;
            }
            else
            {
                icon.bitmap = getIconByProcess(path);
                xmlIcon = new XML("<ICON/>");
                xmlIcon.@PROCESS = path;
                xmlIcon.@ICON = saveIcon(icon.bitmap);
                _xmlIconCollection.appendChild(xmlIcon);
            }

            return icon;
        }

        public function saveIcon(bitmap:Bitmap):String
        {
            if (bitmap == null)
            {
                return "null";
            }

            var path:String = "icon_" + _xmlIconCollection.*.length() + ".png";

            var file:File = File.applicationStorageDirectory.resolvePath("ico/" + path);
            var fileStream:FileStream = new FileStream();
            fileStream.addEventListener(IOErrorEvent.IO_ERROR, saveEventHandler);
            fileStream.addEventListener(Event.COMPLETE, saveEventHandler);
            fileStream.open(file, FileMode.WRITE);
            fileStream.writeBytes(PNGEncoder.encode(bitmap.bitmapData));
            fileStream.close();

            return path;
        }

        private function saveEventHandler(event:Event):void
        {
            switch (event.type)
            {
                case IOErrorEvent.IO_ERROR:
                    trace("icon save error");
                    break;
                case Event.COMPLETE:
                    trace("icon save complete");
                    break;
            }
        }

        private function load():void
        {
            var file:File = File.applicationStorageDirectory.resolvePath("icons.xml");

            if (!file.exists)
            {
                _xmlIconCollection = new XML("<ICONS/>");
                return;
            }

            _fileStream = new FileStream();
            _fileStream.openAsync(file, FileMode.READ);
            _fileStream.addEventListener(Event.COMPLETE, fileCompleteHandler);
        }

        public function save():void
        {
            //			trace("iconManager save");

            if (_iconNum == _xmlIconCollection.*.length())
            {
                return;
            }

            var file:File = File.applicationStorageDirectory.resolvePath("icons.xml");
            var stream:FileStream;

            try
            {
                stream = new FileStream();
            }
            catch (e:Error)
            {
            }

            if (stream)
            {
                stream.openAsync(file, FileMode.WRITE);
                stream.writeUTFBytes(_xmlIconCollection);
                stream.close();
            }

            _iconNum = _xmlIconCollection.*.length();
        }

        private function fileCompleteHandler(event:Event):void
        {
            try
            {
                _xmlIconCollection = XML(_fileStream.readMultiByte(_fileStream.bytesAvailable, 'windows-1251'));
            }
            catch (error:Error)
            {
            }
            _fileStream.close();

            if (!_xmlIconCollection)
            {
                _xmlIconCollection = new XML("<ICONS/>");
            }

            _iconNum = _xmlIconCollection.*.length();
        }

        private function checkJavaPath(path:String):String
        {
            var file:File;
            var newPath:String;

            if (path.search(".jar") != -1)
            {
                newPath = path.replace(".jar", ".exe");
                file = File.applicationDirectory.resolvePath(newPath);
                if (file.exists)
                {
                    return file.nativePath;
                }
            }

            return path;
        }

        private function getIconByProcess(processPath:String, size:int = 16):Bitmap
        {
            var bitmap:Bitmap = new Bitmap();
            var file:File;

            processPath = checkJavaPath(processPath);

            try
            {
                file = new File(processPath);
            }
            catch (error:Error)
            {
            }

            if (!file || file.icon.bitmaps.length == 0)
            {
                return null;
            }

            var bitmapData:BitmapData = file.icon.bitmaps[0];

            for each (var bd:BitmapData in file.icon.bitmaps)
            {
                if (bd.height == size)
                {
                    bitmapData = bd;
                    break;
                }
            }

            bitmap.bitmapData = bitmapData;

            if (!bitmap.bitmapData)
            {
                return null;
            }

            var c1:uint = bitmapData.getPixel32(bitmapData.width / 2, bitmapData.height / 2);
            var c2:uint = bitmapData.getPixel32(bitmapData.width / 4, bitmapData.height / 4);
            var c3:uint = bitmapData.getPixel32(bitmapData.width / 3, bitmapData.height / 3);

            if (c1 == c2 && c2 == c3)
            {
                bitmap = null;
            }

            return bitmap;
        }
    }
}
