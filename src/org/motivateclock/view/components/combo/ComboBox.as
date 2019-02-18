package org.motivateclock.view.components.combo
{

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;

    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ComboBox extends MovieClip
    {
        private static const BASE_DROP_PANEL_HEIGHT:int = 99;

        private var _trackButton:MovieClip;
        private var _openButton:MovieClip;

        private var _track:MovieClip;
        private var _stateField:TextField;
        private var _shadowBack:MovieClip;
        private var _backing:MovieClip;
        private var _dropPanel:MovieClip;
        private var _startY:int;
        private var _contentHolder:Sprite;
        private var _scrollStep:int;
        private var _trackIndent:int;
        private var _mask:Sprite;
        private var _newY:int;
        private var _percent:Number;
        private var _limitRect:Rectangle;
        private var _lastY:Number;
        private var _isScrollable:Boolean;
        private var _gfx:MovieClip;
        private var _data:String;
        private var _itemRendererList:Vector.<ComboItemRenderer> = new Vector.<ComboItemRenderer>;

        public function ComboBox(scrollStep:int = 10, trackIndent:int = 10)
        {
            _trackIndent = trackIndent;
            _scrollStep = scrollStep;
        }

        override public function get height():Number
        {
            return _stateField.height;
        }

        public function init():void
        {
            if (_contentHolder)
            {
                return;
            }

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_COMBO_BOX) as MovieClip;
            addChild(_gfx);

            _trackButton = _gfx["trackButton"];
            _track = _gfx["track"];
            _stateField = _gfx["stateField"];
            _shadowBack = _gfx["shadowBack"];
            _openButton = _gfx["openButton"];
            _backing = _gfx["backing"];
            _dropPanel = _gfx["dropPanel"];

            _contentHolder = new Sprite();
            _contentHolder.x = _stateField.x - 4;
            _gfx.addChildAt(_contentHolder, _gfx.getChildIndex(_track));

            _mask = new Sprite();
            _mask.y = _stateField.y + _stateField.height;
            _mask.graphics.beginFill(0x616161, 1);
            _mask.graphics.drawRect(0, 0, width, height);
            _gfx.addChild(_mask);

            _contentHolder.mask = _mask;

            _contentHolder.visible = false;
            _track.visible = false;
            _trackButton.visible = false;

            addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
            _trackButton.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
            _track.addEventListener(MouseEvent.CLICK, mouseClickHandler);

            _shadowBack.visible = false;
            _shadowBack.mouseChildren = false;
            _shadowBack.mouseEnabled = false;

            _openButton.buttonMode = true;
            _openButton.addEventListener(MouseEvent.MOUSE_OVER, openButton_mouseHandler);
            _openButton.addEventListener(MouseEvent.MOUSE_OUT, openButton_mouseHandler);

            clear();
            close();
            reset();

            addEventListener(MouseEvent.CLICK, clickHandler);
        }

        private function open():void
        {
            setShowState(true);
            stage.addEventListener(MouseEvent.CLICK, stageClickHandler);
        }

        private function close():void
        {
            setShowState(false);
            try
            {
                stage.removeEventListener(MouseEvent.CLICK, stageClickHandler);
            }
            catch (error:Error)
            {
            }
        }

        public function reset():void
        {
            if (!_contentHolder)
            {
                return;
            }

            _contentHolder.y = 0;
            _trackButton.y = _mask.y;
            _newY = 0;
            _percent = 0;
        }

        public function update():void
        {
            _mask.height = _dropPanel.height - 31;
            _track.height = _mask.height - 1;

            _limitRect = new Rectangle(0, _mask.y, 0, _track.height - _trackButton.height);

            _isScrollable = scrollNum > 0;

            if (!_isScrollable)
            {
                reset();
            }

            moveContent();

            moveTrack();
        }

        public function clear():void
        {
            _startY = _mask.y + 4;
            RegularUtils.removeAllChildren(_contentHolder);
            _itemRendererList = new <ComboItemRenderer>[];
        }

        private function get scrollNum():uint
        {
            return Math.max(0, _contentHolder.numChildren - Math.floor(_mask.height / _scrollStep));
        }

        private function moveTrack():void
        {
            if (!_isScrollable)
            {
                return;
            }

            _trackButton.y = _limitRect.y + _limitRect.height * _percent;
        }

        private function moveContent():void
        {
            if (!_isScrollable)
            {
                return;
            }

            _newY = Math.min(0, _newY);
            _newY = Math.max(-scrollNum * _scrollStep, _newY);

            _percent = Math.abs(_newY / (scrollNum * _scrollStep));

            _contentHolder.y = _newY;

            dispatchEvent(new Event(Event.CHANGE));
        }

        public function addItem(itemRenderer:DisplayObject, yDistance:int):void
        {
            itemRenderer.y = _startY;

            _itemRendererList.push(itemRenderer);

            _contentHolder.addChild(itemRenderer);

            var h:int = _startY + yDistance + 8;

            if (h < BASE_DROP_PANEL_HEIGHT)
            {
                _dropPanel.height = h;
            }
            else
            {
                _dropPanel.height = BASE_DROP_PANEL_HEIGHT;
            }

            _startY += yDistance;

            update();
        }

        public function setSize(newWidth:int):void
        {
            _stateField.width = newWidth - 20;

            _backing.width = newWidth;
            _openButton.x = _backing.width - 10;
            _dropPanel.width = _backing.width + 7;

            _track.x = _backing.width - 3;
            _trackButton.x = _track.x;

            update();
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            var trackY:int = mouseY;

            trackY = Math.max(_limitRect.top, trackY);
            trackY = Math.min(_limitRect.bottom, trackY);

            _trackButton.y = trackY;

            _newY = -Math.round(scrollNum * ((_trackButton.y - _mask.y) / _limitRect.height)) * _scrollStep;

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

            _newY = -Math.round(scrollNum * ((_trackButton.y - _mask.y) / _limitRect.height)) * _scrollStep;

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

        private function stageClickHandler(event:MouseEvent):void
        {
            var target:Object = event.target;

            if (target == _stateField || target == _openButton || target == _trackButton || target == _track)
            {
                return;
            }

            close();
        }

        private function clickHandler(event:MouseEvent):void
        {
            var target:Object = event.target;

            if (target == _stateField || target == _openButton)
            {
                if (_dropPanel.visible)
                {
                    close();
                }
                else
                {
                    open();
                }
            }

            if (target is ComboItemRenderer)
            {
                close();
                selectItemByData(ComboItemRenderer(target).data);
            }
        }

        private function setShowState(state:Boolean):void
        {
            _dropPanel.visible = state;
            _contentHolder.visible = state;

            _trackButton.visible = false;
            _track.visible = false;

            if (state && _isScrollable)
            {
                _trackButton.visible = true;
                _track.visible = true;
            }
        }

        public function selectItemByData(data:String):void
        {
            for each (var itemRenderer:ComboItemRenderer in _itemRendererList)
            {
                if (itemRenderer.data != data)
                {
                    continue;
                }

                itemRenderer.highlight();

                _stateField.text = RegularUtils.truncateString(_stateField, itemRenderer.label);

                _data = itemRenderer.data;

                var e:McEvent = new McEvent(McEvent.ITEM_SELECTED);
                e.data = _data;
                dispatchEvent(e);

                return;
            }
        }

        public function get data():String
        {
            return _data;
        }

        public function get openButton():DisplayObjectContainer
        {
            return _openButton;
        }

        public function get trackButton():DisplayObjectContainer
        {
            return _trackButton;
        }

        public function get track():DisplayObjectContainer
        {
            return _track;
        }

        private function openButton_mouseHandler(event:MouseEvent):void
        {
            _openButton.gotoAndStop(event.type == MouseEvent.MOUSE_OVER ? 2 : 1);
        }
    }
}
