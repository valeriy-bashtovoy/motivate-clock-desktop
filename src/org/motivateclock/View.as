/**
 * Created by Valeriy on 05.04.2015.
 */
package org.motivateclock
{

    import caurina.transitions.Tweener;

    import flash.desktop.InvokeEventReason;
    import flash.desktop.NativeApplication;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowDisplayState;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.InvokeEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowBoundsEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.ui.Keyboard;

    import org.motivateclock.enum.LinkEnum;
    import org.motivateclock.enum.StateEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.ToastManager;
    import org.motivateclock.model.icons.IconManager;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.DateWatcher;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.motivateclock.view.ClockView;
    import org.motivateclock.view.NotificationView;
    import org.motivateclock.view.ProjectsView;
    import org.motivateclock.view.StatisticView;
    import org.motivateclock.view.SystemTray;
    import org.motivateclock.view.alert.ConfirmAlert;
    import org.motivateclock.view.clock.ClockToggleView;
    import org.motivateclock.view.windows.AbstractWindow;
    import org.motivateclock.view.windows.ProcessesWindow;
    import org.motivateclock.view.windows.SettingWindow;

    public class View extends EventDispatcher
    {
        private var _model:Model;
        private var _stage:Stage;

        private var _back:MovieClip;
        private var _projectsGui:ProjectsView;
        private var _statisticGui:StatisticView;
        private var _clockGui:ClockView;
        private var _clockToggle:ClockToggleView;

        private var _openedSubWindow:AbstractWindow;
        private var _dragButton:Sprite;
        private var _mainWindow:NativeWindow;
        private var _invokeReason:String;
        private var _projectManager:ProjectsModel;
        private var _notificationView:NotificationView;
        private var _processWindow:ProcessesWindow;

        public function View(model:Model, stage:Stage)
        {
            _model = model;
            _stage = stage;

            _projectManager = _model.projectModel;

            _mainWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;
            _mainWindow.visible = false;

            NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);

            _model.addEventListener(ModelEvent.INITIALIZE_STATE_CHANGE, model_initialize_state_changeHandler);
        }

        private function invokeHandler(event:InvokeEvent):void
        {
            _invokeReason = event.reason;
        }

        private function model_initialize_state_changeHandler(event:ModelEvent):void
        {
            switch (_model.initializeState)
            {
                case StateEnum.INITIALIZE_UI_COMPLETE:
                    break;
                case StateEnum.INITIALIZE_PROJECTS_COMPLETE:
                    initialize();
                    break;
            }
        }

        private function initialize():void
        {
            _back = RegularUtils.getInstanceFromLib(ResourceLib.GFX_MAIN_WINDOW_BACKGROUND) as MovieClip;
            _back.x = 2.5;
            _back.y = 18;
            _stage.addChild(_back);
            _back.mouseChildren = false;
            _back.mouseEnabled = false;

            _model.skinManager.registerDisplayObject(_back);

            _clockToggle = new ClockToggleView(_model);
            _clockToggle.x = 22;
            _clockToggle.y = 7;
            _stage.addChildAt(_clockToggle, 0);
            _clockToggle.initialize();

            _clockGui = new ClockView(_model);
            _clockGui.x = 31;
            _clockGui.y = 62.5;
            _clockGui.update();
            _stage.addChild(_clockGui);

            _dragButton = new Sprite();
            _dragButton.graphics.beginFill(0xFFFFFF, 0);
            _dragButton.graphics.drawRect(0, 0, 230, 35);
            _dragButton.x = 15;
            _dragButton.y = 30;
            _stage.addChild(_dragButton);
            _dragButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            _dragButton.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

            languageChangeHandler();

            _statisticGui = new StatisticView(_model);
            _statisticGui.x = 131;
            _statisticGui.y = 163;
            _stage.addChild(_statisticGui);
            _statisticGui.initialize();
            _statisticGui.addEventListener(McEvent.RESIZE_MAIN, mainResizeHandler);
            _statisticGui.addEventListener(Event.OPEN, openHandler);

            _projectsGui = new ProjectsView(_model, _stage);
            _projectsGui.x = 131;
            _projectsGui.y = 123;
            _stage.addChild(_projectsGui);
            _projectsGui.initialize();
            _projectsGui.addEventListener(McEvent.RESIZE_MAIN, mainResizeHandler);
            _projectsGui.addEventListener(Event.OPEN, openHandler);

            var confirmAlert:ConfirmAlert = ConfirmAlert.getInstance();
            confirmAlert.model = _model;
            _stage.addChild(confirmAlert);

            IconManager.getInstance().init();

            _model.toastManager.initialize();

            _processWindow = ProcessesWindow.getInstance();
            _processWindow.stage.addEventListener(ViewEvent.PROCESS_ADD, redispatchEvent);
            _processWindow.stage.addEventListener(ViewEvent.PROCESS_REMOVE, redispatchEvent);
            _processWindow.initialize(_model);

            SettingWindow.getInstance().initialize(_model);

            SystemTray.getInstance().init(_model);

            _mainWindow.height = _back.height + 20;
            _mainWindow.width = _back.width + 20;

            _notificationView = new NotificationView();

            DateWatcher.getInstance().start();

            resizeUpdateHandler();

            _mainWindow.addEventListener(NativeWindowBoundsEvent.MOVING, movingHandler);
            _stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, int.MAX_VALUE);

            const settings:Settings = _model.settingModel.settings;
            const displayState:String = settings.mainWindowState ? settings.mainWindowState.display : "";

            if (_invokeReason == InvokeEventReason.LOGIN || displayState == NativeWindowDisplayState.MINIMIZED)
            {
                _model.applicationManager.minimizeToTray();
            }
            else
            {
                _model.applicationManager.updateAlwaysInFrontState();
                _model.applicationManager.restore();
            }

            _model.toastManager.show(ToastManager.FIRST_LAUNCH);
        }

        private function redispatchEvent(event:ViewEvent):void
        {
            _stage.dispatchEvent(event);
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var project:Project = _projectManager.getProjectById(ProjectsModel.MANUAL_MODE);
            project.name = _model.languageModel.getText(TextKeyEnum.PROJECT_MANUAL_MODE);

            TimeUtils.monthsCollection = _model.languageModel.getText(TextKeyEnum.MONTHS_COLLECTION).split(",");

            addContextMenu();
        }

        private function openHandler(event:Event):void
        {
            switch (event.target)
            {
                case _statisticGui:
                    _projectsGui.close(0.1);
                    break;
                case _projectsGui:
                    _statisticGui.close(0.1);
                    break;
            }
        }

        private function keyboardHandler(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ESCAPE)
            {
                if (_model.applicationManager.hasDisplayedSubWindows)
                {
                    _model.applicationManager.hideAllSubWindows();
                }
                else
                {
                    _model.applicationManager.minimizeToTray();
                }
            }
        }

        private function addContextMenu():void
        {
            var exit:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.EXIT));
            exit.name = "exit";

            var minimize:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.MINIMIZE));
            minimize.name = "min";

            var above:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.ABOVE_ALL));
            above.name = "above";
            above.checked = _model.settingModel.settings.alwaysInFront;

            var info:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.ABOUT_TITLE));
            info.name = "info";

            var site:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.VISIT_WEBSITE));
            site.name = "site";

            var error:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.ERROR));
            error.name = "error";

            var rate:NativeMenuItem = new NativeMenuItem(_model.languageModel.getText(TextKeyEnum.RATE));
            rate.name = "rate";

            var menu:NativeMenu = new NativeMenu();
            menu.addEventListener(Event.SELECT, menuSelectHandler);

            menu.addItem(info);
            menu.addItem(new NativeMenuItem("", true));
            menu.addItem(rate);
            menu.addItem(error);
            menu.addItem(site);
            menu.addItem(new NativeMenuItem("", true));
            menu.addItem(above);
            menu.addItem(new NativeMenuItem("", true));
            menu.addItem(minimize);
            menu.addItem(exit);

            _dragButton.contextMenu = menu;
        }

        private function menuSelectHandler(event:Event):void
        {
            var target:NativeMenuItem = NativeMenuItem(event.target);

            switch (target.name)
            {
                case "rate":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.RATE)));
                    break;
                case "error":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.BUG_REPORT)));
                    break;
                case "exit":
                    _model.applicationManager.exit();
                    break;
                case "min":
                    _model.applicationManager.minimizeToTray();
                    break;
                case "above":
                    target.checked = !target.checked;
                    _model.settingModel.settings.alwaysInFront = target.checked;
                    _model.applicationManager.updateAlwaysInFrontState();
                    break;
                case "info":
                    SettingWindow.getInstance().showInfo();
                    break;
                case "site":
                    navigateToURL(new URLRequest(_model.languageModel.getLink(LinkEnum.HOME_PAGE)));
                    break;
            }
        }

        private function setSize(newHeight:int, target:DisplayObject, time:Number = 0.5):void
        {
            Tweener.removeTweens(_back);

            var statisticY:int = newHeight - 44;

            if (newHeight > _back.height)
            {
                _mainWindow.height = newHeight + 20;
            }

            Tweener.addTween(_back, {
                height: newHeight,
                time: time,
                transition: "easeOutCubic",
                onComplete: resizeCompleteHandler,
                onUpdate: resizeUpdateHandler
            });

            if (target == _projectsGui)
            {
                Tweener.addTween(_statisticGui, {y: statisticY, time: time, transition: "easeOutCubic"});
            }
        }

        private function resizeUpdateHandler():void
        {
            _dragButton.height = _back.height - 25;
        }

        private function resizeCompleteHandler():void
        {
            _mainWindow.height = _back.height + 20;
            _dragButton.mouseEnabled = true;
        }

        private function checkContact():void
        {
            var windows:Array = NativeApplication.nativeApplication.openedWindows;

            if (windows.length == 1)
            {
                return;
            }

            _openedSubWindow = null;
            // _isContact = false;

            for (var j:int = 1; j < windows.length; j++)
            {
                if (windows[j] is AbstractWindow && windows[j].visible)
                {
                    _openedSubWindow = AbstractWindow(windows[j]);
                    // _isContact = openedSubWindow.isContact;
                    // openedSubWindow.contact();
                }
            }
        }

        private function mouseUpHandler(event:MouseEvent):void
        {
            movingHandler();

            _model.applicationManager.updateWindowPosition();

            redispatchEvent(new ViewEvent(ViewEvent.WINDOW_POSITION_CHANGE));
        }

        private function movingHandler(event:NativeWindowBoundsEvent = null):void
        {
            if (_openedSubWindow)
            {
                _openedSubWindow.contact();
            }
        }

        private function mainResizeHandler(event:McEvent):void
        {
            setSize(event.size, DisplayObject(event.currentTarget), event.time);
        }

        private function mouseDownHandler(event:MouseEvent):void
        {
            checkContact();

            if (!_dragButton.mouseEnabled)
            {
                return;
            }

            _mainWindow.startMove();
        }
    }
}
