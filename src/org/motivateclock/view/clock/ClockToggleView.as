package org.motivateclock.view.clock
{

    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.components.SmartContainer;
    import org.motivateclock.view.windows.SettingWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ClockToggleView extends MovieClip
    {
        private var _workButton:ToggleButton;
        private var _restButton:ToggleButton;
        private var _pauseButton:SimpleButton;
        private var _exitButton:SimpleButton;
        private var _settingButton:SimpleButton;

        private var _idleButtonUpState:DisplayObject;

        private var _fontSize:int;
        private var _gfx:MovieClip;
        private var _smartContainer:SmartContainer;
        private var _offset:int = -1;
        private var _settingWindow:SettingWindow;
        private var _model:Model;
        private var _project:Project;

        public function ClockToggleView(model:Model)
        {
            _model = model;
        }

        public function initialize():void
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_CLOCK_TOGGLE_VIEW) as MovieClip;
            addChild(_gfx);

            _settingWindow = SettingWindow.getInstance();

            _pauseButton = _gfx["pauseButton"];
            _exitButton = _gfx["exitButton"];
            _settingButton = _gfx["settingButton"];

            _workButton = new ToggleButton();
            _workButton.y = 2;
            _restButton = new ToggleButton();
            _restButton.y = 2;

            _idleButtonUpState = _pauseButton.upState;

            _smartContainer = new SmartContainer(this, SmartContainer.HORIZONTAL);
            _smartContainer.offset = _offset;

            _smartContainer.addItem(_workButton);
            _smartContainer.addItem(_pauseButton);
            _smartContainer.addItem(_restButton);
            _smartContainer.addItem(_settingButton);
            _smartContainer.addItem(_exitButton);


            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();
            projectChangeHandler();
            typeChangeHandler();

            _restButton.addEventListener(MouseEvent.CLICK, toggleClickHandler);
            _workButton.addEventListener(MouseEvent.CLICK, toggleClickHandler);
            _pauseButton.addEventListener(MouseEvent.CLICK, toggleClickHandler);

            _settingButton.addEventListener(MouseEvent.CLICK, clickHandler);
            _exitButton.addEventListener(MouseEvent.CLICK, clickHandler);

            _exitButton.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);
            _settingButton.addEventListener(MouseEvent.MOUSE_OVER, buttonOverHandler);

            _exitButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOutHandler);
            _settingButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOutHandler);

            _model.addEventListener(ModelEvent.TYPE_CHANGE, typeChangeHandler);

            ProjectsModel.getInstance().addEventListener(ModelEvent.PROJECT_CHANGE, projectChangeHandler);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            if (!event.ctrlKey)
            {
                return;
            }

            switch (event.keyCode)
            {
                case Keyboard.O:
                    if (!_settingWindow.visible)
                    {
                        _settingWindow.showSetting();
                    }
                    else
                    {
                        _settingWindow.hide();
                    }
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _workButton.setLabel(_model.languageModel.getText(TextKeyEnum.WORK), _fontSize);
            _restButton.setLabel(_model.languageModel.getText(TextKeyEnum.REST), _fontSize);

            // set similar texts size for both button;
            var textSize:int = Math.min(_workButton.getTextFieldSize(), _restButton.getTextFieldSize());
            _workButton.setTextFieldSize(textSize);
            _restButton.setTextFieldSize(textSize);

            _smartContainer.update();
        }

        private function enabledIdleButton(value:Boolean):void
        {
            _pauseButton.enabled = value;

            if (!value)
            {
                _pauseButton.upState = _pauseButton.downState;
            }
            else
            {
                _pauseButton.upState = _idleButtonUpState;
            }
        }

        private function selectedIdleButton(value:Boolean):void
        {
            if (value)
            {
                _pauseButton.upState = _idleButtonUpState;
            }
            else
            {
                enabledIdleButton(false);
            }
        }

        private function projectChangeHandler(event:ModelEvent = null):void
        {
            if (_project)
            {
                _project.removeEventListener(ModelEvent.PROJECT_MODE_CHANGE, project_mode_changeHandler);
            }

            _project = _model.projectModel.currentProject;

            _model.currentType = TypeEnum.IDLE;

            _project.addEventListener(ModelEvent.PROJECT_MODE_CHANGE, project_mode_changeHandler);

            typeChangeHandler();
            //project_mode_changeHandler();
        }

        private function buttonOverHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _exitButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.CLOSE));
                    break;
                case _settingButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.SETTINGS));
                    break;
            }
        }

        private function buttonOutHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
        }

        private function clickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _settingButton:
                    if (!_settingWindow.visible)
                    {
                        _settingWindow.showSetting();
                    }
                    else
                    {
                        _settingWindow.hide();
                    }
                    break;
                case _exitButton:
                    _model.applicationManager.minimizeToTray();
                    break;
            }
        }

        private function toggleClickHandler(event:MouseEvent):void
        {
            if (_project.isAuto)
            {
                return;
            }

            switch (event.target)
            {
                case _restButton:
                    _model.currentType = TypeEnum.REST;
                    break;
                case _workButton:
                    _model.currentType = TypeEnum.WORK;
                    break;
                case _pauseButton:
                    _model.currentType = TypeEnum.IDLE;
                    break;
            }
        }

        private function typeChangeHandler(event:ModelEvent = null):void
        {
            enabledIdleButton(false);

            switch (_model.currentType)
            {
                case TypeEnum.WORK:
                    if (!_project.isAuto)
                    {
                        enabledIdleButton(true);
                        _restButton.selected = false;
                    }
                    else
                    {
                        _restButton.enabled = false;
                        selectedIdleButton(true);
                    }
                    _workButton.selected = true;
                    break;
                case TypeEnum.REST:
                    if (!_project.isAuto)
                    {
                        enabledIdleButton(true);
                        _workButton.selected = false;
                    }
                    else
                    {
                        _workButton.enabled = false;
                        selectedIdleButton(true);
                    }
                    _restButton.selected = true;
                    break;
                case TypeEnum.IDLE:
                    if (!_project.isAuto)
                    {
                        _workButton.selected = false;
                        _restButton.selected = false;
                    }
                    else
                    {
                        _workButton.enabled = false;
                        _restButton.enabled = false;
                    }
                    enabledIdleButton(false);
                    break;
            }
        }

        private function project_mode_changeHandler(event:ModelEvent = null):void
        {
            typeChangeHandler();
        }
    }
}
