package org.motivateclock.view.components
{

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import org.motivateclock.interfaces.IIconViewer;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Scroll extends Sprite
    {
        private var _track:MovieClip;
        private var _trackButton:MovieClip;
        private var _mask:Sprite;
        private var _contentHolder:DisplayObjectContainer;
        private var _newY:int;
        private var _hitArea:Sprite;
        private var _lastY:Number;
        private var _limitRect:Rectangle;
        private var _percent:Number;
        private var _scrollStep:int;
        private var _lastPercent:Number;
        private var _itemRendererCollection:Array;
        private var _viewedItems:int;
        private var _showIconTimer:Timer;
        private var _scroll:MovieClip;

        public function Scroll(width:int, height:int, scrollStep:int, trackIndent:int = 10)
        {
            _scrollStep = scrollStep;

            _scroll = RegularUtils.getInstanceFromLib("common.mocloscroll") as MovieClip;
            addChild(_scroll);

            _trackButton = _scroll.getChildByName("trackButton") as MovieClip;
            _track = _scroll.getChildByName("track") as MovieClip;

            _mask = new Sprite();
            _mask.graphics.beginFill(0x616161, 1);
            _mask.graphics.drawRect(0, 0, width, height);
            addChild(_mask);

            _hitArea = new Sprite();
            _hitArea.graphics.beginFill(0x000000, 0);
            _hitArea.graphics.drawRect(0, 0, width, height);
            addChildAt(_hitArea, 0);

            _showIconTimer = new Timer(150, 1);
            _showIconTimer.addEventListener(TimerEvent.TIMER, showIconTimerHandler);

            setSize(height);

            _track.x = width + trackIndent;
            _trackButton.x = _track.x;

            _trackButton.useHandCursor = false;

            _track.visible = false;
            _trackButton.visible = false;

            addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
            _trackButton.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
            _track.addEventListener(MouseEvent.CLICK, mouseClickHandler);
        }

        override public function get height():Number
        {
            if (_contentHolder)
            {
                return Math.min(_contentHolder.height, _mask.height);
            }
            else
            {
                return super.height;
            }
        }

        public function set itemRendererCollection(value:Array):void
        {
            _itemRendererCollection = value;
            showItemRenderers();
            showIconTimerHandler();
        }

        private function showItemRenderers():void
        {
            if (!_itemRendererCollection)
            {
                return;
            }

            _showIconTimer.stop();
            _showIconTimer.start();

            if (_percent < _lastPercent)
            {
                return;
            }

            _lastPercent = _percent;

            var itemRenderer:IIconViewer;
            var viewItems:int = Math.ceil(_itemRendererCollection.length * _percent);
            viewItems += Math.ceil(this.height / _scrollStep);

            for (var i:int = _viewedItems; i < viewItems; i++)
            {
                itemRenderer = _itemRendererCollection[i] as IIconViewer;
                if (itemRenderer)
                {
                    _contentHolder.addChild(DisplayObject(itemRenderer));
                    //					itemRenderer.showIcon();
                }
            }

            _viewedItems = viewItems;
        }

        private function showIconTimerHandler(event:TimerEvent = null):void
        {
            if (!_itemRendererCollection)
            {
                return;
            }

            var numVisible:int = Math.round(this.height / _scrollStep);
            var startIndex:int = Math.round(scrollNum * _percent);
            var endIndex:int = startIndex + numVisible;
            var itemRenderer:IIconViewer;

            for (var i:int = startIndex; i < endIndex; i++)
            {
                itemRenderer = _itemRendererCollection[i] as IIconViewer;
                if (itemRenderer)
                {
                    itemRenderer.showIcon();
                }
            }
        }

        public function setContent(target:DisplayObjectContainer):void
        {
            _contentHolder = target;
            _contentHolder.x = 0;
            _contentHolder.y = 0;
            _contentHolder.mask = _mask;
            addChildAt(_contentHolder, 1);//this.getChildIndex(_track));
        }

        public function get percent():Number
        {
            return _percent;
        }

        public function set contentHeight(value:int):void
        {
            var holder:Sprite = Sprite(_contentHolder);
            holder.graphics.clear();
            holder.graphics.beginFill(0x0, 0);
            holder.graphics.drawRect(0, 0, 1, value);
        }

        public function get contentHeight():int
        {
            return Math.floor(_contentHolder.height / _scrollStep) * _scrollStep;
        }

        public function reset():void
        {
            if (!_contentHolder)
            {
                return;
            }

            _trackButton.y = 0;
            _contentHolder.y = 0;
            _newY = 0;
            _percent = 0;
            _viewedItems = 0;
            _lastPercent = 0;
            _itemRendererCollection = [];
        }

        public function update():void
        {
            _track.visible = scrollNum > 0;
            _trackButton.visible = _track.visible;

            if (!_track.visible)
            {
                reset();
            }

            moveContent();
            moveTrack();
        }

        private function get scrollNum():int
        {
            return Math.round((_contentHolder.height - _mask.height) / _scrollStep);
        }

        private function moveTrack():void
        {
            if (!_track.visible)
            {
                return;
            }
            _trackButton.y = _limitRect.y + _limitRect.height * _percent;
        }

        private function moveContent():void
        {
            if (!_track.visible)
            {
                return;
            }

            _newY = Math.min(0, _newY);
            _newY = Math.max(-scrollNum * _scrollStep, _newY);

            _percent = Math.abs(_newY / (scrollNum * _scrollStep));

            _contentHolder.y = _newY;

            dispatchEvent(new Event(Event.CHANGE));

            showItemRenderers();
        }

        public function setSize(newHeight:int):void
        {
            _mask.height = newHeight;
            _hitArea.height = _mask.height;
            _track.height = _mask.height;//6;

            _limitRect = new Rectangle(0, _track.y, 0, _track.y + _track.height - _trackButton.height + 2);

            reset();
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            var trackY:int = mouseY;

            trackY = Math.max(_limitRect.top, trackY);
            trackY = Math.min(_limitRect.bottom, trackY);

            _trackButton.y = trackY;

            _newY = -Math.round(scrollNum * (_trackButton.y / _limitRect.height)) * _scrollStep;

            moveContent();
        }

        private function trackDownHandler(event:MouseEvent):void
        {
            _lastY = mouseY;
            stage.addEventListener(MouseEvent.MOUSE_UP, trackUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        private function mouseMoveHandler(event:MouseEvent):void
        {
            var trackY:int = _trackButton.y - int(_lastY - mouseY);

            trackY = Math.max(_limitRect.top, trackY);
            trackY = Math.min(_limitRect.bottom, trackY);

            _trackButton.y = trackY;

            _lastY = mouseY;

            _newY = -Math.round(scrollNum * (_trackButton.y / _limitRect.height)) * _scrollStep;

            event.updateAfterEvent();

            moveContent();
        }

        private function trackUpHandler(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, trackUpHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        private function mouseWheelHandler(event:MouseEvent):void
        {
            _newY += _scrollStep * int(event.delta / Math.abs(event.delta));
            moveContent();
            moveTrack();
        }

        public function get trackButton():MovieClip
        {
            return _trackButton;
        }

        public function get track():MovieClip
        {
            return _track;
        }
    }
}
