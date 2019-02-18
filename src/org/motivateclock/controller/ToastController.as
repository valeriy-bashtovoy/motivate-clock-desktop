package org.motivateclock.controller
{

    import org.motivateclock.Model;
    import org.motivateclock.enum.SettingKeyEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.ToastManager;
    import org.motivateclock.model.settings.Settings;

    public class ToastController
    {
        private var _model:Model;
        private var _activityTime:Number = 0;
        private var _settings:Settings;
        private var _targetActivityTime:Number = 0;

        public function ToastController(model:Model)
        {
            _model = model;
            _settings = _model.settingModel.settings;

            updateTargetTime();

            _model.clockModel.addEventListener(ModelEvent.CLOCK_TICK, clock_tickHandler);
            _model.addEventListener(ModelEvent.TYPE_CHANGE, model_type_changeHandler);
            _model.settingModel.addEventListener(ModelEvent.SETTING_CHANGE, setting_changeHandler);
        }

        private function clock_tickHandler(event:ModelEvent):void
        {
//            updateActivityTime(event.timeRange);
        }

        private function updateActivityTime(time:Number):void
        {
            if (!_settings.workState || _model.currentType == TypeEnum.IDLE)
                return;

            _activityTime += time;

            trace(this, 'time', time, '_activityTime', _activityTime, _targetActivityTime);

            if (_activityTime >= _targetActivityTime)
            {
                _model.toastManager.show(ToastManager.ACTIVITY);
                _activityTime = 0;
            }
        }

        private function updateTargetTime():void
        {
            _targetActivityTime = _settings.workTime * 60 / 8;
        }

        private function model_type_changeHandler(event:ModelEvent):void
        {
            if (_model.currentType == TypeEnum.IDLE)
                _activityTime = 0;
        }

        private function setting_changeHandler(event:ModelEvent):void
        {
            switch (event.propertyKey)
            {
                case SettingKeyEnum.WORK_TIME:
                    updateTargetTime();
                    break;
            }
        }
    }
}
