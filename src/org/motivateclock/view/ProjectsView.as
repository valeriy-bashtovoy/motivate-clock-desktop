package org.motivateclock.view
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.projects.HelpView;
    import org.motivateclock.view.projects.ProjectsCreatorView;
    import org.motivateclock.view.projects.ProjectsListView;
    import org.motivateclock.view.windows.ProcessesWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectsView extends MovieClip
    {
        private static const NUM_VISIBLE_PROJECTS:int = 8;

        private static const CLOSE_HEIGHT:int = 37;
        private static const PANEL_GAP:int = 169;

        private static const HELP_X_OFFSET:int = 10;
        private static const HELP_Y_OFFSET:int = 18;

        private var _background:MovieClip;
        private var _openButton:SimpleButton;
        private var _closeButton:SimpleButton;
        private var _labelHolder:MovieClip;
        private var _shadow:MovieClip;
        private var _shadowField:TextField;
        private var _labelField:TextField;
        private var _projectsCreatorView:ProjectsCreatorView;
        private var _projectsListView:ProjectsListView;
        private var _mask:Sprite;

        private var _isOpen:Boolean = false;
        private var _projectsManager:ProjectsModel;
        private var _gfx:MovieClip;
        private var _model:Model;
        private var _helpView:HelpView;
        private var _container:Sprite;
        private var _height:int = CLOSE_HEIGHT;
        private var _stage:Stage;

        public function ProjectsView(model:Model, stage:Stage)
        {
            _model = model;
            _stage = stage;
        }

        public function initialize():void
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECTS_VIEW) as MovieClip;
            addChild(_gfx);

            _background = _gfx["background"];
            _openButton = _gfx["openButton"];
            _closeButton = _gfx["closeButton"];
            _labelHolder = _gfx["labelHolder"];
            _shadow = _gfx["shadow"];

            _labelField = _labelHolder["label"] as TextField;
            _shadowField = _labelHolder["shadow"] as TextField;

            _mask = new Sprite();
            _mask.x = -_background.width / 2;
            _mask.graphics.beginFill(0x616161, 1);
            _mask.graphics.drawRoundRect(0, 0, _background.width, _background.height, 15);
            addChild(_mask);

            _container = new Sprite();
            _container.mask = _mask;
            addChild(_container);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);

            _projectsManager = _model.projectModel;
            _projectsManager.addEventListener(ModelEvent.PROJECT_CHANGE, projectChangeHandler, false, 0, true);
            _projectsManager.addEventListener(ProjectsModel.PROJECT_NAME_CHANGE, projectNameChangeHandler, false, 0, true);

            _closeButton.visible = false;
            _labelHolder.mouseChildren = false;

            _closeButton.addEventListener(MouseEvent.MOUSE_OVER, labelMouseHandler);
            _openButton.addEventListener(MouseEvent.MOUSE_OVER, labelMouseHandler);
            _closeButton.addEventListener(MouseEvent.MOUSE_OUT, labelMouseHandler);
            _openButton.addEventListener(MouseEvent.MOUSE_OUT, labelMouseHandler);

            _closeButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
            _openButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);

            languageChangeHandler();
        }

        private function projectNameChangeHandler(event:Event):void
        {
            updateTitle();
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            if (!event.ctrlKey)
            {
                return;
            }

            switch (event.keyCode)
            {
                case Keyboard.P:
                    _isOpen ? close() : open();
                    break;
                case Keyboard.N:
                    if (!_isOpen)
                    {
                        open();
                        _projectsCreatorView.open(true);
                    }
                    else
                    {
                        _projectsCreatorView.open(true);
                    }
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            updateTitle();
            updateHelpPosition();
        }

        public function open():void
        {
            _isOpen = true;

            dispatchEvent(new Event(Event.OPEN));

            _closeButton.visible = true;
            _openButton.visible = !_closeButton.visible;

            updateTitle();

            Tweener.removeTweens(_shadow);
            _shadow.alpha = 0;

            _projectsListView = new ProjectsListView(_model, 190, NUM_VISIBLE_PROJECTS);
            _projectsListView.x = -99;
            _projectsListView.y = 60;
            _container.addChild(_projectsListView);
            _projectsListView.initialize();

            _projectsCreatorView = new ProjectsCreatorView(_model, _stage);
            _projectsCreatorView.x = -90;
            _projectsCreatorView.y = 32;
            _container.addChild(_projectsCreatorView);
            _projectsCreatorView.initialize();
            _projectsCreatorView.addEventListener(Event.OPEN, creatorOpenHandler, false, 0, true);
            _projectsCreatorView.addEventListener(Event.CLOSE, creatorCloseHandler, false, 0, true);

            _helpView = new HelpView(_model);
            _helpView.x = _projectsListView.x + HELP_X_OFFSET;
            _helpView.addEventListener(ViewEvent.CREATE_PROJECT, helpView_createProjectHandler);
            _container.addChild(_helpView);

            setSize(_model.settingModel.settings.appHeight - PANEL_GAP);
        }

        public function close(time:Number = 0.1):void
        {
            _isOpen = false;

            _closeButton.visible = false;
            _openButton.visible = !_closeButton.visible;

            Tweener.addTween(_shadow, {alpha: 1, time: 1});

            ProcessesWindow.getInstance().hide();

            updateTitle();

            if (!_projectsListView)
            {
                return;
            }

            _helpView.dispose();
            _helpView.removeEventListener(ViewEvent.CREATE_PROJECT, helpView_createProjectHandler);
            _container.removeChild(_helpView);
            _helpView = null;

            _projectsCreatorView.dispose();
            _projectsCreatorView.removeEventListener(Event.OPEN, creatorOpenHandler);
            _projectsCreatorView.removeEventListener(Event.CLOSE, creatorCloseHandler);
            _container.removeChild(_projectsCreatorView);
            _projectsCreatorView = null;

            _projectsListView.dispose();
            _container.removeChild(_projectsListView);
            _projectsListView = null;

            setSize(CLOSE_HEIGHT, time);

            this.stage.focus = this.stage;
        }

        private function setSize(newHeight:int, time:Number = 0.2):void
        {
            _height = Math.max(newHeight, CLOSE_HEIGHT);

            Tweener.addTween(_background, {
                height: _height,
                time: time,
                transition: "easeOutCubic",
                onUpdate: updateHandler
            });

            updateHelpPosition();

            function updateHandler():void
            {
                _mask.height = _background.height - 5;
            }

            var e:McEvent = new McEvent(McEvent.RESIZE_MAIN);
            e.size = _height + PANEL_GAP;
            e.time = time;
            dispatchEvent(e);
        }

        private function updateHelpPosition():void
        {
            if (!_helpView)
            {
                return;
            }

            _helpView.y = _height - _helpView.height - HELP_Y_OFFSET;
        }

        private function showHint():void
        {
            var name:String;
            var project:Project = _model.projectModel.currentProject;

            name = project.name;

            if (name.length > _labelField.text.length)
            {
                Hint.getInstance().show(this.stage.nativeWindow, name);
            }
        }

        private function updateTitle():void
        {
            var title:String = "";
            var currentProject:Project = _model.projectModel.currentProject;

            if (_isOpen)
            {
                title = _model.languageModel.getText(TextKeyEnum.PROJECT_MINIMIZE);
            }
            else
            {
                title = currentProject.name;
            }

            _labelField.htmlText = RegularUtils.truncateString(_labelField, title);
            _shadowField.htmlText = _labelField.text;

            _labelField.textColor = (!_isOpen && currentProject.id == ProjectsModel.MANUAL_MODE) ? 0x0a485c : 0x252628;
        }

        private function labelMouseHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    showHint();
                    break;
                case MouseEvent.MOUSE_OUT:
                    Hint.getInstance().hide();
                    break;
            }
        }

        private function creatorOpenHandler(event:Event):void
        {
            _projectsListView.y = int(_projectsCreatorView.y + _projectsCreatorView.height);
            _projectsListView.numVisibleItems = 6;
        }

        private function creatorCloseHandler(event:Event):void
        {
            _projectsListView.y = int(_projectsCreatorView.y + _projectsCreatorView.height);
            _projectsListView.numVisibleItems = NUM_VISIBLE_PROJECTS;
            _projectsListView.update();
        }

        private function projectChangeHandler(event:ModelEvent = null):void
        {
            updateTitle();
        }

        private function buttonClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _openButton:
                    open();
                    break;
                case _closeButton:
                    close();
                    break;
            }
        }

        private function helpView_createProjectHandler(event:ViewEvent):void
        {
            _projectsCreatorView.open(true);
        }
    }
}
