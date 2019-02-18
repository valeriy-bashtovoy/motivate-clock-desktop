/**
 * Created by Valeriy on 23.11.2014.
 */
package org.motivateclock.model
{

    import flash.events.EventDispatcher;

    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.interfaces.IProcessModel;

    public class ProcessModel extends EventDispatcher implements IProcessModel
    {
        private var _processList:Vector.<IProcess> = new <IProcess>[];
        private var _processMap:Object = {};
        private var _currentProcess:IProcess;

        public function ProcessModel()
        {
        }

        public function initialize(rawProcesses:String):void
        {
            _processList = deserialize(rawProcesses);
            _processMap = createMap(_processList);
        }

        private function createMap(processList:Vector.<IProcess>):Object
        {
            const map:Object = {};
            const length:int = processList.length;

            var process:IProcess;

            for (var i:int = 0; i < length; i++)
            {
                process = processList[i];
                map[process.id] = process;
            }

            return map;
        }

        private function validate(process:IProcess):void
        {
            if (!process)
            {
                return;
            }

            process.isMarked = _processMap[process.id];

            //trace(this, process.name, process.isMarked);
        }

        public function setCurrentProcess(process:IProcess):void
        {
            validate(process);

            _currentProcess = process;

            dispatchEvent(new ModelEvent(ModelEvent.PROCESS_CHANGE));

            trace(this, "currentProcess:", _currentProcess);
        }

        public function get currentProcess():IProcess
        {
            return _currentProcess;
        }

        public function add(process:IProcess):void
        {
            _processMap[process.id] = process;

            _processList.push(process);

            var e:ModelEvent = new ModelEvent(ModelEvent.PROCESS_ADD);
            e.process = process;
            dispatchEvent(e);
        }

        public function remove(process:IProcess):void
        {
            const length:int = _processList.length;

            for (var i:int = 0; i < length; i++)
            {
                if (processList[i].id != process.id)
                {
                    continue;
                }

                _processList.splice(i, 1);

                break;
            }

            delete _processMap[process.id];

            var e:ModelEvent = new ModelEvent(ModelEvent.PROCESS_REMOVE);
            e.process = process;
            dispatchEvent(e);
        }

        public function increaseCurrentProcessTime(time:Number):void
        {
            if (!_currentProcess || time == 0)
            {
                return;
            }

            _currentProcess.increaseTime(time);
        }

        public function serialize(processList:Vector.<IProcess>):String
        {
            var data:String = "";
            var length:int = processList ? processList.length : 0;

            for (var i:int = 0; i < length; i++)
            {
                data += processList[i].serialize();
            }

            return data;
        }

        public function deserialize(rawProcesses:String):Vector.<IProcess>
        {
            var processList:Vector.<IProcess> = new <IProcess>[];
            var appList:Array = rawProcesses.split("\t");
            var length:int = appList.length;
            var process:IProcess;
            var appInfoList:Array;

            for (var i:int = 0; i < length; i++)
            {
                appInfoList = appList[i].split("$");

                process = new Process();

                process.type = appInfoList[0];
                process.name = appInfoList[1];
                process.path = appInfoList[2];

                if (!process.path)
                {
                    continue;
                }

                processList.push(process);
            }

            return processList;
        }

        public function get processList():Vector.<IProcess>
        {
            return _processList;
        }

        public function has(process:IProcess):Boolean
        {
            return Boolean(_processMap[process.id]);
        }
    }
}
