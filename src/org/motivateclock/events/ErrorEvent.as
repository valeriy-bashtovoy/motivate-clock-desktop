/**
 * User: Valeriy Bashtovoy
 * Date: 15.06.2014
 */
package org.motivateclock.events
{

    import flash.events.Event;

    public class ErrorEvent extends Event
    {
        public static const ERROR:String = "error";

        public var version:String;
        public var message:String;
        public var stackTrace:String;

        public function ErrorEvent(type:String, bubbles:Boolean = false)
        {
            super(type, bubbles, false);
        }
    }
}
