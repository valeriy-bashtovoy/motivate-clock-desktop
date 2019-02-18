package org.motivateclock.services
{

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NativeProcessExitEvent;
    import flash.filesystem.File;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.Capabilities;
    import flash.utils.ByteArray;

    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Process;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class RunningProcessService extends EventDispatcher
    {

        public static var instance:RunningProcessService;
        private static var isSingleton:Boolean = false;

        private var _nativeProcess:NativeProcess;
        private var _nativeProcessStartupInfo:NativeProcessStartupInfo;
        private var _processList:Array;
        private var _ignore2List:Vector.<String> = new <String>['distnoted.exe',
            'webkit2webprocess.exe',
            'btstackserver.exe',
            'bluetoothheadsetproxy.exe',
            'taskeng.exe',
            'sihost.exe',
            'svchost.exe',
            'ps64ldr.exe',
            'dllhost.exe',
            'igfxem.exe',
            'fsnotifier64.exe',
            'taskhostw.exe',
            'igfxhk.exe',
            'igfxtray.exe',
            'searchui.exe',
            'motivateclockactivity64.exe',
            'shellexperiencehost.exe',
            'msascuil.exe',
            'runtimebroker.exe',
            'settingsynchost.exe',
            'applicationframehost.exe',
            'conhost.exe',
            'taskhost.exe',
            'dwm.exe',
            'searchfilterhost.exe',
            'motivateclockactivity.exe',
            'googletalkplugin.exe',
            'googlecrashhandler.exe',
            'divxupdate.exe',
            'ituneshelper.exe',
            'bttray.exe',
            'jusched.exe'];

        public static function getInstance():RunningProcessService
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new RunningProcessService();
                isSingleton = false;
            }

            return instance;
        }

        public function RunningProcessService()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + " is singletone;");
            }

            _nativeProcessStartupInfo = new NativeProcessStartupInfo();
            _nativeProcessStartupInfo.workingDirectory = File.applicationStorageDirectory;

            var processArguments:Vector.<String>;
            var isDebugMode:Boolean = File.applicationDirectory.resolvePath("debugprocesses.txt").exists;

            if (isDebugMode)
            {
                processArguments = new Vector.<String>();
                processArguments[0] = "/debuglog";
                _nativeProcessStartupInfo.arguments = processArguments;
            }

            var path:String = "utils/MotivateClockProcesses";

            path += Capabilities.supports64BitProcesses ? "64" : "";

            var file:File = File.applicationDirectory.resolvePath(path + ".exe");

            try
            {
                _nativeProcessStartupInfo.executable = file;
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
                return;
            }

            _nativeProcess = new NativeProcess();
            _nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, exitHandler);
        }

        private function exitHandler(event:NativeProcessExitEvent):void
        {
            loadApplicationList();
        }

        public function getApplications():void
        {
            if (_nativeProcess.running)
            {
                return;
            }

            try
            {
                _nativeProcess.start(_nativeProcessStartupInfo);
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
            }
        }

        public function get processList():Vector.<IProcess>
        {
            return Vector.<IProcess>(_processList);
        }

        private function hasDuplicate(process:IProcess):Boolean
        {
            for each (var p:IProcess in _processList)
            {
                if (process.path == p.path)
                    return true;
            }

            return false;
        }

        private function getApplicationCollection(byte:ByteArray):void
        {
            var data:String = byte.readMultiByte(byte.bytesAvailable, 'windows-1251');
            data = data.replace(/(unknown_description)/ig, "");

            _processList = [];

            var appCollection:Array = data.split(/\$\r\n/);
            var app:Array;
            var process:IProcess;

            for each (var item:String in appCollection)
            {
                app = item.split(/\t/);

                process = new Process('', app[2]);

                process.path = String(app[0]).toLowerCase().replace(/(\r\n|\t)/ig, "");
                process.path = process.path.replace(/(\.\S{3})(\s+.*)/i, "$1");

                if (process.path.search(/(firefox.exe|opera.exe|iexplore.exe|chrome.exe)/ig) != -1)
                    process.type = ProcessTypeEnum.BROWSER;
                else
                    process.type = ProcessTypeEnum.APP;

                if (!process.path)
                    continue;

                if (hasDuplicate(process) || isIgnored(process))
                    continue;

//                trace('process', process.serialize());

                if (process.name == "" || process.path.search(".jar") != -1)
                {
                    process.name = process.path.replace(/(.*\\|\.\S{3}\Z|.*\/)/ig, "");
                    process.name = process.name.substr(0, 1).toUpperCase() + process.name.substr(1);
                }

                _processList.push(process);
            }

            _processList.sortOn('name');

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function isIgnored(process:IProcess):Boolean
        {
            for each (var name:String in _ignore2List)
            {
                if (process.path.indexOf(name) != -1)
                    return true;
            }

            return false;
        }

        private function loadApplicationList():void
        {
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, completeHandler);

            var path:String = File.applicationStorageDirectory.nativePath;

            try
            {
                loader.load(new URLRequest(path + "/processes.dat"));
            }
            catch (error:Error)
            {
                trace(error.message);
            }
        }

        private function completeHandler(event:Event):void
        {
            getApplicationCollection(event.target.data);
        }
    }
}
