package org.motivateclock.view.setting
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    import org.motivateclock.Model;
    import org.motivateclock.enum.SettingKeyEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.interfaces.IContent;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.view.components.SmartContainer;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class SettingContent extends MovieClip implements IContent
    {
        private static const COLOR_MAX_VALUE:int = 180;

        private var _autorunBox:SettingCheckBox;
        private var _langBox:SettingCheckBox;
        private var _idleBox:SettingCheckBox;
        private var _soundBox:SettingCheckBox;
        private var _workBox:SettingCheckBox;
        private var _restBox:SettingCheckBox;

        private var _settings:Settings;

        private var _smartContainer:SmartContainer;
        private var _offset:int = 10;
        private var _contentHolder:Sprite;
        private var _model:Model;
        private var _exportRestStatCB:SettingCheckBox;
        private var _workingHoursCB:SettingCheckBox;
        private var _appColorCB:SettingCheckBox;

        public function SettingContent(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            _contentHolder = new Sprite();
            _contentHolder.y = 15;
            _contentHolder.x = 15;
            addChild(_contentHolder);

            _smartContainer = new SmartContainer(_contentHolder, SmartContainer.VERTICAL);
            _smartContainer.offset = _offset;

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
            _settings = _model.settingModel.settings;

            _autorunBox = createCheckBox(_settings.autorun);
            _autorunBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);

            _langBox = createCheckBox(true);
            _langBox.disableCheckboxMode();
            _langBox.addComboBox(_settings.language, 85);
            _model.skinManager.registerDisplayObject(_langBox.comboBox.openButton);

            var languagesList:XMLList = _model.languageModel.getLangugesList();
            for each (var lang:XML in languagesList)
            {
                _langBox.addComboBoxItem(lang.@NAME, lang.@ID);
            }
            _langBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);

            _exportRestStatCB = createCheckBox(_settings.exportRestStat);
            _exportRestStatCB.addEventListener(Event.CHANGE, changeHandler, false, 0, true);

            _idleBox = createCheckBox(_settings.idleState);
            _idleBox.addComboBox(_settings.idleTarget, 85);
            _idleBox.addSlider(120, _settings.idleTime);
            _idleBox.disableCheckboxMode();
            _idleBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);
            _model.skinManager.registerDisplayObject(_idleBox.comboBox.openButton);
            _model.skinManager.registerDisplayObject(_idleBox.slider.background);

            _workingHoursCB = createCheckBox(true);
            _workingHoursCB.addSlider(24, _settings.workingHours);
            _workingHoursCB.disableCheckboxMode();
            _workingHoursCB.addEventListener(Event.CHANGE, changeHandler, false, 0, true);
            _model.skinManager.registerDisplayObject(_workingHoursCB.slider.background);

            _soundBox = createCheckBox(_settings.soundEnabled);
            _soundBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);

            _workBox = createCheckBox(_settings.workState);
            _workBox.addSlider(120, _settings.workTime);
            _workBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);
            _model.skinManager.registerDisplayObject(_workBox.slider.background);

            _restBox = createCheckBox(_settings.restState);
            _restBox.addSlider(120, _settings.restTime);
            _restBox.addEventListener(Event.CHANGE, changeHandler, false, 0, true);
            _model.skinManager.registerDisplayObject(_restBox.slider.background);

            _appColorCB = createCheckBox(true);
            _appColorCB.addSlider(COLOR_MAX_VALUE, _settings.colorTone / 2 + 90);
            _appColorCB.disableCheckboxMode();
            _appColorCB.showSeperator(false);
            _appColorCB.addEventListener(Event.CHANGE, changeHandler, false, 0, true);
            _model.skinManager.registerDisplayObject(_appColorCB.slider.background);

            languageChangeHandler();
        }

        private function createCheckBox(selected:Boolean):SettingCheckBox
        {
            var checkBox:SettingCheckBox = new SettingCheckBox();
            checkBox.state = selected;

            _smartContainer.addItem(checkBox, 0);

            return checkBox;
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _autorunBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_AUTORUN));

            _workBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_ALERT_WORK));
            _workBox.sliderPrefixList = _model.languageModel.getText(TextKeyEnum.EVERY).split(",");
            _workBox.sliderPostfixList = _model.languageModel.getText(TextKeyEnum.MINUTE).split(",");

            _restBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_ALERT_REST));
            _restBox.sliderPrefixList = _model.languageModel.getText(TextKeyEnum.EVERY).split(",");
            _restBox.sliderPostfixList = _model.languageModel.getText(TextKeyEnum.MINUTE).split(",");

            _exportRestStatCB.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_EXPORT_REST_STAT));

            _soundBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_SOUND));

            _workingHoursCB.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_WORKING_HOURS));
            _workingHoursCB.sliderPostfixList = _model.languageModel.getText(TextKeyEnum.HOUR).split(",");

            _appColorCB.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_APP_COLOR));

            _idleBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_IDLE_TYPE));
            _idleBox.clearComboBox();
            _idleBox.addComboBoxItem(_model.languageModel.getText(TextKeyEnum.PAUSE), TypeEnum.IDLE);
            _idleBox.addComboBoxItem(_model.languageModel.getText(TextKeyEnum.REST), TypeEnum.REST);
            _idleBox.sliderPrefixList = _model.languageModel.getText(TextKeyEnum.THROUGH).split(",");
            _idleBox.sliderPostfixList = _model.languageModel.getText(TextKeyEnum.MINUTE).split(",");

            _langBox.setLabel(_model.languageModel.getText(TextKeyEnum.SETTINGS_LANGUAGE));

            _smartContainer.update();
        }

        private function changeHandler(event:Event):void
        {
            switch (event.target)
            {
                case _soundBox:
                    _settings.soundEnabled = _soundBox.state;
                    return;
                case _langBox:
                    _model.languageModel.setLanguage(_langBox.comboBoxData);
                    return;
                case _autorunBox:
                    _settings.autorun = _autorunBox.state;
                    break;
                case _idleBox:
                    _settings.idleTarget = _idleBox.comboBoxData;
                    _settings.idleState = _idleBox.state;
                    _settings.idleTime = _idleBox.currentSliderValue;
                    _model.toastManager.update();
                    break;
                case _workBox:
                    _settings.workState = _workBox.state;
                    _model.settingModel.setProperty(SettingKeyEnum.WORK_TIME, _workBox.currentSliderValue);
                    break;
                case _restBox:
                    _settings.restState = _restBox.state;
                    _settings.restTime = _restBox.currentSliderValue;
                    _model.toastManager.update();
                    break;
                case _workingHoursCB:
                    _model.settingModel.setProperty(SettingKeyEnum.WORKING_HOURS, _workingHoursCB.currentSliderValue);
                    break;
                case _exportRestStatCB:
                    _settings.exportRestStat = _exportRestStatCB.state;
                    break;
                case _appColorCB:
                    _model.colorTone = (_appColorCB.currentSliderValue - 90) * 2;
                    break;
            }
        }

        public function dispose():void
        {
            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _model.skinManager.unregisterDisplayObject(_restBox.slider.background);
            _model.skinManager.unregisterDisplayObject(_workBox.slider.background);
            _model.skinManager.unregisterDisplayObject(_idleBox.slider.background);
            _model.skinManager.unregisterDisplayObject(_langBox.comboBox.openButton);
            _model.skinManager.unregisterDisplayObject(_idleBox.comboBox.openButton);
            _model.skinManager.unregisterDisplayObject(_workingHoursCB.slider.background);
            _model.skinManager.unregisterDisplayObject(_appColorCB.slider.background);
        }
    }
}
