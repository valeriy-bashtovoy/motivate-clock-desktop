package org.motivateclock.view.projects
{

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Project;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.windows.ProcessesWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectEditorView extends MovieClip
    {
        private var _background:MovieClip;
        private var _labelField:TextField;
        private var _labelBacking:MovieClip;
        private var _saveButton:SimpleButton;
        private var _addButton:SimpleButton;
        private var _iconsLine:IconsSliderView;
        private var _questionButton:ProjectQuestionButton;

        private var _separator:MovieClip;
        private var _baseText:String;
        private var _project:Project;
        private var _isEditMode:Boolean = false;

        private var _gfx:MovieClip;
        private var _model:Model;

        public function ProjectEditorView(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECT_EDITOR_VIEW) as MovieClip;
            addChild(_gfx);

            _background = _gfx["background"];
            _saveButton = _gfx["saveButton"];
            _labelField = _gfx["labelField"];
            _labelBacking = _gfx["labelBacking"];
            _addButton = _gfx["addButton"];
            _separator = _gfx["separator"];

            _iconsLine = new IconsSliderView(_model);
            _iconsLine.x = 83;
            _iconsLine.y = 43;
            _gfx.addChild(_iconsLine);

            _questionButton = new ProjectQuestionButton();
            _questionButton.x = 29;
            _questionButton.y = 34;
            _gfx.addChild(_questionButton);

            languageChangeHandler();

            _labelField.textColor = 0xB6B6B6;
            _labelField.text = _baseText;
            _labelField.restrict = "^/\\";

            _iconsLine.visible = false;

            _labelBacking.width += 16;
            _labelField.width = _labelBacking.width - 15;
            _saveButton.x += 17;
            _background.height -= 4;

            _labelField.addEventListener(FocusEvent.FOCUS_IN, focusHandler, false, 0, true);
            _labelField.addEventListener(FocusEvent.FOCUS_OUT, focusHandler, false, 0, true);

            _addButton.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
            _addButton.addEventListener(MouseEvent.MOUSE_OVER, overHandler, false, 0, true);
            _addButton.addEventListener(MouseEvent.MOUSE_OUT, outHandler, false, 0, true);

            _saveButton.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
            _saveButton.addEventListener(MouseEvent.MOUSE_OVER, overHandler, false, 0, true);
            _saveButton.addEventListener(MouseEvent.MOUSE_OUT, outHandler, false, 0, true);

            _questionButton.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);

            _iconsLine.addEventListener(Event.CHANGE, iconsChangeHandler, false, 0, true);

            addEventListener(Event.REMOVED_FROM_STAGE, stageHandler, false, 0, true);
            addEventListener(Event.ADDED_TO_STAGE, stageHandler, false, 0, true);
        }

        private function stageHandler(event:Event):void
        {
            switch (event.type)
            {
                case Event.ADDED_TO_STAGE:
                    this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);
                    _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
                    break;
                case Event.REMOVED_FROM_STAGE:
                    this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
                    _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var baseText:String = _baseText;

            _baseText = _model.languageModel.getText(TextKeyEnum.PROJECT_ENTER_NAME);

            if (_labelField.text == baseText)
            {
                _labelField.text = _baseText;
            }

            _questionButton.setLabel(_model.languageModel.getText(TextKeyEnum.PROJECT_SELECT_APP));
        }

        public function enableCreateMode(project:Project):void
        {
            _project = project;
            _iconsLine.setProject(_project);
        }

        private function hideNameEditor():void
        {
            _labelBacking.visible = false;
            _labelField.selectable = _labelBacking.visible;

            _labelField.type = TextFieldType.DYNAMIC;
            _labelField.text = RegularUtils.truncateString(_labelField, _project.name);

            _labelField.setSelection(0, 0);

            _labelField.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeHandler);
            removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }

        public function setLabelFieldFocus():void
        {
            this.stage.focus = _labelField;
        }

        public function save():void
        {
            ProcessesWindow.getInstance().hide();

            if (_isEditMode)
            {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }

            var name:String = _labelField.text;

            if (name == _baseText || name == "")
            {
                name = _model.languageModel.getText(TextKeyEnum.PROJECT_UNNAMED);
            }

            _model.projectModel.createProject(name, _project.applications);

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function outHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
        }

        private function overHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _saveButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROJECT_SAVE));
                    break;
                case _addButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROJECT_ADD_APPS));
                    break;
            }
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            if (_isEditMode)
                event.stopImmediatePropagation();

            switch (event.keyCode)
            {
                case Keyboard.ESCAPE:
                    if (_isEditMode)
                    {
                        hideNameEditor();
                    }
                    break;
                case Keyboard.ENTER:
                    if (_isEditMode)
                    {
                        _project.name = _labelField.text;
                        hideNameEditor();
                    }
                    else
                    {
                        save();
                    }
                    break;
                case Keyboard.EQUAL:
                    if (event.ctrlKey)
                    {
                        addApplications();
                    }
                    break;
            }
        }

        private function focusChangeHandler(event:FocusEvent):void
        {
            if (event.relatedObject.name == "editButton")
            {
                return;
            }

            _project.name = _labelField.text;
            hideNameEditor();
        }

        private function iconsChangeHandler(event:Event):void
        {
            _iconsLine.visible = _iconsLine.numIcon > 0;

            var project:Project;

            if (_questionButton.visible == _iconsLine.visible)
            {
                project = _model.projectModel.currentProject;
                if (project == _project)
                {
                    _model.projectModel.selectProject(_project.id);
                }
            }

            _questionButton.visible = !_iconsLine.visible;
        }

        private function clickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _questionButton:
                case _addButton:
                    addApplications();
                    break;
                case _saveButton:
                    save();
                    break;
            }
        }

        private function addApplications():void
        {
            ProcessesWindow.getInstance().setProject(_project);
            ProcessesWindow.getInstance().showAppSelector();
        }

        private function focusHandler(event:FocusEvent):void
        {
            switch (event.type)
            {
                case FocusEvent.FOCUS_IN:
                    if (_labelField.text == _baseText)
                    {
                        _labelField.text = "";
                        _labelField.textColor = 0x252628;
                    }
                    break;
                case FocusEvent.FOCUS_OUT:
                    if (_labelField.text == "")
                    {
                        _labelField.text = _baseText;
                        _labelField.textColor = 0xB6B6B6;
                    }
                    break;
            }
        }

        public function dispose():void
        {
            _iconsLine.dispose();
        }

        override public function get height():Number
        {
            if (_background)
                return _background.height;

            return super.height;
        }

        public function addProcess(process:IProcess):void
        {
           if (_project)
               _project.processModel.add(process);
        }

        public function removeProcess(process:IProcess):void
        {
            if (_project)
                _project.processModel.remove(process);
        }
    }
}
