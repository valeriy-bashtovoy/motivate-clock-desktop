package org.motivateclock.view.clock
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ClockStatusView extends MovieClip
    {

        private var _dayHolder:Sprite;
        private var _statusField:TextField;

        private var _nowDaysField:TextField;
        private var _nowDaysText:TextField;
        private var _nowDay:int = -1;
        private var _firstLaunchText:String;

        private var _dayCollection:Array = [];
        private var _gfx:MovieClip;
        private var _currentType:String;
        private var _model:Model;

        public function ClockStatusView(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_CLOCK_STATUS_VIEW) as MovieClip;
            addChild(_gfx);

            _dayHolder = _gfx["dayHolder"];
            _statusField = _gfx["statusField"];

            _nowDaysField = _dayHolder["nowDaysField"];
            _nowDaysText = _dayHolder["nowDaysText"];

            var format:TextFormat = new TextFormat();
            format.letterSpacing = -0.3;

            _statusField.autoSize = TextFieldAutoSize.LEFT;
            _nowDaysField.text = "";
            _dayHolder.visible = false;
            _statusField.htmlText = "";


            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();

            update();
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _firstLaunchText = _model.languageModel.getText(TextKeyEnum.START_TIME_TRACKING);

            _dayCollection = _model.languageModel.getText(TextKeyEnum.DAY).split(",");

            _dayHolder.x = _statusField.x;

            setStatus(_currentType);

            setNowDays(_nowDay);
        }

        public function setNowDays(days:int):void
        {
            _nowDay = days;

            _dayHolder.visible = Boolean(days > 0);

            _nowDaysField.htmlText = String(days);
            _nowDaysText.text = TimeUtils.getDeclensionNumberName(days, _dayCollection);
        }

        public function update():void
        {
            if (_model.isFirstLaunch)
            {
                _statusField.htmlText = _firstLaunchText;
            }
        }

        private function setWorkMode():void
        {
            _statusField.htmlText = _model.languageModel.getText(TextKeyEnum.YOU_WORK);
        }

        private function setRestMode():void
        {
            _statusField.htmlText = _model.languageModel.getText(TextKeyEnum.YOU_REST);
        }

        public function setStatus(type:String):void
        {
            _currentType = type;

            _statusField.htmlText = "";

            switch (type)
            {
                case TypeEnum.REST:
                    setRestMode();
                    break;
                case TypeEnum.WORK:
                    setWorkMode();
                    break;
                case TypeEnum.IDLE:
                    break;
            }

            _dayHolder.visible = _statusField.text != "" && _nowDay > 0;

            _dayHolder.x = Math.max(_dayHolder.x, _statusField.x + _statusField.width - 4);
        }
    }
}
