package org.motivateclock.view.setting
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Slider extends Sprite
    {
        private var _trackButton:MovieClip;
        private var _background:MovieClip;
        private var _track:MovieClip;
        private var _hitLayer:MovieClip;
        private var _dragRect:Rectangle;
        private var _scrollRect:Rectangle;
        private var _percent:Number;
        private var _gfx:MovieClip;

        public function Slider()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_SLIDER) as MovieClip;
            addChild(_gfx);

            _trackButton = _gfx["trackButton"];
            _background = _gfx["background"];
            _track = _gfx["track"];
            _hitLayer = _gfx["hitLayer"];

            _trackButton.mouseChildren = false;

            _dragRect = new Rectangle(0, 0, _track.width - _trackButton.width + 4, 0);

            _scrollRect = new Rectangle(0, 0, 0, _track.height);
            _background.scrollRect = _scrollRect;

            _trackButton.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler, false, 0, true);
            _trackButton.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler, false, 0, true);
            _trackButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler, false, 0, true);
            _hitLayer.addEventListener(MouseEvent.CLICK, mouseHandler, false, 0, true);
            _background.addEventListener(MouseEvent.CLICK, mouseHandler, false, 0, true);

            addEventListener(Event.ADDED_TO_STAGE, stageAddedHandler, false, 0, true);
            addEventListener(Event.REMOVED_FROM_STAGE, stageRemoveHandler, false, 0, true);
        }

        private function stageRemoveHandler(event:Event):void
        {
            dispose();
        }

        public function dispose():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

            _dragRect = null;
            _scrollRect = null;
            _trackButton = null;
            _hitLayer = null;
            _track = null;
        }

        public function set percent(value:Number):void
        {
            _percent = value;
            _trackButton.x = _percent * _dragRect.width;
            updateBackgroud();
        }

        public function get percent():Number
        {
            return _percent;
        }

        private function updateBackgroud():void
        {
            _scrollRect.width = _trackButton.x;
            _background.scrollRect = _scrollRect;
        }

        private function stageAddedHandler(event:Event):void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
        }

        private function mouseHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    _trackButton.gotoAndStop(2);
                    break;
                case MouseEvent.MOUSE_OUT:
                    _trackButton.gotoAndStop(1);
                    break;
                case MouseEvent.MOUSE_DOWN:
                    stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
                    _trackButton.startDrag(false, _dragRect);
                    break;
                case MouseEvent.MOUSE_UP:
                    stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
                    _trackButton.stopDrag();
                    break;
                case MouseEvent.CLICK:
                    var x:int = mouseX;
                    x = Math.max(0, x);
                    x = Math.min(_dragRect.width, x);
                    _trackButton.x = x;
                    mouseMoveHandler();
                    break;
            }
        }

        private function mouseMoveHandler(event:MouseEvent = null):void
        {
            updateBackgroud();

            _percent = _trackButton.x / _dragRect.width;

            dispatchEvent(new Event(Event.CHANGE));

            if (event)
            {
                event.updateAfterEvent();
            }
        }

        public function get background():MovieClip
        {
            return _background;
        }

        public function get track():MovieClip
        {
            return _track;
        }

        public function get trackButton():MovieClip
        {
            return _trackButton;
        }
    }
}
