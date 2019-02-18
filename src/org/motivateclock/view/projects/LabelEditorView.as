package org.motivateclock.view.projects
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
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
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.windows.ProcessesWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class LabelEditorView extends Sprite implements IDisposable
    {
        private static const LIB_LABEL_EDITOR_VIEW:String = "Lib.LabelEditorView";

        private var _defaultTextColor:uint = 0xB6B6B6;
        private var _editTextColor:uint = 0x252628;

        private var _labelField:TextField;
        private var _labelFrame:MovieClip;

        private var _baseText:String;
        private var _project:Project;
        private var _isEditMode:Boolean = true;

        private var _gfx:MovieClip;
        private var _model:Model;

        public function LabelEditorView(project:Project, model:Model)
        {
            _project = project;
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(LIB_LABEL_EDITOR_VIEW) as MovieClip;
            addChild(_gfx);

            _labelField = _gfx["labelField"];
            _labelFrame = _gfx["labelFrame"];

            languageChangeHandler();

            _labelFrame.visible = false;
            _labelFrame.width = 175;

            _labelField.text = _baseText;
            _labelField.restrict = "^/\\";
            _labelField.width = _labelFrame.width - 15;

            _labelField.doubleClickEnabled = true;
            _labelField.addEventListener(MouseEvent.DOUBLE_CLICK, labelDoubleClickHandler);

            hideEditor();

            _labelField.addEventListener(FocusEvent.FOCUS_IN, focusHandler, false, 0, true);
            _labelField.addEventListener(FocusEvent.FOCUS_OUT, focusHandler, false, 0, true);

            addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);
        }

        public function get isRequiredHint():Boolean
        {
            return _project.name.length > _labelField.text.length;
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var baseText:String = _baseText;

            _baseText = _model.languageModel.getText(TextKeyEnum.PROJECT_ENTER_NAME);

            if (_labelField.text == baseText)
            {
                _labelField.text = _baseText;
            }
        }

        public function showEditor(select:Boolean):void
        {
            _labelFrame.visible = true;
            _labelField.selectable = _labelFrame.visible;

            _labelField.type = TextFieldType.INPUT;
            _labelField.text = _project.name;

            if (select)
                _labelField.setSelection(0, _labelField.length);

            stage.focus = _labelField;

            _labelField.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeHandler);
            addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }

        public function hideEditor():void
        {
            _labelFrame.visible = false;
            _labelField.selectable = _labelFrame.visible;

            _labelField.type = TextFieldType.DYNAMIC;
            _labelField.text = RegularUtils.truncateString(_labelField, _project.name);

            _labelField.setSelection(0, 0);

            _labelField.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusChangeHandler);

            removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);

            dispatchEvent(new Event(Event.COMPLETE));
        }

        public function editName(select:Boolean):void
        {
            if (!_labelFrame.visible)
            {
                showEditor(select);
            }
            else
            {
                _project.name = _labelField.text;
                hideEditor();
            }
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

            //ProjectsModel.getInstance().addProject(name, true, _project.applications);

            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            event.stopImmediatePropagation();

            switch (event.keyCode)
            {
                case Keyboard.ESCAPE:
                    if (_isEditMode)
                    {
                        hideEditor();
                    }
                    break;
                case Keyboard.ENTER:
                    if (_isEditMode)
                    {
                        ProjectsModel.getInstance().updateProjectName(_project, _labelField.text);
                        hideEditor();
                    }
                    else
                    {
                        save();
                    }
                    break;
            }
        }

        private function labelDoubleClickHandler(event:MouseEvent):void
        {
            showEditor(true);
        }

        private function focusChangeHandler(event:FocusEvent):void
        {
            if (event.relatedObject.name == "editButton")
            {
                return;
            }

            _project.name = _labelField.text;
            hideEditor();
        }

        private function focusHandler(event:FocusEvent):void
        {
            switch (event.type)
            {
                case FocusEvent.FOCUS_IN:
                    if (_labelField.text == _baseText)
                    {
                        _labelField.text = "";
                        _labelField.textColor = _editTextColor;
                    }
                    break;
                case FocusEvent.FOCUS_OUT:
                    if (_labelField.text == "")
                    {
                        _labelField.text = _baseText;
                        _labelField.textColor = _defaultTextColor;
                    }
                    break;
            }
        }

        public function dispose():void
        {
            removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
        }

        public function setTextColor(color:int):void
        {
            _defaultTextColor = color;
            _labelField.textColor = _defaultTextColor;
        }
    }
}
