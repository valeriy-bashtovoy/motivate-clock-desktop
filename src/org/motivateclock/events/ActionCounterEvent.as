/**
 * User: Valeriy Bashtovoy
 * Date: 12/5/2014
 */
package org.motivateclock.events
{

    import flash.events.Event;

    public class ActionCounterEvent extends Event
    {
        public static const PASS:String = "pass";

        public var action:String = "";
        public var complete:Boolean = false;

        public function ActionCounterEvent(action:String, complete:Boolean)
        {
            this.action = action;
            this.complete = complete;

            super(ActionCounterEvent.PASS, false, false);
        }
    }
}
