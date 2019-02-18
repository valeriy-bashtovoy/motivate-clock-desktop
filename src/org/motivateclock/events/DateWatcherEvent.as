/**
 * User: Valeriy Bashtovoy
 * Date: 07.06.2014
 */
package org.motivateclock.events
{

    import flash.events.Event;

    public class DateWatcherEvent extends Event
    {
        public static var CHANGE:String = "change";

        private var _data:Object;

        public function DateWatcherEvent(type:String, bubbles:Boolean = false, data:Object = null)
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
