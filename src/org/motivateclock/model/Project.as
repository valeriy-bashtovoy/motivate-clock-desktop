package org.motivateclock.model
{

    import flash.events.EventDispatcher;

    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProcessModel;
    import org.motivateclock.interfaces.IProject;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Project extends EventDispatcher implements IProject
    {
        private var _name:String;
        private var _id:String;
        private var _date:Date;
        private var _isCurrent:Boolean = false;
        private var _isChanged:Boolean = false;

        private var _workTime:Number = 0;
        private var _restTime:Number = 0;
        private var _idleTime:Number = 0;

        private var _processModel:IProcessModel;
        private var _isAuto:Boolean = true;

        public function Project()
        {
            _processModel = new ProcessModel();
        }

        public function equals(project:Project):Boolean
        {
            return project && _id == project.id;
        }

        public function reset():void
        {
            _restTime = 0;
            _workTime = 0;
            _idleTime = 0;

            _isChanged = true;

            if(_processModel.currentProcess)
                _processModel.currentProcess.clear();
        }

        public function get isManual():Boolean
        {
            return _id == ProjectsModel.MANUAL_MODE;
        }

        public function set isChanged(value:Boolean):void
        {
            _isChanged = value;
        }

        public function get isChanged():Boolean
        {
            return _isChanged;
        }

        public function set isCurrent(value:Boolean):void
        {
            if (_isCurrent == value)
            {
                return;
            }

            _isChanged = true;

            _isCurrent = value;
        }

        public function get isCurrent():Boolean
        {
            return _isCurrent;
        }

        public function set creationDate(value:Date):void
        {
            _date = value;
        }

        public function get creationDate():Date
        {
            return _date;
        }

        public function set workTime(value:Number):void
        {
            _workTime = value;

            _isChanged = true;

            dispatchEvent(new ModelEvent(ModelEvent.PROJECT_TIME_CHANGE));
        }

        public function get workTime():Number
        {
            return _workTime;
        }

        public function set restTime(value:Number):void
        {
            _restTime = value;

            _isChanged = true;

            dispatchEvent(new ModelEvent(ModelEvent.PROJECT_TIME_CHANGE));
        }

        public function get restTime():Number
        {
            return _restTime;
        }

        public function set idleTime(value:Number):void
        {
            _idleTime = value;

            _isChanged = true;
        }

        public function get idleTime():Number
        {
            return _idleTime;
        }

        public function set id(value:String):void
        {
            _id = value;
        }

        public function get id():String
        {
            return _id;
        }

        public function set name(value:String):void
        {
            _name = value;
            _isChanged = true;
        }

        public function get name():String
        {
            return _name;
        }

        public function set applications(value:String):void
        {
            _isChanged = true;
            _processModel.initialize(value);
        }

        public function get applications():String
        {
            return _processModel.serialize(_processModel.processList);
        }

        public function get processModel():IProcessModel
        {
            return _processModel;
        }

        public function updateProjectMode():void
        {
            isAuto = _processModel.processList.length != 0;
        }

        public function set isAuto(value:Boolean):void
        {
            _isAuto = value;

            _isChanged = true;

            dispatchEvent(new ModelEvent(ModelEvent.PROJECT_MODE_CHANGE));
        }

        public function get isAuto():Boolean
        {
            return _isAuto;
        }

        override public function toString():String
        {
            return "id: " + _id + ", name: " + _name + ", isCurrent: " + _isCurrent + ", isChanged: " + _isChanged + "\n";
        }
    }
}
