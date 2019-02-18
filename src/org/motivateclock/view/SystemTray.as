package org.motivateclock.view
{

    import flash.desktop.NativeApplication;
    import flash.desktop.SystemTrayIcon;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowDisplayState;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ScreenMouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.Dictionary;

    import org.motivateclock.Model;
    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.enum.LinkEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class SystemTray extends Sprite
    {

        public static var instance:SystemTray;
        private static var isSingleton:Boolean = false;

        private var _iconMap:Dictionary = new Dictionary();
        private var _iconMenu:NativeMenu;
        private var _subMenu:NativeMenu;
        private var _above:NativeMenuItem;
        private var _work:NativeMenuItem;
        private var _rest:NativeMenuItem;
        private var _idle:NativeMenuItem;
        private var _mainWindow:NativeWindow;
        private var _systemTrayIcon:SystemTrayIcon;

        private var _model:Model;

        public static function getInstance():SystemTray
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new SystemTray();
                isSingleton = false;
            }

            return instance;
        }

        public function SystemTray()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + " is Singletone, use getInstance()");
            }


        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            addMenu();

            if (NativeApplication.supportsSystemTrayIcon)
            {
                _systemTrayIcon.menu = _iconMenu;
            }

            update();
        }

        public function init(model:Model):void
        {
            _model = model;
            _mainWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;

            if (NativeApplication.supportsSystemTrayIcon)
            {
                iconLoader(FileEnum.TRAY_ICON_REST, TypeEnum.REST);
                iconLoader(FileEnum.TRAY_ICON_WORK, TypeEnum.WORK);
                iconLoader(FileEnum.TRAY_ICON_IDLE, TypeEnum.IDLE);

                _systemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
                _systemTrayIcon.addEventListener(ScreenMouseEvent.CLICK, mouseClickHandler);
                _systemTrayIcon.addEventListener(ScreenMouseEvent.RIGHT_CLICK, rightClickHandler);
            }

            _model.addEventListener(ModelEvent.TYPE_CHANGE, typeChangeHandler, false, 0, true);
            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();
        }

        private function typeChangeHandler(event:ModelEvent):void
        {
            update();
        }

        public function hide():void
        {
            NativeApplication.nativeApplication.icon.bitmaps = [];
        }

        private function addMenu():void
        {
            _iconMenu = new NativeMenu();

            var open:NativeMenuItem = addMenuItem(_model.languageModel.getText(TextKeyEnum.TRAY_OPEN));
            open.data = "open";

            addMenuItem("", "", true);

            _work = addMenuItem(_model.languageModel.getText(TextKeyEnum.WORK), "work");
            _rest = addMenuItem(_model.languageModel.getText(TextKeyEnum.REST), "rest");
            _idle = addMenuItem(_model.languageModel.getText(TextKeyEnum.PAUSE), "idle");

            addMenuItem("", "", true);

            _subMenu = new NativeMenu();
            _iconMenu.addSubmenu(_subMenu, _model.languageModel.getText(TextKeyEnum.TRAY_PROJECTS));

            addMenuItem("", "", true);

            _above = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.ABOVE_ALL));
            _above.checked = _model.settingModel.settings.alwaysInFront;
            _above.data = "above";
            _iconMenu.addItem(_above);

            addMenuItem("", "", true);

            addMenuItem(_model.languageModel.getText(TextKeyEnum.RATE), "rate");
            addMenuItem(_model.languageModel.getText(TextKeyEnum.ERROR), "error");
            addMenuItem(_model.languageModel.getText(TextKeyEnum.VISIT_WEBSITE), "visitSite");

            addMenuItem("", "", true);

            addMenuItem(_model.languageModel.getText(TextKeyEnum.EXIT), "close");

            _iconMenu.addEventListener(Event.SELECT, selectHandler);
            _subMenu.addEventListener(Event.SELECT, subSelectHandler);
        }

        private function addMenuItem(label:String, data:String = "", isSeparator:Boolean = false):NativeMenuItem
        {
            var item:NativeMenuItem = new NativeMenuItem(label, isSeparator);
            item.data = data;
            _iconMenu.addItem(item);

            return item;
        }

        private function addSubMenuItems():void
        {
            _subMenu.removeAllItems();

            var projectsCollection:Vector.<Project> = _model.projectModel.projectsList.slice();
            projectsCollection.unshift(projectsCollection.pop());

            var currentProject:Project = _model.projectModel.currentProject;
            var menuItem:NativeMenuItem;

            for each (var p:Project in projectsCollection)
            {
                menuItem = new NativeMenuItem(p.name);
                menuItem.data = p.id;

                if (currentProject == p)
                {
                    menuItem.checked = true;
                }

                _subMenu.addItem(menuItem);
            }
        }

        private function subSelectHandler(event:Event):void
        {
            var id:String = NativeMenuItem(event.target).data as String;
            _model.projectModel.selectProject(id);
        }

        private function enableManualMode(enable:Boolean):void
        {
            _work.enabled = enable;
            _rest.enabled = _work.enabled;
            _idle.enabled = _work.enabled;
        }

        public function update():void
        {
            var type:String = _model.currentType;

            _work.checked = false;
            _rest.checked = false;
            _idle.checked = false;

            var projectName:String = _model.projectModel.currentProject.name;
            var tooltipText:String = _model.languageModel.getText(TextKeyEnum.TRAY_PROJECT) + ": " + RegularUtils.truncateStringByLength(projectName, 41);
            tooltipText += "\n" + _model.languageModel.getText(TextKeyEnum.TRAY_MODE) + ": ";

            switch (type)
            {
                case TypeEnum.WORK:
                    _work.checked = true;
                    tooltipText += _model.languageModel.getText(TextKeyEnum.WORK);
                    break;
                case TypeEnum.REST:
                    _rest.checked = true;
                    tooltipText += _model.languageModel.getText(TextKeyEnum.REST);
                    break;
                case TypeEnum.IDLE:
                    _idle.checked = true;
                    tooltipText += _model.languageModel.getText(TextKeyEnum.PAUSE);
                    break;
            }

            if (NativeApplication.supportsSystemTrayIcon)
                _systemTrayIcon.tooltip = tooltipText;

            if (!_iconMap[type])
            {
                return;
            }

            NativeApplication.nativeApplication.icon.bitmaps = [_iconMap[type]];
        }

        private function iconLoader(url:String, type:String):void
        {
            var icon:Loader = new Loader();
            icon.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            icon.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            try
            {
                icon.load(new URLRequest(url));
            }
            catch (error:Error)
            {
                trace(error.message);
            }

            function completeHandler(event:Event):void
            {
                _iconMap[type] = Bitmap(icon.content).bitmapData;
                update();
            }

            function ioErrorHandler(event:IOErrorEvent):void
            {
            }
        }

        private function rightClickHandler(event:ScreenMouseEvent):void
        {
            addSubMenuItems();

            enableManualMode(_model.projectModel.currentProject && _model.projectModel.currentProject.isAuto);
        }

        private function mouseClickHandler(event:ScreenMouseEvent):void
        {
            if (_mainWindow.displayState == NativeWindowDisplayState.NORMAL)
            {
                _model.applicationManager.minimizeToTray();
            }
            else
            {
                _model.applicationManager.restore();
            }
        }

        private function selectHandler(event:Event):void
        {
            var data:String = NativeMenuItem(event.target).data as String;

            switch (data)
            {
                case "open":
                    _model.applicationManager.restore();
                    break;
                case "close":
                    _model.applicationManager.exit();
                    break;
                case "work":
                    _model.currentType = TypeEnum.WORK;
                    break;
                case "rest":
                    _model.currentType = TypeEnum.REST;
                    break;
                case "idle":
                    _model.currentType = TypeEnum.IDLE;
                    break;
                case "above":
                    _above.checked = !_above.checked;
                    _model.settingModel.settings.alwaysInFront = _above.checked;
                    _model.applicationManager.updateAlwaysInFrontState();
                    break;
                case "visitSite":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.HOME_PAGE)));
                    break;
                case "rate":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.RATE)));
                    break;
                case "error":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.BUG_REPORT)));
                    break;
            }
        }
    }
}
