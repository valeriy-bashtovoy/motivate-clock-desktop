package org.motivateclock.view.setting
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.motivateclock.view.components.combo.ComboBox;
    import org.motivateclock.view.components.combo.ComboItemRenderer;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class SettingCheckBox extends MovieClip
    {
        private var _nameField:TextField;
        private var _check:MovieClip;
        private var _separator:MovieClip;
        private var _hitsArea:MovieClip;
        private var _icon:MovieClip;
        private var _valueField:TextField;
        private var _currentSliderValue:int;
        private var _slider:Slider;
        private var _maxSliderValue:int;
        private var _prefixList:Array = [];
        private var _postfixList:Array = [];
        private var _comboBox:ComboBox;
        private var _comboBoxData:String;
        private var _selectedData:*;
        private var _height:Number = 0;
        private var _comboBoxWidth:int;
        private var _gfx:MovieClip;

        public function SettingCheckBox()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_SETTING_CHECK_BOX) as MovieClip;
            addChild(_gfx);

            _nameField = _gfx["nameField"];
            _check = _gfx["check"];
            _separator = _gfx["separator"];
            _hitsArea = _gfx["hitsArea"];
            _icon = _gfx["icon"];
            _valueField = _gfx["timeField"];

            _check.visible = false;
            _hitsArea.buttonMode = true;
            _valueField.visible = false;
            _nameField.autoSize = TextFieldAutoSize.LEFT;
            _nameField.mouseWheelEnabled = false;
            _hitsArea.y = _nameField.y;

            _hitsArea.addEventListener(MouseEvent.CLICK, mouseHandler);
            _hitsArea.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
            _hitsArea.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
        }

        override public function get height():Number
        {
            return _height;//super.height;
        }

        public function get currentSliderValue():int
        {
            return _currentSliderValue;
        }

        public function get state():Boolean
        {
            return _check.visible;
        }

        public function set state(value:Boolean):void
        {
            _check.visible = value;
        }

        public function setLabel(lable:String):void
        {
            _nameField.htmlText = lable;
            _hitsArea.height = _nameField.height;

            updateHeight();
        }

        public function setTextColor(color:uint):void
        {
            _nameField.textColor = color;
        }

        public function showSeperator(value:Boolean):void
        {
            _separator.visible = value;
        }

        private function updateValueField():void
        {
            var prefix:String = _prefixList.length > 0 ? TimeUtils.getDeclensionNumberName(_currentSliderValue, _prefixList) + " " : "";
            var postfix:String = _postfixList.length > 0 ? TimeUtils.getDeclensionNumberName(_currentSliderValue, _postfixList) : "";

            _valueField.htmlText = prefix + "<font color='#0c0c0c'>" + _currentSliderValue + "</font> " + postfix;

            _valueField.visible = prefix || postfix;

            updateHeight();

            dispatchEvent(new Event(Event.CHANGE));
        }

        public function disableCheckboxMode():void
        {
            _check.visible = false;
            _hitsArea.visible = false;
            _icon.visible = false;
        }

        public function addComboBox(selectedData:*, width:int = 70):void
        {
            _selectedData = selectedData;
            _comboBoxWidth = width;

            _comboBox = new ComboBox();
            _comboBox.init();
            _comboBox.setSize(width);
            _comboBox.x = 16;
            addChild(_comboBox);//, this.numChildren - 1

            _comboBox.addEventListener(McEvent.ITEM_SELECTED, selectHandler);

            updateHeight();
        }

        public function clearComboBox():void
        {
            if (_comboBox)
            {
                _comboBox.clear();
            }
        }

        public function addComboBoxItem(name:String, data:*):void
        {
            if (!_comboBox)
            {
                return;
            }

            var item:ComboItemRenderer = new ComboItemRenderer(name, _comboBoxWidth - 6);
            item.data = data;
            _comboBox.addItem(item, item.height - 6);

            if (_selectedData == data)
            {
                _comboBox.selectItemByData(data);
                _comboBoxData = data;
            }
        }

        public function addSlider(maxValue:int, currentValue:int):void
        {
            _currentSliderValue = currentValue;
            _maxSliderValue = maxValue;

            _slider = new Slider();
            _slider.x = 22;
            _slider.percent = _currentSliderValue / _maxSliderValue;
            addChildAt(_slider, 0);

            _slider.addEventListener(Event.CHANGE, changeHandler);

            updateHeight();

            updateValueField();
        }

        public function set sliderPrefixList(value:Array):void
        {
            _prefixList = value;
            updateValueField();
        }

        public function set sliderPostfixList(value:Array):void
        {
            _postfixList = value;
            updateValueField();
        }

        private function updateHeight():void
        {
            _separator.y = _nameField.y + _nameField.height;

            if (_comboBox)
            {
                _comboBox.y = int(_nameField.y + _nameField.height - 2);
                _separator.y = _comboBox.y + _comboBox.height + 10;
            }

            if (_slider)
            {
                _slider.y = int(_nameField.y + _nameField.height + 7);

                if (_comboBox)
                    _slider.y = _comboBox.y + _comboBox.height + 17;

                _valueField.y = _valueField.visible ? (_slider.y + _slider.height - 5) : _slider.y;
                _separator.y = _valueField.y + _valueField.height + 1;
            }

            _height = (_separator.y + _separator.height);
        }

        public function get comboBoxData():String
        {
            return _comboBoxData;
        }

        private function selectHandler(event:McEvent):void
        {
            _comboBoxData = event.data;
            dispatchEvent(new Event(Event.CHANGE));
        }

        private function changeHandler(event:Event):void
        {
            _currentSliderValue = int(_maxSliderValue * _slider.percent);
            _currentSliderValue = Math.max(1, _currentSliderValue);
            updateValueField();
        }

        private function mouseHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    Tweener.addTween(_icon, {_brightness: 0.25, time: 0.5});
                    Tweener.addTween(_check, {_brightness: 0.25, time: 0.5});
                    break;
                case MouseEvent.MOUSE_OUT:
                    Tweener.addTween(_icon, {_brightness: 0, time: 0.5});
                    Tweener.addTween(_check, {_brightness: 0, time: 0.5});
                    break;
                case MouseEvent.CLICK:
                    _check.visible = !_check.visible;
                    dispatchEvent(new Event(Event.CHANGE));
                    break;
            }
        }

        public function get slider():Slider
        {
            return _slider;
        }

        public function get comboBox():ComboBox
        {
            return _comboBox;
        }
    }
}
