package org.motivateclock.model
{

    import flash.display.LoaderInfo;
    import flash.events.EventDispatcher;
    import flash.events.UncaughtErrorEvent;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.system.Capabilities;

    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.events.ErrorEvent;
    import org.motivateclock.model.update.UpdaterModel;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ErrorLog extends EventDispatcher
    {

        public static var instance:ErrorLog;
        private static var isSingleton:Boolean = false;

        private var _file:File;
        private var _stream:FileStream;

        public static function getInstance():ErrorLog
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new ErrorLog();
                isSingleton = false;
            }

            return instance;
        }

        public function ErrorLog()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + "this is singletone, use getInstance()");
            }

            _file = File.applicationStorageDirectory.resolvePath(FileEnum.ERROR_LOG);
            _stream = new FileStream();
        }

        private function getShortErrorInfo(message:String):String
        {
            var log:String = "v.";

            log += UpdaterModel.getInstance().currentVersionLabel + " | ";
            log += Capabilities.os + " | ";

            var lineCollection:Array;
            var infoCollection:Array;

            if (message)
            {
                lineCollection = message.split("\n");
                if (lineCollection.length > 0)
                {
                    infoCollection = String(lineCollection[1]).split("::");

                    if (infoCollection.length > 1)
                    {
                        log += String(infoCollection[1]).replace(/(.*\\)|\]|\[/ig, "");
                    }
                }
            }

            return log;
        }

        public function init(loaderInfo:LoaderInfo):void
        {
            //if (!Capabilities.isDebugger)
//            {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
//            }
        }

        private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
        {
            event.stopPropagation();
            event.preventDefault();

            var errorEvent:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);

            errorEvent.version = UpdaterModel.getInstance().currentVersionLabel;

            if (event.error is Error)
            {
                errorEvent.message = Error(event.error).message;
                errorEvent.stackTrace = Error(event.error).getStackTrace();
            }
            else if (event.error is ErrorEvent)
            {
                errorEvent.message = flash.events.ErrorEvent(event.error).text;
            }
            else
            {
                errorEvent.message = event.error.toString();
            }

            log(errorEvent.message + "\n" + errorEvent.stackTrace);

            trace(this, errorEvent);

            dispatchEvent(errorEvent);
        }

        public function log(value:String):void
        {
            var log:String = new Date().toString() + "\n";
            log += "v. " + UpdaterModel.getInstance().currentVersionLabel + "\n";
            log += value + "\n - - -\n";

            _stream.open(_file, FileMode.APPEND);
            _stream.writeUTF(log);
            _stream.close();
        }
    }
}
