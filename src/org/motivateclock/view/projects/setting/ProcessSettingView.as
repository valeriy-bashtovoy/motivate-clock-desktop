package org.motivateclock.view.projects.setting
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.vo.ProcessVO;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.services.RunningProcessService;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.components.Scroll;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessSettingView extends MovieClip
    {
        private static const NUM_VISIBLE_ITEMS:int = 14;

        private var _infoField:TextField;
        private var _preloader:MovieClip;
        private var _itemRendererList:Array = [];
        private var _itemRendererHeight:Number = 24;
        private var _scroll:Scroll;
        private var _projectsManager:ProjectsModel;
        private var _processService:RunningProcessService;
        private var _contentHolder:Sprite;
        private var _project:Project;

        private var _refreshButton:MovieClip;
        private var _gfx:MovieClip;
        private var _model:Model;

        public function ProcessSettingView(project:Project, model:Model)
        {
            _project = project;
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_APPLICATIONS_VIEW) as MovieClip;
            addChild(_gfx);

            _infoField = _gfx["infoField"];
            _preloader = _gfx["preloader"];

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _processService = RunningProcessService.getInstance();
            _processService.addEventListener(Event.COMPLETE, appReceiveHandler);

            _projectsManager = ProjectsModel.getInstance();

            _contentHolder = new Sprite();

            _refreshButton = RegularUtils.getInstanceFromLib("ui.processes.refresh") as MovieClip;
            _refreshButton.x = 42;
            _refreshButton.y = 70;
            addChild(_refreshButton);

            initButton(_refreshButton);

            languageChangeHandler();

            var scrollHeight:int = _itemRendererHeight * NUM_VISIBLE_ITEMS;
            var contentGap:int = 12;

            _scroll = new Scroll(181, scrollHeight, _itemRendererHeight, 0);
            _scroll.x = 31;
            _scroll.y = _refreshButton.y + _refreshButton.height - 2;
            addChild(_scroll);

            _model.skinManager.registerDisplayObject(_scroll.trackButton);
            _model.skinManager.registerDisplayObject(_preloader);

            _preloader.x = _scroll.x + 95;
            _preloader.y = _scroll.y + 130;

            _scroll.setContent(_contentHolder);

            _infoField.x = 26;
            _infoField.y = _scroll.y + scrollHeight + contentGap;
        }

        private function initButton(target:MovieClip):void
        {
            target.buttonMode = true;
            target.mouseChildren = false;
            target.addEventListener(MouseEvent.MOUSE_DOWN, buttonEventHandler, false, 0, true);
            target.addEventListener(MouseEvent.MOUSE_UP, buttonEventHandler, false, 0, true);
            target.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler, false, 0, true);
            target.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler, false, 0, true);
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            var button:MovieClip = event.currentTarget as MovieClip;

            switch (event.type)
            {
                case MouseEvent.MOUSE_DOWN:
                    button.gotoAndStop(3);
                    break;
                case MouseEvent.MOUSE_UP:
                    if (_refreshButton)
                    {
                        refresh();
                    }
                    button.gotoAndStop(1);
                    break;
                case MouseEvent.MOUSE_OUT:
                    Hint.getInstance().hide();
                    button.gotoAndStop(1);
                    break;
                case MouseEvent.MOUSE_OVER:
                    button.gotoAndStop(2);
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROCESSES_HINT_UPDATE));
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _refreshButton["labelField"].text = _model.languageModel.getText(TextKeyEnum.PROCESSES_APP_UPDATE);
            _infoField.htmlText = _model.languageModel.getText(TextKeyEnum.PROCESSES_APP_INFO);
        }

        public function dispose():void
        {
            _model.skinManager.unregisterDisplayObject(_scroll.trackButton);
            _model.skinManager.unregisterDisplayObject(_preloader);

            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
            _processService.removeEventListener(Event.COMPLETE, appReceiveHandler);
        }

        public function select(appVO:ProcessVO):void
        {
            selected(appVO, true);
        }

        public function unselect(appVO:ProcessVO):void
        {
            selected(appVO, false);
        }

        private function appReceiveHandler(event:Event):void
        {
            _preloader.visible = false;
            update();
        }

        private function selected(appVO:ProcessVO, state:Boolean):void
        {
            for each (var itemRenderer:ProcessItemRenderer in _itemRendererList)
            {
                if (itemRenderer.process.path == appVO.path)
                {
                    itemRenderer.isChecked = state;
                    return;
                }
            }
        }

        public function refresh():void
        {
            clear();
            _preloader.visible = true;
            _processService.getApplications();
        }

        public function clear():void
        {
            _itemRendererList = [];
            RegularUtils.removeAllChildren(_contentHolder);
            _scroll.reset();
        }

        private function reposit():void
        {
            var startX:int = 12;
            var startY:int = 14;

            for each (var itemRenderer:ProcessItemRenderer in _itemRendererList)
            {
                itemRenderer.hideSeparator();

                itemRenderer.x = startX;
                itemRenderer.y = startY;

                startY += _itemRendererHeight;
            }

            if (itemRenderer)
            {
                itemRenderer.showSeparator();
            }
        }

        private function update():void
        {
            if (!_project)
            {
                return;
            }

            var itemRenderer:ProcessItemRenderer;
            var process:IProcess;

            for each (process in _project.processModel.processList)
            {
                if (process.isSite)
                {
                    continue;
                }

                itemRenderer = new ProcessItemRenderer(process);
                itemRenderer.isChecked = true;
                //itemRenderer.setOffMode();
                itemRenderer.addEventListener(Event.CHANGE, itemRendererSelectHandler, false, 0, true);

                _itemRendererList.unshift(itemRenderer);
            }

            for each (process in _processService.processList)
            {
                if (_project.processModel.has(process))
                {
                    continue;
                }

                itemRenderer = new ProcessItemRenderer(process);
                itemRenderer.addEventListener(Event.CHANGE, itemRendererSelectHandler, false, 0, true);

                _itemRendererList.push(itemRenderer);
            }

            reposit();

            _scroll.reset();
            _scroll.contentHeight = _itemRendererList.length * _itemRendererHeight;
            _scroll.itemRendererCollection = _itemRendererList;
            _scroll.update();
        }

        private function itemRendererSelectHandler(event:Event):void
        {
            var itemRenderer:ProcessItemRenderer = event.currentTarget as ProcessItemRenderer;

            var viewEvent:ViewEvent = new ViewEvent(itemRenderer.isChecked ? ViewEvent.PROCESS_ADD : ViewEvent.PROCESS_REMOVE);

            viewEvent.projectId = _project.id;
            viewEvent.process = itemRenderer.process;

            stage.dispatchEvent(viewEvent);
        }
    }
}
