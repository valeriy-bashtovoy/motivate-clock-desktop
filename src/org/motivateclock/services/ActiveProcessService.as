package org.motivateclock.services
{

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.NativeProcessExitEvent;
    import flash.events.ProgressEvent;
    import flash.filesystem.File;
    import flash.system.Capabilities;

    import org.motivateclock.Model;
    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.interfaces.IService;
    import org.motivateclock.model.vo.ProcessVO;
    import org.motivateclock.utils.URIUtil;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ActiveProcessService implements IService
    {
        public static const BLANK_TAB:String = "tab:blank";

        private var _nativeProcess:NativeProcess;
        private var _currentProcessPath:String = "";
        private var _nativeProcessStartupInfo:NativeProcessStartupInfo;
        private var _tempPathPart:String = "";
        private var _currentAppVO:ProcessVO;
        private var _dataHandler:Function;
        private var _model:Model;

        public function ActiveProcessService(model:Model)
        {
            _model = model;
        }

        public function initialize():void
        {
            _nativeProcessStartupInfo = new NativeProcessStartupInfo();

            var processArguments:Vector.<String>;
            var isDebugMode:Boolean = File.applicationDirectory.resolvePath("debugactivity.txt").exists;

            if (isDebugMode)
            {
                processArguments = new Vector.<String>();
                processArguments[0] = "/debuglog";
                _nativeProcessStartupInfo.arguments = processArguments;
            }


            var path:String = "utils/MotivateClockActivity";

            path += Capabilities.supports64BitProcesses ? "64" : "";

            var file:File = File.applicationDirectory.resolvePath(path + ".exe");

            try
            {
                _nativeProcessStartupInfo.executable = file;
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
            }

            _nativeProcess = new NativeProcess();
            _nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputDataHandler);
            _nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);

            try
            {
                _nativeProcess.start(_nativeProcessStartupInfo);
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
            }
        }

        public function dispose():void
        {
            if (!_nativeProcess)
            {
                return;
            }
            _nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, exitHandler);
            _nativeProcess.exit(true);
        }

        private function exitHandler(event:NativeProcessExitEvent):void
        {
            _nativeProcess = null;
            _model.applicationManager.exit(true);
        }

        private function getDomainFromUrl(url:String):String
        {
            var domain:String = URIUtil.getDomainFromURI(url);

            domain = (domain.length != 0) ? domain : ActiveProcessService.BLANK_TAB;

            //trace( "domain:", domain );

            return domain;
        }

        private function getAppLabel(label:String, path:String):String
        {
            if (label == "-" || path.search(".jar") != -1)
            {
                label = path.replace(/(.*\\|\..*)/ig, "");
                label = label.substr(0, 1).toUpperCase() + label.substr(1);
            }

            return label;
        }

        private function outputDataHandler(event:ProgressEvent):void
        {
            var data:String = _nativeProcess.standardOutput.readMultiByte(_nativeProcess.standardOutput.bytesAvailable, 'windows-1251');

            data = _tempPathPart + data;

            if (!isValid(data))
            {
                _tempPathPart = data;
                return;
            }

            _tempPathPart = "";

            data = data.replace(/\n/ig, "");

            //			trace("data:", data);

            dispatchAppVO(data);
        }

        /**
         * all raw info should have '/n' at the end of the string;
         */
        private function isValid(data:String):Boolean
        {
            return data.search(/\n/ig) != -1;
        }

        private function getAppPath(path:String):String
        {
            return path.replace(/(\.\S{3})(\s+.*)/i, "$1");
        }

        private function dispatchAppVO(data:String):void
        {
            var dataCollection:Array = data.split("$");
            var path:String = String(dataCollection[1]).toLowerCase();

            if (path == _currentProcessPath)
            {
                return;
            }

            _currentProcessPath = path;

            var appVO:ProcessVO = new ProcessVO();
            appVO.path = path;
            appVO.type = dataCollection[0];
            appVO.label = dataCollection[2];
            appVO.title = dataCollection[3];

            switch (appVO.type)
            {
                case ProcessTypeEnum.APP:
                    appVO.path = getAppPath(appVO.path);
                    appVO.label = getAppLabel(appVO.label, appVO.path);
                    break;
                case ProcessTypeEnum.SITE:
                    appVO.path = getDomainFromUrl(appVO.path);
                    appVO.label = appVO.path;
                    if (dataCollection[3])
                    {
                        appVO.browserPath = String(dataCollection[3]).toLowerCase();
                    }
                    break;
            }

            _currentAppVO = appVO;

            if (_dataHandler)
            {
                _dataHandler(appVO);
            }
        }

        public function initializeHandlers(dataHandler:Function, errorHandler:Function = null):void
        {
            _dataHandler = dataHandler;
        }
    }
}
