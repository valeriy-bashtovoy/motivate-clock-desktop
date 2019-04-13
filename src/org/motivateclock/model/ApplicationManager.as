package org.motivateclock.model
{

    import flash.desktop.NativeApplication;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowDisplayState;
    import flash.display.Screen;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NativeWindowDisplayStateEvent;
    import flash.events.TimerEvent;
    import flash.system.Capabilities;
    import flash.utils.Timer;

    import org.motivateclock.Model;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.view.SystemTray;
    import org.motivateclock.view.windows.AbstractWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    // TODO should be converted to controller;
    public class ApplicationManager extends EventDispatcher
    {
        private static const DELAY:int = 2000;

        public static var instance:ApplicationManager;

        private var _mainWindow:NativeWindow;
        private var _settings:Settings;
        private var _saveTimer:Timer;

        private var _isMinimizeToTray:Boolean = false;
        private var _model:Model;

        public function ApplicationManager(model:Model)
        {
            _model = model;

            _saveTimer = new Timer(DELAY);
            _saveTimer.addEventListener(TimerEvent.TIMER, saveTimerHandler);
            _saveTimer.start();

            _settings = _model.settingModel.settings;
            _mainWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;

            _mainWindow.addEventListener(Event.CLOSE, mainWindowCloseHandler);
            NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingHandler);

            _mainWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, stateChangeHandler, false, int.MAX_VALUE);
        }

        private function stateChangeHandler(event:NativeWindowDisplayStateEvent):void
        {
            switch (event.afterDisplayState)
            {
                case NativeWindowDisplayState.MINIMIZED:
                    _mainWindow.stage.frameRate = 1;
                    _mainWindow.visible = !_isMinimizeToTray;
                    _isMinimizeToTray = false;
                    hideAllSubWindows();
                    break;
                case NativeWindowDisplayState.NORMAL:
                    _mainWindow.stage.frameRate = 24;
                    activateMainWindow();
                    break;
            }
        }

        public function activateMainWindow():void
        {
            NativeApplication.nativeApplication.activate(_mainWindow);
        }

        public function minimize():void
        {
            _mainWindow.minimize();
        }

        public function minimizeToTray():void
        {
            _isMinimizeToTray = true;
            _mainWindow.visible = false;
            minimize();
        }

        public function restore():void
        {
            if (!_mainWindow.alwaysInFront)
            {
                _mainWindow.alwaysInFront = true;
                _mainWindow.restore();
                _mainWindow.alwaysInFront = false;
            }
            else
            {
                _mainWindow.restore();
            }
        }

        public function hideAllSubWindows():void
        {
            var windowCollection:Array = NativeApplication.nativeApplication.openedWindows;
            var window:NativeWindow;

            if (windowCollection.length == 1)
            {
                return;
            }

            for (var j:int = 1; j < windowCollection.length; j++)
            {
                window = windowCollection[j];

                if (window is AbstractWindow && window.visible)
                {
                    AbstractWindow(window).hide();
                }
            }
        }

        public function get hasDisplayedSubWindows():Boolean
        {
            var windowList:Array = NativeApplication.nativeApplication.openedWindows;
            var hasDisplayedWindows:Boolean = false;

            for each (var window:NativeWindow in windowList)
            {
                if (window is AbstractWindow && window != _mainWindow && window.visible)
                {
                    hasDisplayedWindows = true;
                    break;
                }
            }

            return hasDisplayedWindows;
        }

        public function updateAlwaysInFrontState():void
        {
            var windows:Array = NativeApplication.nativeApplication.openedWindows;

            for each (var win:NativeWindow in windows)
            {
                win.alwaysInFront = _settings.alwaysInFront;
            }
        }

        public function updateWindowPosition():void
        {
            var state:Object = {};

            state.x = _mainWindow.x;
            state.y = _mainWindow.y;
            state.display = _mainWindow.displayState;

            _settings.mainWindowState = state;
        }

        // TODO should be moved to command;
        public function applyWindowPosition():void
        {
            var screenCollection:Array = Screen.screens;
            var screensWidth:int = 0;
            var windowState:Object = _settings.mainWindowState;

            if (!windowState)
            {
                return;
            }

            for each (var screen:Screen in screenCollection)
            {
                screensWidth += screen.bounds.width;
            }

            if (windowState.x > screensWidth)
            {
                windowState.x = (Capabilities.screenResolutionX - _mainWindow.width) / 2;
            }

            _mainWindow.x = windowState.x;
            _mainWindow.y = windowState.y;

            updateAlwaysInFrontState();
        }

        public function exit(isEmergency:Boolean = false):void
        {
            var modelEvent:ModelEvent = new ModelEvent(ModelEvent.APPLICATION_EXITING);
            modelEvent.isEmergency = isEmergency;
            dispatchEvent(modelEvent);

            _saveTimer.stop();
            _model.clockModel.stop();

            _model.settingModel.save();
            _model.iconManager.save();

            SystemTray.getInstance().hide();

            _mainWindow.removeEventListener(Event.CLOSE, mainWindowCloseHandler);

            _model.projectModel.addEventListener(ModelEvent.PROJECT_SAVE_COMPLETE, project_save_completeHandler);
            _model.projectModel.save();

            NativeApplication.nativeApplication.dispatchEvent(new Event(Event.EXITING, false, true));
        }

        private function project_save_completeHandler(event:ModelEvent):void
        {
            NativeApplication.nativeApplication.exit();
        }

        private function exitingHandler(event:Event):void
        {
            var winClosingEvent:Event;

            for each (var win:NativeWindow in NativeApplication.nativeApplication.openedWindows)
            {
                winClosingEvent = new Event(Event.CLOSING, false, true);

                win.dispatchEvent(winClosingEvent);

                winClosingEvent.isDefaultPrevented() ? event.preventDefault() : win.close();
            }

            if (event.isDefaultPrevented())
            {
                return;
            }

            event.preventDefault();
        }

        private function mainWindowCloseHandler(event:Event):void
        {
            exit();
        }

        private function saveTimerHandler(event:TimerEvent):void
        {
            _model.projectModel.save();
        }
    }
}
