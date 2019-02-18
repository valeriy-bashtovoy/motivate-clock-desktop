package org.motivateclock.view.clock
{

    import flash.display.MovieClip;
    import flash.events.Event;

    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class FlipperView extends MovieClip
    {

        private var tempTime:String = "<b>00</b>";

        private var _isFlipped:Boolean = true;
        private var _gfx:MovieClip;

        public function FlipperView(gfx:String)
        {
            _gfx = RegularUtils.getInstanceFromLib(gfx) as MovieClip;
            addChild(_gfx);

            _gfx.addEventListener(Event.CHANGE, changeHandler, false, 0, true);

            changeHandler();
        }

        public function startFlip():void
        {
            _isFlipped = true;
            _gfx.gotoAndPlay(2);
        }

        public function stopFlip():void
        {
            _isFlipped = false;
        }

        public function setTime(time:String):void
        {
            time = "<b>" + time + "</b>";

            if (time == tempTime)
            {
                return;
            }

            tempTime = time;

            if (_isFlipped)
            {
                _gfx.gotoAndPlay(2);
            }
        }

        private function changeHandler(event:Event = null):void
        {
            _gfx.flipTime = tempTime;
        }
    }
}
