package org.motivateclock.model
{

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.filesystem.File;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IToast;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.resource.ResourceImage;
    import org.motivateclock.utils.AccurateTimer;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.motivateclock.view.toast.Toast;
    import org.motivateclock.view.toast.ToastWindow;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ToastManager extends EventDispatcher
    {
        private static const TEXT_FIELD_MAX_LENGTH:int = 28;
        private static const DEFAULT_TOAST_SIZE:Rectangle = new Rectangle(0, 0, 243, 47);

        public static const UPDATE:String = 'update';
        public static const ACTIVITY:String = 'activity';
        public static const REST:String = 'rest';
        public static const FIRST_LAUNCH:String = 'firstLaunch';

        private var _showTimer:AccurateTimer;
        private var _hideTimer:Timer;
        private var _settings:Settings;
        private var _currentType:String;
        private var _showCount:int = 0;
        private var _model:Model;
        private var _soundDictionary:Dictionary = new Dictionary();
        private var _toastWindow:ToastWindow;

        public function ToastManager(model:Model)
        {
            _model = model;
        }

        public function initialize():void
        {
            _settings = _model.settingModel.settings;
            _toastWindow = new ToastWindow(_model);

            _hideTimer = new Timer(1, 1);
            _hideTimer.addEventListener(TimerEvent.TIMER, hideTimerHandler);

            _showTimer = new AccurateTimer(1000, int.MAX_VALUE);
            _showTimer.addEventListener(TimerEvent.TIMER, showTimerHandler);

            _model.addEventListener(ModelEvent.TYPE_CHANGE, typeChangedHandler);

            update();
        }

        /**
         * @param delay measured in seconds.
         */
        public function show(type:String, delay:int = 15):void
        {
            _hideTimer.stop();

            _hideTimer.delay = delay * 1000;

            _showCount++;

            _toastWindow.display(getToast(type));

            _hideTimer.start();
        }

        private function getToast(type:String):IToast
        {
            var toast:IToast = new Toast();
            toast.addEventListener(ViewEvent.TOAST_CLOSE, toast_closeHandler, false, 0, true);
            toast.addEventListener(ViewEvent.TOAST_CLICK, toast_clickHandler, false, 0, true);

            switch (type)
            {
                case ToastManager.UPDATE:
                    initializeUpdateToast(toast);
                    break;
                case ToastManager.ACTIVITY:
                    initializeWorkToast(toast);
                    break;
                case ToastManager.REST:
                    initializeRestToast(toast);
                    break;
                case ToastManager.FIRST_LAUNCH:
                    initializeLaunchToast(toast);
                    break;
            }

            return toast;
        }

        private function initializeLaunchToast(toast:IToast):void
        {
            var name:String = _model.projectModel.currentProject.name;

            var text:String = _model.languageModel.getText(TextKeyEnum.ALERT_PROJECT) + "<br>" + RegularUtils.truncateStringByLength(name, TEXT_FIELD_MAX_LENGTH);

            toast.initialize(new Rectangle(0, 0, 270, DEFAULT_TOAST_SIZE.height), new ResourceImage.TOAST_ICON_PROJECT(), text);
        }

        private function initializeRestToast(toast:IToast):void
        {
            playSound("alert_rest.mp3");

            var text:String = _model.languageModel.getText(TextKeyEnum.ALERT_RESTING) + " <font color='#b50909'>" + getTime(_settings.restTime * _showCount) + "</font>" +
                    "<br>" + _model.languageModel.getText(TextKeyEnum.ALERT_RESTING_QUESTION);

            toast.initialize(new Rectangle(0, 0, 275, DEFAULT_TOAST_SIZE.height), new ResourceImage.TOAST_ICON_REST(), text);
        }

        private function initializeWorkToast(toast:IToast):void
        {
            playSound("alert_work.mp3");

            var text:String = _model.languageModel.getText(TextKeyEnum.ALERT_WORKING) + " <font color='#969700'>" + getTime(_settings.workTime * _showCount) + "</font>" +
                    "<br>" + _model.languageModel.getText(TextKeyEnum.ALERT_WORKING_QUESTION);

            toast.initialize(new Rectangle(0, 0, 260, DEFAULT_TOAST_SIZE.height), new ResourceImage.TOAST_ICON_WORK(), text);
        }


        private function initializeUpdateToast(toast:IToast):void
        {
            var updateText:String = _model.languageModel.getText(TextKeyEnum.ABOUT_UPDATE_NEW) + "<br>" +
                    "<a href='" + _model.updaterModel.downloadUrl + "'>Motivate Clock " + _model.updaterModel.latestVersionLabel + "</a>";

            toast.initialize(new Rectangle(0, 0, 280, DEFAULT_TOAST_SIZE.height), new ResourceImage.TOAST_ICON_NEW(), updateText);
        }

        private function getTime(minutes:Number):String
        {
            var seconds:Number = minutes * 60;
            var t:Object = TimeUtils.convertSeconds(seconds, _settings.workingHours);

            return t.hour + ":" + t.min + ":" + t.sec;
        }

        private function playSound(fileName:String):void
        {
            if (!_settings.soundEnabled)
            {
                return;
            }

            var sound:Sound = _soundDictionary[fileName];
            var file:File;

            if (!sound)
            {
                file = File.applicationDirectory.resolvePath("sounds/" + fileName);
                _soundDictionary[fileName] = sound = new Sound(new URLRequest(file.nativePath));
            }

            sound.play();
        }

        public function hide(type:String):void
        {
            _toastWindow.display(null);
            _hideTimer.stop();
        }

        private function showTimerHandler(event:TimerEvent):void
        {
            show(_currentType);
        }

        private function hideTimerHandler(event:TimerEvent):void
        {
            _toastWindow.display(null);
        }

        private function typeChangedHandler(event:ModelEvent):void
        {
            update();
        }

        public function update():void
        {
            var alertState:Boolean = false;
            var time:Number;

            _showCount = 0;
            _showTimer.stop();

            switch (_model.currentType)
            {
                case TypeEnum.IDLE:
                    return;
                case TypeEnum.WORK:
                    alertState = _settings.workState;
                    time = _settings.workTime;
                    _currentType = ToastManager.ACTIVITY;
                    break;
                case TypeEnum.REST:
                    alertState = _settings.restState;
                    time = _settings.restTime;
                    _currentType = ToastManager.REST;
                    break;
            }

            if (!alertState)
            {
                return;
            }

            _showTimer.delay = time * 60 * 1000;
            _showTimer.start();
        }

        private function toast_clickHandler(event:Event):void
        {
            _model.applicationManager.restore();
        }

        private function toast_closeHandler(event:Event):void
        {
            _hideTimer.stop();
            _toastWindow.display(null);
        }
    }
}
