/**
 * User: Valeriy Bashtovoy
 * Date: 10.09.13
 */
package org.motivateclock
{

    import flash.events.EventDispatcher;

    import org.motivateclock.enum.ProcessStateEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.INotificationModel;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.interfaces.IStatisticsModel;
    import org.motivateclock.model.ApplicationManager;
    import org.motivateclock.model.ClockModel;
    import org.motivateclock.model.ErrorLog;
    import org.motivateclock.model.LanguagesManager;
    import org.motivateclock.model.NotificationModel;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.SkinManager;
    import org.motivateclock.model.StatisticsModel;
    import org.motivateclock.model.ToastManager;
    import org.motivateclock.model.icons.IconManager;
    import org.motivateclock.model.settings.SettingsManager;
    import org.motivateclock.model.statistic.DataBase;
    import org.motivateclock.model.statistic.StatisticExporter;
    import org.motivateclock.model.update.UpdaterModel;
    import org.motivateclock.model.vo.BrowserVO;
    import org.motivateclock.resource.ResourceCommon;

    public class Model extends EventDispatcher
    {
        private var _browserList:Vector.<BrowserVO>;
        private var _projectsHelpText:String = "";
        private var _initializeState:String;
        private var _config:XML = XML(new ResourceCommon.CONFIG());
        private var _languageModel:LanguagesManager;
        private var _clockModel:ClockModel;
        private var _projectModel:ProjectsModel;
        private var _toastManager:ToastManager;
        private var _currentType:String = TypeEnum.IDLE;
        private var _previousType:String = _currentType;
        private var _updaterModel:UpdaterModel;
        private var _errorManager:ErrorLog;
        private var _settingModel:SettingsManager;
        private var _dataBase:DataBase;
        private var _isFirstLaunch:Boolean = false;
        private var _exporter:StatisticExporter;
        private var _applicationManager:ApplicationManager;
        private var _notificationModel:INotificationModel;
        private var _iconManager:IconManager;
        private var _syncState:String = ProcessStateEnum.PROCESS_SYNC_COMPLETE;
        private var _statisticsModel:IStatisticsModel;
        private var _skinManager:SkinManager;
        private var _userIdle:Boolean = false;
        private var _isPending:Boolean;

        public function Model()
        {
            _errorManager = ErrorLog.getInstance();

            _settingModel = new SettingsManager();
            _languageModel = new LanguagesManager(this);
            _clockModel = new ClockModel();
            _notificationModel = new NotificationModel();
            _exporter = new StatisticExporter(this);
            _statisticsModel = new StatisticsModel();
            _skinManager = new SkinManager();

            _projectModel = ProjectsModel.getInstance();
            _projectModel.model = this;
            _toastManager = new ToastManager(this);
            _updaterModel = UpdaterModel.getInstance();
            _dataBase = DataBase.getInstance();
            _applicationManager = new ApplicationManager(this);
            _iconManager = IconManager.getInstance();
        }

        public function get browserList():Vector.<BrowserVO>
        {
            return _browserList;
        }

        public function set browserList(value:Vector.<BrowserVO>):void
        {
            _browserList = value;
            //trace(this, _browserList);
            dispatchEvent(new ModelEvent(ModelEvent.BROWSER_LIST_CHANGE));
        }

        public function updateCurrentProcess(process:IProcess):void
        {
            var e:ModelEvent = new ModelEvent(ModelEvent.NEW_PROCESS_READY);
            e.process = process;
            dispatchEvent(e);
        }

        public function get projectsHelpText():String
        {
            return _projectsHelpText;
        }

        public function set projectsHelpText(value:String):void
        {
            _projectsHelpText = value;
            dispatchEvent(new ModelEvent(ModelEvent.PROJECT_HELP_TEXT_CHANGE));
        }

        public function get initializeState():String
        {
            return _initializeState;
        }

        public function set initializeState(value:String):void
        {
            _initializeState = value;
            dispatchEvent(new ModelEvent(ModelEvent.INITIALIZE_STATE_CHANGE));
        }

        public function get config():XML
        {
            return _config;
        }

        public function get languageModel():LanguagesManager
        {
            return _languageModel;
        }

        public function get clockModel():ClockModel
        {
            return _clockModel;
        }

        public function get projectModel():ProjectsModel
        {
            return _projectModel;
        }

        public function get previousType():String
        {
            return _previousType;
        }

        public function get currentType():String
        {
            return _currentType;
        }

        public function set currentType(value:String):void
        {
            _previousType = _currentType;

            _currentType = value;

            dispatchEvent(new ModelEvent(ModelEvent.TYPE_CHANGE))
        }

        public function get toastManager():ToastManager
        {
            return _toastManager;
        }

        public function get updaterModel():UpdaterModel
        {
            return _updaterModel;
        }

        public function get errorManager():ErrorLog
        {
            return _errorManager;
        }

        public function get isFirstLaunch():Boolean
        {
            return _isFirstLaunch;
        }

        public function set isFirstLaunch(value:Boolean):void
        {
            _isFirstLaunch = value;
        }

        public function get settingModel():SettingsManager
        {
            return _settingModel;
        }

        public function get dataBase():DataBase
        {
            return _dataBase;
        }

        public function get applicationManager():ApplicationManager
        {
            return _applicationManager;
        }

        public function get exporter():StatisticExporter
        {
            return _exporter;
        }

        public function get iconManager():IconManager
        {
            return _iconManager;
        }

        public function get colorTone():int
        {
            return _settingModel.settings.colorTone;
        }

        public function set colorTone(value:int):void
        {
            _settingModel.settings.colorTone = value;

            dispatchEvent(new ModelEvent(ModelEvent.COLOR_TONE_CHANGE))
        }

        public function get syncState():String
        {
            return _syncState;
        }

        public function set syncState(value:String):void
        {
            _syncState = value;
            dispatchEvent(new ModelEvent(ModelEvent.PROCESS_SYNC_STATE_CHANGE));
        }

        public function get statisticsModel():IStatisticsModel
        {
            return _statisticsModel;
        }

        public function get skinManager():SkinManager
        {
            return _skinManager;
        }

        public function set userIdle(value:Boolean):void
        {
            _userIdle = value;
            dispatchEvent(new ModelEvent(ModelEvent.USER_IDLE_STATE_CHANGE));
        }

        public function get userIdle():Boolean
        {
            return _userIdle;
        }

        public function set isPending(value:Boolean):void
        {
            _isPending = value;
            trace(this, '_isPending', _isPending);
            dispatchEvent(new ModelEvent(ModelEvent.APP_PENDING_CHANGE));
        }

        public function get isPending():Boolean
        {
            return _isPending;
        }
    }
}
