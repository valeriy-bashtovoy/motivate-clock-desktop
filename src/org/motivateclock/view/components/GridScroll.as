package org.motivateclock.view.components
{

    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class GridScroll extends Sprite
    {

        private var _trackButton:Sprite;
        private var _track:MovieClip;
        private var _hitArea:Sprite;
        private var _percent:Number;
        private var _updateTimer:Timer;
        private var _scrollGfx:MovieClip;
        private var _limitRect:Rectangle;
        private var _trackYDiff:Number;
        private var _contentHolder:DisplayObjectContainer;
        private var _minTrackButtonHeight:int;
        private var _dynamicTrackButtonHeight:Boolean = true;
        // base wheel step = 1%;
        private var _wheelStep:Number = 0.1;

        /**
         * updateTime - measured in sec;
         */
        public function GridScroll(updateTime:int = 1, minTrackButtonHeight:int = 20)
        {
            _minTrackButtonHeight = minTrackButtonHeight;
            _scrollGfx = RegularUtils.getInstanceFromLib("common.mocloscroll") as MovieClip;
            addChild(_scrollGfx);

            _trackButton = _scrollGfx.getChildByName("trackButton") as Sprite;
            _track = _scrollGfx.getChildByName("track") as MovieClip;

            _hitArea = new Sprite();
            _hitArea.graphics.beginFill(0x000000, 0);
            _hitArea.graphics.drawRect(0, 0, 5, 5);
            addChildAt(_hitArea, 0);

            _trackButton.mouseChildren = false;

            _updateTimer = new Timer(updateTime * 60, 1);
            _updateTimer.addEventListener(TimerEvent.TIMER, updateTimerHandler, false, 0, true);

            _trackButton.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler, false, 0, true);
            _track.addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);

            this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
        }

        public function set dynamicTrackButtonHeight(value:Boolean):void
        {
            _dynamicTrackButtonHeight = value;
        }

        public function set displayTrack(value:Boolean):void
        {
            _scrollGfx.visible = value;
        }

        /**
         * need only for mouse wheel;
         */
        public function setContent(target:DisplayObjectContainer):void
        {
            _contentHolder = target;
            _contentHolder.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
            addChildAt(_contentHolder, 1);
        }

        public function update(contentHeight:int, wheelStep:Number):void
        {
            _wheelStep = wheelStep;

            if (_dynamicTrackButtonHeight)
                _trackButton.height = Math.max(_track.height * (_track.height / contentHeight), _minTrackButtonHeight);

            _limitRect = new Rectangle(0, _track.y, 0, _track.y + _track.height - _trackButton.height);

            reset();
        }

        public function setSize(width:int, height:int):void
        {
            _hitArea.height = height;
            _hitArea.width = width;

            _track.height = height;

            _scrollGfx.x = width;

            _limitRect = new Rectangle(0, _track.y, 0, _track.y + _track.height - _trackButton.height);

            reset();
        }

        private function updateTimerHandler(event:TimerEvent = null):void
        {
            if (!_scrollGfx.visible)
            {
                return;
            }

            dispatchEvent(new Event(Event.CHANGE));
        }

        public function set percent(value:Number):void
        {
            updatePercent(value);
            moveTrack();
        }

        public function get percent():Number
        {
            return _percent;
        }

        public function reset():void
        {
            _trackButton.y = 0;
            _percent = 0;
        }

        private function updatePercent(percent:Number):void
        {
            percent = Math.min(percent, 1);
            percent = Math.max(percent, 0);

            if (_percent == percent)
            {
                return;
            }

            _percent = percent;

            _updateTimer.stop();
            _updateTimer.start();
        }

        private function moveTrack():void
        {
            _trackButton.y = _limitRect.y + _limitRect.height * _percent;
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            updatePercent(mouseY / _limitRect.height);
            moveTrack();
        }

        private function trackDownHandler(event:MouseEvent):void
        {
            _trackYDiff = _trackButton.y - mouseY;

            stage.addEventListener(MouseEvent.MOUSE_UP, trackUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        private function mouseMoveHandler(event:MouseEvent):void
        {
            updatePercent((mouseY + _trackYDiff) / _limitRect.height);
            moveTrack();

            event.updateAfterEvent();
        }

        private function trackUpHandler(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, trackUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        private function mouseWheelHandler(event:MouseEvent):void
        {
            var direction:int = -event.delta / Math.abs(event.delta);

            //var wheelStep:Number = Math.min( (getTimer() - _wheelTime) / 100, 1 );
            //trace(this, "wheelStep:", wheelStep, _wheelStep * ( 1 + (1 + wheelStep) ) );
            //_wheelTime = getTimer();

            updatePercent(_percent + _wheelStep * direction);

            moveTrack();

            event.updateAfterEvent();
        }

        public function dispose():void
        {
            _updateTimer.stop();
            _updateTimer.removeEventListener(TimerEvent.TIMER, updateTimerHandler);
            _updateTimer = null;

            _trackButton.removeEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
            _track.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
            this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
        }

        public function get trackButton():Sprite
        {
            return _trackButton;
        }

        public function get track():MovieClip
        {
            return _track;
        }
    }
}
