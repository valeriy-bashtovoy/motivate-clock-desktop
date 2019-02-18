package org.motivateclock.view.projects.setting
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    import org.motivateclock.Model;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessesContent extends MovieClip
    {
        private var _processesMenu:ProcessesMenu;

        private var _project:Project;
        private var _appSelector:ProcessSettingView;
        private var _siteSelector:InternetSettingView;
        private var _selectorHolder:Sprite;
        private var _model:Model;

        public function ProcessesContent(model:Model)
        {
            _model = model;

            _processesMenu = new ProcessesMenu(_model);
            _processesMenu.x = 22.5;
            _processesMenu.y = 27.5;
            addChild(_processesMenu);

            _selectorHolder = new Sprite();
            addChild(_selectorHolder);

            _processesMenu.addEventListener(Event.SELECT, menuSelectHandler);
        }

        public function showSiteSelector():void
        {
            _processesMenu.selectSites();
        }

        public function showAppSelector():void
        {
            _processesMenu.selectApps();
        }

        private function menuSelectHandler(event:Event):void
        {
            switch (_processesMenu.selected)
            {
                case ProcessesMenu.APP:
                    addAppSelector();
                    break;
                case ProcessesMenu.SITE:
                    addSiteSelector();
                    break;
            }
        }

        private function addSiteSelector():void
        {
            destroy();

            _siteSelector = new InternetSettingView(_project, _model);
            _siteSelector.x = 17;
            _siteSelector.y = 23;
            _selectorHolder.addChild(_siteSelector);
        }

        private function addAppSelector():void
        {
            destroy();

            _appSelector = new ProcessSettingView(_project, _model);
            _appSelector.addEventListener(Event.CLOSE, appSelectorCloseHandler);
            _selectorHolder.addChild(_appSelector);
            _appSelector.refresh();
        }

        private function appSelectorCloseHandler(event:Event):void
        {
            _processesMenu.selectSites();
        }

        private function destroy():void
        {
            if (_appSelector)
            {
                _appSelector.dispose();
                _appSelector.removeEventListener(Event.CLOSE, appSelectorCloseHandler);
                _selectorHolder.removeChild(_appSelector);
                _appSelector = null;
            }

            if (_siteSelector)
            {
                _siteSelector.dispose();
                _selectorHolder.removeChild(_siteSelector);
                _siteSelector = null;
            }
        }

        public function setProject(value:Project):void
        {
            _project = value;
            _project.processModel.addEventListener(ModelEvent.PROCESS_ADD, processHandler);
            _project.processModel.addEventListener(ModelEvent.PROCESS_REMOVE, processHandler);
        }

        public function dispose():void
        {
            destroy();
            _project.processModel.removeEventListener(ModelEvent.PROCESS_ADD, processHandler);
            _project.processModel.removeEventListener(ModelEvent.PROCESS_REMOVE, processHandler);
        }

        private function processHandler(event:ModelEvent):void
        {
            switch (event.type)
            {
                case ModelEvent.PROCESS_ADD:
                    if (_appSelector)
                    {
                        //_appSelector.select(event.process);
                    }
                    if (_siteSelector)
                    {
                        _siteSelector.add(event.process);
                    }
                    break;
                case ModelEvent.PROCESS_REMOVE:
                    if (_appSelector)
                    {
                        //_appSelector.unselect(event.process);
                    }
                    if (_siteSelector)
                    {
                        _siteSelector.remove(event.process);
                    }
                    break;
            }
        }
    }
}
