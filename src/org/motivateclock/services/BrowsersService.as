/**
 * User: Valeriy Bashtovoy
 * Date: 08.09.13
 */
package org.motivateclock.services
{

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;

    import org.motivateclock.interfaces.IService;

    public class BrowsersService implements IService
    {
        private static const PATH:String = "utils/MotivateClockBrowsers.exe";

        private var _nativeProcessStartupInfo:NativeProcessStartupInfo;
        private var _nativeProcess:NativeProcess;
        private var _dataHandler:Function;
        private var _errorHandler:Function;
        private var _data:String = "";

        public function BrowsersService()
        {
        }

        public function initialize():void
        {
            _nativeProcessStartupInfo = new NativeProcessStartupInfo();

            try
            {
                _nativeProcessStartupInfo.executable = File.applicationDirectory.resolvePath(PATH);
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
                return;
            }

            _nativeProcess = new NativeProcess();
            _nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputDataHandler, false, 0, true);
            _nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, exitHandler, false, 0, true);

            try
            {
                _nativeProcess.start(_nativeProcessStartupInfo);
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
            }
        }

        private function exitHandler(event:NativeProcessExitEvent):void
        {
            if (_dataHandler)
            {
                _dataHandler(_data);
            }
        }

        private function outputDataHandler(event:ProgressEvent):void
        {
            _data += _nativeProcess.standardOutput.readMultiByte(_nativeProcess.standardOutput.bytesAvailable, "unicode")
        }

        public function initializeHandlers(dataHandler:Function, errorHandler:Function = null):void
        {
            _dataHandler = dataHandler;
            _errorHandler = errorHandler;
        }

        public function dispose():void
        {
        }
    }
}
