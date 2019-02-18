package org.motivateclock.model.statistic
{

    import flash.events.EventDispatcher;

    import org.motivateclock.model.Process;
    import org.motivateclock.model.Project;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatDay extends EventDispatcher
    {

        private var _date:String;
        private var _workAppCollection:Array = [];
        private var _restAppCollection:Array = [];
        private var _project:Project;
        private var _restTime:Number = 0;
        private var _workTime:Number = 0;
        private var _dateArray:Array;

        public function StatDay(project:Project)
        {
            _project = project;
        }

        public function get workTime():int
        {
            return _workTime;
        }

        public function get restTime():int
        {
            return _restTime;
        }

        public function get workApp():Array
        {
            return _workAppCollection;
        }

        public function get restApp():Array
        {
            return _restAppCollection;
        }

        public function addApplication(app:Object):void
        {
            var exist:Boolean = _project.processModel.has(new Process('', '', app.appPath));

            if (!exist)
            {
                _restTime += app.time;
                _restAppCollection.push(app);
            }
            else
            {
                _workTime += app.time;
                _workAppCollection.push(app);
            }
        }

        public function get day():int
        {
            return _dateArray[2];
        }

        public function get month():int
        {
            return _dateArray[1];
        }

        public function get year():int
        {
            return _dateArray[0];
        }

        public function set date(value:String):void
        {
            _date = value;
            _dateArray = _date.split("-");
        }

        public function get date():String
        {
            return _date;
        }
    }
}
