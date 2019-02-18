/**
 * Created by Valeriy Bashtovoy on 28.08.2015.
 */
package org.motivateclock.events
{

    import flash.events.Event;

    public class StatisticViewEvent extends Event
    {
        public static const STATISTIC_SELECT:String = "statistic_select";

        public var projectId:String;
        public var category:String;
        public var range:String;

        public function StatisticViewEvent(type:String)
        {
            super(type, true, false);
        }

        override public function clone():Event
        {
            var event:StatisticViewEvent = new StatisticViewEvent(type);
            event.projectId = projectId;
            event.category = category;
            event.range = range;
            return event;
        }
    }
}
