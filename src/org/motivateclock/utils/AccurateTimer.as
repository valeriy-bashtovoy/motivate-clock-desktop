package org.motivateclock.utils
{

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
     * @author: Valeriy Bashtovoy
     *
     *
     * org.motivateclock.common.AccurateTimer
     */
    public class AccurateTimer extends Timer
    {

        private var m_delay:Number = 0;
        private var m_lastTime:Date;
        private var m_accuracy:uint = 10;
        private var m_nCount:uint;
        private var m_nCurrentCount:uint;

        override public function get delay():Number
        {
            return m_delay;
        }

        override public function set delay(value:Number):void
        {
            m_delay = value;
        }

        override public function get currentCount():int
        {
            return m_nCurrentCount;
        }

        override public function get repeatCount():int
        {
            return m_nCount;
        }

        override public function set repeatCount(value:int):void
        {
            m_nCount = value;
        }

        public function get accuracy():uint
        {
            return m_accuracy;
        }

        public function set accuracy(value:uint):void
        {
            m_accuracy = value;
        }

        public function AccurateTimer(nDelay:Number, nCount:uint)
        {
            m_delay = nDelay;
            m_nCount = nCount;
            addEventListener(TimerEvent.TIMER, ontmrTick, false, 0, true);
            super(m_accuracy, 0);
        }

        override public function start():void
        {
            m_lastTime = new Date();
            m_lastTime.time = new Date().time + m_delay;
            super.start();
        }

        override public function stop():void
        {
            super.stop();
        }

        override public function reset():void
        {
            m_nCount = 0;
            m_nCurrentCount = 0;
            super.reset();
        }

        private function ontmrTick(evnt:TimerEvent):void
        {
            var nNewTime:Date = new Date();

            if ((nNewTime.time > m_lastTime.time) || (m_lastTime.time - nNewTime.time < m_accuracy / 2) || (nNewTime.time == m_lastTime.time))
            {
                m_lastTime.time = m_lastTime.time + m_delay;

                if (0 < m_nCount)
                {
                    m_nCurrentCount = m_nCurrentCount + 1;

                    if (m_nCount == m_nCurrentCount)
                    {
                        dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
                        reset();
                        evnt.stopImmediatePropagation();
                    }
                }
            }
            else
            {
                evnt.stopImmediatePropagation();
            }
        }
    }
}
