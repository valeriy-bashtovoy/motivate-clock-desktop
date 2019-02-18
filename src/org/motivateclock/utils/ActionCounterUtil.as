/**
 * User: Valeriy Bashtovoy
 * Date: 12/5/2014
 */
package org.motivateclock.utils
{

    import flash.events.EventDispatcher;

    import org.motivateclock.events.ActionCounterEvent;

    public class ActionCounterUtil extends EventDispatcher
    {
        private var _numActions:int;
        private var _actionList:Vector.<String> = new <String>[];

        public function ActionCounterUtil(numActions:int)
        {
            _numActions = numActions;
        }

        public function pass(action:String):void
        {
            _actionList.push(action);

            dispatchEvent(new ActionCounterEvent(action, _numActions == _actionList.length));
        }
    }
}
