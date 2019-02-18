package org.motivateclock.view.projects
{

    import flash.display.MovieClip;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.windows.ProcessesWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectsCreatorView extends MovieClip
    {
        private var _openButton:ProjectCreateButton;
        private var _closeButton:ProjectCreateButton;
        private var _separator:MovieClip;
        private var _editor:ProjectEditorView;

        private var _isOpen:Boolean = false;
        private var _gfx:MovieClip;
        private var _model:Model;
        private var _stage:Stage;

        public function ProjectsCreatorView(model:Model, stage:Stage)
        {
            _model = model;
            _stage = stage;
        }

        public function initialize():void
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECTS_CREATOR_VIEW) as MovieClip;
            addChild(_gfx);

            _separator = _gfx["separator"];

            _openButton = new ProjectCreateButton();
            _openButton.x = 58;
            _openButton.y = 5;
            _gfx.addChild(_openButton);

            _closeButton = new ProjectCreateButton();
            _closeButton.x = _openButton.x;
            _closeButton.y = _openButton.y;
            _gfx.addChild(_closeButton);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);

            _openButton.setType("open");
            _openButton.mouseChildren = false;
            _openButton.buttonMode = true;

            _closeButton.setType("close");
            _closeButton.mouseChildren = false;
            _closeButton.buttonMode = true;

            _closeButton.visible = false;

            languageChangeHandler();

            _openButton.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);
            _closeButton.addEventListener(MouseEvent.CLICK, buttonClickHandler, false, 0, true);

            _openButton.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler, false, 0, true);
            _openButton.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler, false, 0, true);

            _closeButton.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler, false, 0, true);
            _closeButton.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler, false, 0, true);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, int.MAX_VALUE, true);
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.ESCAPE:
                    if (_isOpen)
                    {
                        close();
                        event.stopImmediatePropagation();
                    }
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _openButton.setLabel(_model.languageModel.getText(TextKeyEnum.PROJECT_NEW));
            _closeButton.setLabel(_model.languageModel.getText(TextKeyEnum.PROJECT_CANCEL));
        }

        public function open(isNeedFocus:Boolean = false):void
        {
            _isOpen = true;

            _closeButton.visible = true;
            _openButton.visible = !_closeButton.visible;

            ProcessesWindow.getInstance().hide();

            _editor = new ProjectEditorView(_model);
            _editor.enableCreateMode(new Project());
            _editor.x = -5.5;
            _editor.y = 28.5;
            addChild(_editor);

            _separator.y = _editor.y + _editor.height;

            if (isNeedFocus)
            {
                _editor.setLabelFieldFocus();
            }

            _editor.addEventListener(Event.COMPLETE, createCompleteHandler);

            _stage.addEventListener(ViewEvent.PROCESS_ADD, processHandler);
            _stage.addEventListener(ViewEvent.PROCESS_REMOVE, processHandler);

            dispatchEvent(new Event(Event.OPEN));
        }

        private function processHandler(event:ViewEvent):void
        {
            switch (event.type)
            {
                case ViewEvent.PROCESS_ADD:
                    _editor.addProcess(event.process);
                    break;
                case ViewEvent.PROCESS_REMOVE:
                    _editor.removeProcess(event.process);
                    break;
            }
        }

        public function close():void
        {
            _isOpen = false;

            this.stage.focus = this.stage;

            _closeButton.visible = false;
            _openButton.visible = !_closeButton.visible;

            _editor.dispose();
            removeChild(_editor);
            _editor = null;

            _separator.y = _openButton.y + _openButton.height;

            _stage.removeEventListener(ViewEvent.PROCESS_ADD, processHandler);
            _stage.removeEventListener(ViewEvent.PROCESS_REMOVE, processHandler);

            ProcessesWindow.getInstance().hide();

            dispatchEvent(new Event(Event.CLOSE));
        }

        private function createCompleteHandler(event:Event):void
        {
            close();
        }

        private function buttonClickHandler(event:MouseEvent):void
        {
            switch (event.currentTarget)
            {
                case _openButton:
                    open(true);
                    break;
                case _closeButton:
                    close();
                    break;
            }
        }

        public function create():void
        {
            _model.projectModel.createProject(_model.languageModel.getText(TextKeyEnum.PROJECT_UNNAMED) + " " + getTimer());

            ProcessesWindow.getInstance().setProject(_model.projectModel.currentProject);

            ProcessesWindow.getInstance().showAppSelector();

            dispatchEvent(new Event(Event.CLOSE));
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

        public function dispose():void
        {
            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _openButton.removeEventListener(MouseEvent.CLICK, buttonClickHandler);
            _closeButton.removeEventListener(MouseEvent.CLICK, buttonClickHandler);
            _openButton.removeEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            _openButton.removeEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);
            _closeButton.removeEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            _closeButton.removeEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);

            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }

        override public function get height():Number
        {
            return _separator.y;
        }
    }
}
