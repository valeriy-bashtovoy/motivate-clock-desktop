/**
 * Created by Valeriy on 23.11.2014.
 */
package org.motivateclock.model
{

    import flash.events.EventDispatcher;

    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.vo.ProcessVO;

    public class Process extends EventDispatcher implements IProcess
    {
        private var _type:String;
        private var _id:String;
        private var _name:String;
        private var _path:String;
        private var _time:Number = 0;
        private var _isMarked:Boolean = false;

        public static function convert(processVO:ProcessVO):IProcess
        {
            var process:IProcess = new Process(processVO.type, processVO.label, processVO.path, processVO.seconds);
            return process;
        }

        public function Process(type:String = "", name:String = "", path:String = "", time:Number = 0)
        {
            _type = type;
            _name = name;
            _path = path;
            _time = time;
        }

        public function get id():String
        {
            if (!_id)
            {
                createId();
            }

            return _id;
        }

        private function createId():void
        {
            _id = _path.replace(/\W/ig, "");
        }

        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
        }

        public function get path():String
        {
            return _path;
        }

        public function set path(value:String):void
        {
            _path = value;
        }

        public function get time():Number
        {
            return _time;
        }

        public function set time(value:Number):void
        {
            _time = value;
            dispatchEvent(new ModelEvent(ModelEvent.PROCESS_TIME_CHANGE));
        }

        override public function toString():String
        {
            return _path;
        }

        public function serialize():String
        {
            return _type + "$" + _name + "$" + _path + "\t";
        }

        public function get isMarked():Boolean
        {
            return _isMarked;
        }

        public function set isMarked(value:Boolean):void
        {
            _isMarked = value;
        }

        public function increaseTime(time:Number):void
        {
            _time += time;
            dispatchEvent(new ModelEvent(ModelEvent.PROCESS_TIME_CHANGE));
        }

        public function clear():void
        {
            _time = 0;
        }

        public function get type():String
        {
            return _type;
        }

        public function set type(value:String):void
        {
            _type = value;
        }

        public function get isSite():Boolean
        {
            return _type == ProcessTypeEnum.SITE;
        }

        public function clone():IProcess
        {
            return new Process(_type, _name, _path, _time);
        }
    }
}
