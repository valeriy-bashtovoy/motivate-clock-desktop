package org.motivateclock.view.statistic
{

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticMenu extends Sprite
    {
        private var _resetButton:SimpleButton;
        private var _exportButton:SimpleButton;
        private var _allButton:StatisticMenuButton;
        private var _workButton:StatisticMenuButton;
        private var _restButton:StatisticMenuButton;
        private var _type:String = "";
        private var _activated:Boolean = true;

        private var _hintClear:String = "";
        private var _hintPdf:String = "";
        private var _hintUpdate:String = "";
        private var _gfx:MovieClip;
        private var _model:Model;

        public function StatisticMenu(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_STATISTIC_MENU) as MovieClip;
            addChild(_gfx);

            _resetButton = _gfx["resetButton"];
            _exportButton = _gfx["exportButton"];

            _allButton = new StatisticMenuButton();
            addChild(_allButton);
            _workButton = new StatisticMenuButton();
            addChild(_workButton);
            _restButton = new StatisticMenuButton();
            addChild(_restButton);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();

            reset();

            _allButton.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            _workButton.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            _restButton.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);

            _allButton.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);
            _workButton.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);
            _restButton.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);

            _allButton.addEventListener(MouseEvent.CLICK, clickHandler);
            _workButton.addEventListener(MouseEvent.CLICK, clickHandler);
            _restButton.addEventListener(MouseEvent.CLICK, clickHandler);

            _resetButton.addEventListener(MouseEvent.CLICK, optionClickHandler);
            _resetButton.addEventListener(MouseEvent.MOUSE_OVER, optionOverHandler);
            _resetButton.addEventListener(MouseEvent.MOUSE_OUT, optionOutHandler);

            _exportButton.addEventListener(MouseEvent.CLICK, optionClickHandler);
            _exportButton.addEventListener(MouseEvent.MOUSE_OVER, optionOverHandler);
            _exportButton.addEventListener(MouseEvent.MOUSE_OUT, optionOutHandler);
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _hintClear = _model.languageModel.getText(TextKeyEnum.STATISTIC_HINT_CLEAR);
            _hintPdf = _model.languageModel.getText(TextKeyEnum.STATISTIC_HINT_PDF);
            _hintUpdate = _model.languageModel.getText(TextKeyEnum.STATISTIC_HINT_UPDATE);

            _allButton.setLabel(_model.languageModel.getText(TextKeyEnum.STATISTIC_ALL));
            _workButton.setLabel(_model.languageModel.getText(TextKeyEnum.STATISTIC_WORK));
            _restButton.setLabel(_model.languageModel.getText(TextKeyEnum.STATISTIC_REST));

            _workButton.x = _allButton.x + _allButton.width + 4;
            _restButton.x = _workButton.x + _workButton.width + 4;
        }

        public function set activated(value:Boolean):void
        {
            _activated = value;

            _allButton.activated = value;
            _workButton.activated = value;
            _restButton.activated = value;
        }

        public function set exportEnabled(value:Boolean):void
        {
            value = false;

            _exportButton.enabled = value;
            _exportButton.alpha = value ? 1 : 0.4;
        }

        public function get type():String
        {
            return _type;
        }

        public function reset():void
        {
            if (!_activated)
            {
                return;
            }
            _allButton.selected = true;
            _workButton.selected = false;
            _restButton.selected = false;
        }

        private function optionOutHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
        }

        private function optionOverHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _resetButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _hintClear);
                    break;
                case _exportButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _hintPdf);
                    break;
            }
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    event.target.over();
                    break;
                case MouseEvent.MOUSE_OUT:
                    event.target.out();
                    break;
            }
        }

        private function optionClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _resetButton:
                    dispatchEvent(new ViewEvent(ViewEvent.PROJECT_RESET, false));
                    break;
                case _exportButton:
                    dispatchEvent(new ViewEvent(ViewEvent.EXPORT_PDF, false));
                    break;
            }
        }

        private function clickHandler(event:MouseEvent):void
        {
            var target:StatisticMenuButton = StatisticMenuButton(event.target);

            if (target.selected)
            {
                return;
            }

            _restButton.selected = _workButton.selected = _allButton.selected = false;

            target.selected = true;

            switch (target)
            {
                case _allButton:
                    _type = "";
                    break;
                case _workButton:
                    _type = TypeEnum.WORK;
                    break;
                case _restButton:
                    _type = TypeEnum.REST;
                    break;
            }

            dispatchEvent(new Event(Event.SELECT));
        }
    }
}
