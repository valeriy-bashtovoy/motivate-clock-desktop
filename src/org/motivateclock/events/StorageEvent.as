/**
 * User: Valeriy Bashtovoy
 * Date: 03.06.2014
 */
package org.motivateclock.events
{

    import flash.events.Event;

    public class StorageEvent extends Event
    {
        public static var COMPLETE:String = "complete";
        public static var ERROR:String = "error";

        private var _data:Object;

        public function StorageEvent(type:String, bubbles:Boolean = false, data:Object = null)
        {
            _data = data;

            super(type, bubbles, false);
        }

        public function get data():Object
        {
            return _data;
        }
    }
}
