/**
 * User: Valeriy Bashtovoy
 * Date: 15.06.2014
 */
package org.motivateclock.controller
{

    import flash.display.Stage;
    import flash.system.Capabilities;

    import org.motivateclock.Model;
    import org.motivateclock.enum.AnalyticsTypeEnum;
    import org.motivateclock.events.DateWatcherEvent;
    import org.motivateclock.events.ErrorEvent;
    import org.motivateclock.interfaces.IAnalytics;
    import org.motivateclock.model.GoogleAnalytics;
    import org.motivateclock.utils.DateWatcher;

    public class AnalyticsController
    {
        private var _model:Model;
        private var _analytics:IAnalytics;
        private var _dateWatcher:DateWatcher;
        private var _osShortName:String;

        public function AnalyticsController(model:Model, root:Stage)
        {
            _model = model;
            _analytics = new GoogleAnalytics("UA-8935548-3", 'Motivate Clock', root);
            _osShortName = Capabilities.os.split(" ")[0].toLowerCase();

            initialize();
        }

        private function initialize():void
        {
            _dateWatcher = DateWatcher.getInstance();
            _dateWatcher.addEventListener(DateWatcherEvent.CHANGE, dateChangeHandler);

            if (_model.isFirstLaunch)
            {
                var dimensions:Object = {};

                dimensions.os = _osShortName;
                dimensions.version = _model.updaterModel.currentVersionLabel;

                _analytics.track(AnalyticsTypeEnum.INSTALL, dimensions);
            }

            _model.errorManager.addEventListener(ErrorEvent.ERROR, errorEventHandler);
        }

        private function dateChangeHandler(event:DateWatcherEvent):void
        {
            var dimensions:Object = {};

            dimensions.os = _osShortName;
            dimensions.version = _model.updaterModel.currentVersionLabel;

            _analytics.track(AnalyticsTypeEnum.LAUNCH, dimensions);
        }

        private function errorEventHandler(event:ErrorEvent):void
        {
            var dimensions:Object = {};

            dimensions.os = Capabilities.os;
            dimensions.version = event.version;
            dimensions.message = event.message;
            dimensions.stackTrace = event.stackTrace;

            _analytics.track(AnalyticsTypeEnum.ERROR, dimensions);
        }
    }
}
