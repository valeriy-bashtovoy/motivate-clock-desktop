package org.motivateclock.model
{

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    import org.motivateclock.events.ModelEvent;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    [Event(name="clock_tick", type="org.motivateclock.events.ModelEvent")]
    public class ClockModel extends EventDispatcher
    {
        private static const TICK_TIME:int = 1000;

        private var _timer:Timer;
        private var _time:int;

        public function ClockModel()
        {
        }

        public function initialize():void
        {
            _time = getTimer();

            _timer = new Timer(TICK_TIME);
            _timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
            _timer.start();
        }

        public function tick():void
        {
            if (!_timer.running)
            {
                trace("Warning.", this + " isn't running;");
                return;
            }

            var e:ModelEvent = new ModelEvent(ModelEvent.CLOCK_TICK);
            e.timeRange = (getTimer() - _time) / 1000;
            dispatchEvent(e);

            //trace(this, "timeRange:", e.timeRange );

            _time = getTimer();
        }

        public function stop():void
        {
            _timer.stop();
        }

        public function start():void
        {
            _time = getTimer();
            _timer.start();
        }

        private function timerHandler(event:TimerEvent):void
        {
            tick();
        }
    }
}
