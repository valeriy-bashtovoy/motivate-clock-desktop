package org.motivateclock.view
{

    import flash.desktop.NativeApplication;
    import flash.display.MovieClip;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowDisplayState;
    import flash.events.NativeWindowDisplayStateEvent;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.motivateclock.view.clock.*;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ClockView extends MovieClip
    {
        private var _hourFlipper:FlipperView;
        private var _minFlipper:FlipperView;
        private var _secFlipper:FlipperView;
        private var _clockStatusViewer:ClockStatusView;
        private var _mainWindow:NativeWindow;

        private var _project:Project;
        private var _gfx:MovieClip;
        private var _model:Model;
        private var _settings:Settings;

        public function ClockView(model:Model)
        {
            _model = model;
            _settings = _model.settingModel.settings;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_CLOCK_VIEW) as MovieClip;
            addChild(_gfx);

            _hourFlipper = new FlipperView(ResourceLib.GFX_FLIPPER_BIG);
            _hourFlipper.x = 23;
            _hourFlipper.y = 27;
            addChild(_hourFlipper);

            _minFlipper = new FlipperView(ResourceLib.GFX_FLIPPER_BIG);
            _minFlipper.x = 100;
            _minFlipper.y = 27;
            addChild(_minFlipper);

            _secFlipper = new FlipperView(ResourceLib.GFX_FLIPPER_SMALL);
            _secFlipper.x = 167;
            _secFlipper.y = 39.5;
            addChild(_secFlipper);

            _clockStatusViewer = new ClockStatusView(_model);
            _clockStatusViewer.x = -2;
            _clockStatusViewer.y = -29.5;
            addChild(_clockStatusViewer);


            _model.projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, projectChangeHandler);

            _model.addEventListener(ModelEvent.TYPE_CHANGE, typeChangeHandler);

            _mainWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;
            _mainWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, stateChangeHandler);

            projectChangeHandler();
        }

        private function projectChangeHandler(event:ModelEvent = null):void
        {
            if (_project)
            {
                _project.removeEventListener(ModelEvent.PROJECT_TIME_CHANGE, project_time_changeHandler);
            }

            _project = _model.projectModel.currentProject;

            if (_project)
            {
                _project.addEventListener(ModelEvent.PROJECT_TIME_CHANGE, project_time_changeHandler, false, 0, true);
            }

            setTime(0);

            update();
        }

        public function update():void
        {
            _clockStatusViewer.update();
        }

        private function setTime(seconds:Number):void
        {
            var time:Object = TimeUtils.convertSeconds(seconds, _settings.workingHours);

            _clockStatusViewer.setNowDays(time.day);

            _hourFlipper.setTime(time.hour);
            _minFlipper.setTime(time.min);
            _secFlipper.setTime(time.sec);
        }

        private function typeChangeHandler(event:ModelEvent):void
        {
            _clockStatusViewer.setStatus(_model.currentType);
        }

        private function stateChangeHandler(event:NativeWindowDisplayStateEvent):void
        {
            switch (event.afterDisplayState)
            {
                case NativeWindowDisplayState.MINIMIZED:
                    _hourFlipper.stopFlip();
                    _minFlipper.stopFlip();
                    _secFlipper.stopFlip();
                    break;
                case NativeWindowDisplayState.NORMAL:
                    _hourFlipper.startFlip();
                    _minFlipper.startFlip();
                    _secFlipper.startFlip();
                    break;
            }
        }

        private function project_time_changeHandler(event:ModelEvent):void
        {
            switch (_model.currentType)
            {
                case TypeEnum.REST:
                    setTime(_project.restTime);
                    break;
                case TypeEnum.WORK:
                    setTime(_project.workTime);
                    break;
            }
        }
    }
}
