/**
 * Created by Valeriy Bashtovoy on 14.11.2015.
 */
package org.motivateclock.view.components
{

    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.AntiAliasType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Timer;

    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.resource.ResourceImage;
    import org.motivateclock.utils.DisplayObjectUtils;
    import org.motivateclock.utils.RegularUtils;

    public class HSelector extends Sprite implements IDisposable
    {
        private static const DEFAULT_TEXT_SIZE:int = 12;

        private var _labelField:TextField;
        private var _dataProvider:Vector.<Object>;
        private var _currentIndex:int = 0;
        private var _data:Object;
        private var _leftButton:SimpleButton;
        private var _rightButton:SimpleButton;
        private var _timer:Timer;

        public function HSelector()
        {
            initialize();
        }

        private function initialize():void
        {
            _labelField = new TextField();
            _labelField.selectable = false;
            _labelField.multiline = false;
            _labelField.textColor = 0x5e6064;
            _labelField.autoSize = TextFieldAutoSize.CENTER;
            _labelField.embedFonts = true;
            _labelField.wordWrap = true;
            _labelField.antiAliasType = AntiAliasType.ADVANCED;
            addChild(_labelField);

            _leftButton = createButton(ResourceImage.SLIDER_LEFT_BUTTON);
            _rightButton = createButton(ResourceImage.SLIDER_RIGHT_BUTTON);

            //_labelField.text = "test test";

            setTextSize(DEFAULT_TEXT_SIZE);
        }

        private function createButton(upState:Class, visible:Boolean = true):SimpleButton
        {
            var button:SimpleButton = DisplayObjectUtils.createButton(upState, upState);
            button.visible = visible;
            button.overState.alpha = 0.5;
            button.addEventListener(MouseEvent.CLICK, button_clickHandler, false, 0, true);

            addChild(button);

            return button;
        }

        private function button_clickHandler(event:MouseEvent):void
        {
            switch (event.currentTarget)
            {
                case _leftButton:
                    selectData(_currentIndex - 1);
                    break;
                case _rightButton:
                    selectData(_currentIndex + 1);
                    break;
            }
        }

        public function get data():Object
        {
            return _data;
        }

        public function selectData(index:int):void
        {
            if (!_dataProvider)
                return;

            _currentIndex = index;

            _currentIndex = _currentIndex >= _dataProvider.length ? 0 : _currentIndex;
            _currentIndex = _currentIndex < 0 ? (_dataProvider.length - 1) : _currentIndex;

            _data = _dataProvider[_currentIndex];

            _labelField.text = _data.label;

            if (_timer)
            {
                _timer.stop();
            }

            _timer = RegularUtils.callFunctionWithDelay(dispatchEvent, 500, [new ViewEvent(ViewEvent.SELECT)]);
        }

        public function setTextSize(size:int):void
        {
            _labelField.defaultTextFormat = new TextFormat("Myriad Pro Semibold", size, null, null, null, null, null, null, 'center');
            _labelField.setTextFormat(_labelField.defaultTextFormat);

            _labelField.y = int(_labelField.textHeight - _labelField.height);
        }

        public function setSize(width:int, height:int):void
        {
            _labelField.width = width - (_rightButton.width + _leftButton.width);
            _labelField.x = int(_leftButton.x + _leftButton.width);
            _rightButton.x = int(_labelField.x + _labelField.width);
        }

        public function setDataProvider(dataProvider:Vector.<Object>):void
        {
            _dataProvider = dataProvider;

            selectData(_currentIndex);
        }

        public function dispose():void
        {

        }
    }
}
