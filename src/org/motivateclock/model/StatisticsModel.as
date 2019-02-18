/**
 * Created by Valeriy Bashtovoy on 05.08.2015.
 */
package org.motivateclock.model
{

    import flash.events.EventDispatcher;

    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.interfaces.IStatisticsModel;

    public class StatisticsModel extends EventDispatcher implements IStatisticsModel
    {
        private var _processList:Vector.<IProcess> = new <IProcess>[];
        private var _currentProject:IProject;
        private var _map:Object = [];
        private var _currentProcess:IProcess;

        public function StatisticsModel()
        {
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

        public function set processList(value:Vector.<IProcess>):void
        {
            _processList = value ? value.sort(compare) : new <IProcess>[];

            _map = createMap(_processList);

            dispatchEvent(new ModelEvent(ModelEvent.STAT_LIST_CHANGE));
        }

        public function get processList():Vector.<IProcess>
        {
            return _processList;
        }

        private function compare(p1:IProcess, p2:IProcess):Number
        {
            if (p1.time > p2.time) return -1;

            if (p1.time < p2.time) return 1;

            return 0;
        }

        public function set currentProject(value:IProject):void
        {
            _currentProject = value;
        }

        public function get currentProject():IProject
        {
            return _currentProject;
        }

        public function hasProcess(process:IProcess):Boolean
        {
            return _map[process.id];
        }

        public function addProcess(process:IProcess):void
        {
            _processList.push(process);
            _map[process.id] = process;
            dispatchEvent(new ModelEvent(ModelEvent.STAT_LIST_CHANGE));
        }

        public function getProcess(id:String):IProcess
        {
            return _map[id];
        }

        public function set currentProcess(value:IProcess):void
        {
            _currentProcess = value;
        }

        public function get currentProcess():IProcess
        {
            return _currentProcess;
        }

        public function updateCurrentProcess(time:Number):void
        {
            _currentProcess.time = time;

            const index:int = _processList.indexOf(_currentProcess);

            if (index < 1)
                return;

            const process:IProcess = _processList[index - 1];

            if (_currentProcess.time <= process.time)
                return;

            _processList.splice(index, 1);
            _processList.splice(index - 1, 0, _currentProcess);

            dispatchEvent(new ModelEvent(ModelEvent.STAT_LIST_CHANGE));
        }
    }
}
