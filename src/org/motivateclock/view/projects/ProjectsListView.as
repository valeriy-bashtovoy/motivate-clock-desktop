package org.motivateclock.view.projects
{

    import flash.display.MovieClip;
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import org.motivateclock.Model;
    import org.motivateclock.enum.ContextMenuEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.ToastManager;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.alert.ConfirmAlert;
    import org.motivateclock.view.components.Scroll;
    import org.motivateclock.view.windows.ProcessesWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectsListView extends MovieClip implements IDisposable
    {
        private static const ITEM_RENDERER_HEIGHT:Number = 28;

        private var _projectList:Vector.<Project>;
        private var _contentHolder:Sprite;
        private var _scroll:Scroll;
        private var _currentItemRenderer:ProjectItemRenderer;
        private var _contextItemRenderer:ProjectItemRenderer;
        private var _menu:NativeMenu;

        private var _itemRendererList:Vector.<ProjectItemRenderer>;
        private var _projectsManager:ProjectsModel;
        private var _model:Model;
        private var _height:int;

        public function ProjectsListView(model:Model, width:int, numVisibleItems:int)
        {
            _model = model;

            _projectsManager = _model.projectModel;
            _height = numVisibleItems * ITEM_RENDERER_HEIGHT;

            _scroll = new Scroll(width, _height, ITEM_RENDERER_HEIGHT, -5);
            addChild(_scroll);

            _model.skinManager.registerDisplayObject(_scroll.trackButton);
        }

        override public function get height():Number
        {
            return _height;
        }

        public function initialize():void
        {
            _contentHolder = new Sprite();
            _scroll.setContent(_contentHolder);

            languageChangeHandler();

            ConfirmAlert.getInstance().addEventListener(McEvent.CONFIRMED, alertConfirmHandler, false, 0, true);
            ConfirmAlert.getInstance().addEventListener(McEvent.CANCEL, alertCancelHandler, false, 0, true);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);
            ProcessesWindow.getInstance().addEventListener(ViewEvent.WINDOW_HIDE, processesWindowHideHandler, false, 0, true);

            _model.projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, project_changeHandler);
        }

        public function getItemRendererByID(id:String):ProjectItemRenderer
        {
            for each (var itemRenderer:ProjectItemRenderer in _itemRendererList)
            {
                if (itemRenderer.project.id == id)
                    return itemRenderer;
            }

            return null;
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            addContextMenu();

            update();
        }

        public function set numVisibleItems(value:int):void
        {
            _scroll.setSize(value * ITEM_RENDERER_HEIGHT);
        }

        public function update():void
        {
            _currentItemRenderer = null;

            ProcessesWindow.getInstance().hide();

            RegularUtils.removeAllChildren(_contentHolder);

            _itemRendererList = new Vector.<ProjectItemRenderer>();

            _projectList = _projectsManager.projectsList.slice();

            var itemRenderer:ProjectItemRenderer;

            for each(var project:Project in _projectList)
            {
                itemRenderer = new ProjectItemRenderer(project, _model);
                _contentHolder.addChildAt(itemRenderer, 0);

                itemRenderer.addEventListener(ViewEvent.SELECT_PROJECT, itemRendererEventHandler, false, 0, true);
                itemRenderer.addEventListener(ViewEvent.REMOVE_PROJECT, itemRendererEventHandler, false, 0, true);
                itemRenderer.addEventListener(ViewEvent.EDIT_PROJECT_NAME, itemRendererEventHandler, false, 0, true);
                itemRenderer.addEventListener(ViewEvent.OPEN_PROJECT_SETTING, itemRendererEventHandler, false, 0, true);

                _itemRendererList.push(itemRenderer);

                if (project.id != ProjectsModel.MANUAL_MODE)
                {
                    itemRenderer.contextMenu = _menu;
                    itemRenderer.addEventListener(MouseEvent.CONTEXT_MENU, contextMenuHandler);
                }
            }

            updatePosition();

            _scroll.update();

            dispatchEvent(new McEvent(McEvent.RESIZE));
        }

        private function itemRendererEventHandler(event:ViewEvent):void
        {
            var itemRenderer:ProjectItemRenderer = event.currentTarget as ProjectItemRenderer;

            switch (event.type)
            {
                case ViewEvent.SELECT_PROJECT:
                    _projectsManager.selectProject(event.projectId);
                    break;
                case ViewEvent.REMOVE_PROJECT:
                    removeProject(itemRenderer);
                    break;
                case ViewEvent.OPEN_PROJECT_SETTING:
                    openProjectSettings(itemRenderer);
                    break;
                case ViewEvent.EDIT_PROJECT_NAME:
                    editProjectName(itemRenderer);
                    break;
            }
        }

        public function openProjectSettings(itemRenderer:ProjectItemRenderer):void
        {
            if (_currentItemRenderer == itemRenderer)
            {
                return;
            }

            ProcessesWindow.getInstance().hide();

            _currentItemRenderer = itemRenderer;
            _currentItemRenderer.highlight(true);

            ProcessesWindow.getInstance().setProject(itemRenderer.project);
            ProcessesWindow.getInstance().showAppSelector();
        }

        public function duplicateProject(project:Project = null):void
        {
            if (!project)
            {
                project = _currentItemRenderer.project;
            }

            _projectsManager.createProject(_model.languageModel.getText(TextKeyEnum.PROJECT_COPY) + " " + project.name, project.applications);

            update();
        }

        public function removeProject(itemRenderer:ProjectItemRenderer):void
        {
            _model.toastManager.hide(ToastManager.FIRST_LAUNCH);
            ProcessesWindow.getInstance().hide();

            itemRenderer.highlight(true);

            ConfirmAlert.getInstance().show(ConfirmAlert.DELETE, itemRenderer.project.id);
        }

        public function editProjectName(itemRenderer:ProjectItemRenderer, select:Boolean = false):void
        {
            if (_currentItemRenderer)
            {
                _currentItemRenderer.highlight(false);
                ProcessesWindow.getInstance().hide();
            }

            itemRenderer.editName(select);
        }

        private function addContextMenu():void
        {
            _menu = new NativeMenu();

            addContextMenuItem(ContextMenuEnum.OPTIONS, TextKeyEnum.PROJECT_OPTIONS);
            addContextMenuItem(ContextMenuEnum.DUPLICATE, TextKeyEnum.PROJECT_DUPLICATE);
            addContextMenuItem(ContextMenuEnum.RESET, TextKeyEnum.STATISTIC_HINT_CLEAR);
            addContextMenuItem(ContextMenuEnum.REMOVE, TextKeyEnum.PROJECT_DELETE);

            _menu.addEventListener(Event.DISPLAYING, menuEventHandler, false, 0, true);
            _menu.addEventListener(Event.SELECT, contextMenuSelectHandler, false, 0, true);

            stage.addEventListener(MouseEvent.CLICK, stageClickHandler, false, 0, true);
        }

        private function addContextMenuItem(name:String, languageKey:String):void
        {
            var item:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(languageKey));
            item.name = name;
            _menu.addItem(item);
        }

        private function stageClickHandler(event:MouseEvent):void
        {
            deselectContextItem();
        }

        private function deselectContextItem():void
        {
            if (!_contextItemRenderer || _contextItemRenderer == _currentItemRenderer)
            {
                return;
            }

            _contextItemRenderer.highlight(false);
            _contextItemRenderer = null;
        }

        private function menuEventHandler(event:Event):void
        {
            if (_contextItemRenderer)
                _contextItemRenderer.highlight(true);
        }

        private function updatePosition():void
        {
            var currentProject:Project = _projectsManager.currentProject;
            var startY:int = 0;

            for each(var itemRenderer:ProjectItemRenderer in _itemRendererList)
            {
                itemRenderer.hideIndicator();
                itemRenderer.y = startY;

                if (itemRenderer.project == currentProject)
                {
                    itemRenderer.showIndicator();
                }

                startY += ITEM_RENDERER_HEIGHT;
            }
        }

        private function alertConfirmHandler(event:McEvent):void
        {
            if (event.messageType != ConfirmAlert.DELETE)
            {
                return;
            }

            var project:Project = _projectsManager.getProjectById(event.projectId);

            if (project)
            {
                _projectsManager.removeProject(project);
                update();
            }
        }

        private function alertCancelHandler(event:McEvent):void
        {
            if (event.messageType != ConfirmAlert.DELETE)
            {
                return;
            }

            for each(var itemRenderer:ProjectItemRenderer in _itemRendererList)
            {
                if (itemRenderer.project.id == event.projectId)
                {
                    itemRenderer.highlight(false);
                    break;
                }
            }
        }

        private function contextMenuSelectHandler(event:Event):void
        {
            switch (event.target.name)
            {
                case ContextMenuEnum.OPTIONS:
                    openProjectSettings(_contextItemRenderer);
                    break;
                case ContextMenuEnum.REMOVE:
                    ConfirmAlert.getInstance().show(ConfirmAlert.DELETE, _contextItemRenderer.project.id);
                    break;
                case ContextMenuEnum.DUPLICATE:
                    duplicateProject(_contextItemRenderer.project);
                    break;
                case ContextMenuEnum.RESET:
                    _model.projectModel.resetProject(_contextItemRenderer.project);
                    break;
            }

            _contextItemRenderer = null;
        }

        private function contextMenuHandler(event:MouseEvent):void
        {
            deselectContextItem();
            _contextItemRenderer = ProjectItemRenderer(event.currentTarget);
        }

        private function processesWindowHideHandler(event:ViewEvent):void
        {
            if (!_currentItemRenderer)
            {
                return;
            }

            _currentItemRenderer.highlight(false);
            _currentItemRenderer = null;
        }

        public function dispose():void
        {
            _model.skinManager.unregisterDisplayObject(_scroll.trackButton);

            _menu = null;

            stage.removeEventListener(MouseEvent.CLICK, stageClickHandler);

            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            ConfirmAlert.getInstance().removeEventListener(McEvent.CONFIRMED, alertConfirmHandler);
            ConfirmAlert.getInstance().removeEventListener(McEvent.CANCEL, alertCancelHandler);

            _model.projectModel.removeEventListener(ModelEvent.PROJECT_CHANGE, project_changeHandler);
        }

        private function project_changeHandler(event:ModelEvent):void
        {
            //_model.alertModel.hide(Alert.FIRST_LAUNCH);
            ProcessesWindow.getInstance().hide();
            updatePosition();
        }
    }
}
