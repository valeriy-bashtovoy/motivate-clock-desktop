/**
 * User: Valeriy Bashtovoy
 * Date: 16.11.13
 */
package org.motivateclock
{

    import flash.desktop.NativeApplication;
    import flash.display.DisplayObject;
    import flash.events.Event;

    import org.motivateclock.controller.AnalyticsController;
    import org.motivateclock.controller.ClockController;
    import org.motivateclock.controller.KeyController;
    import org.motivateclock.controller.ProcessController;
    import org.motivateclock.controller.ProjectController;
    import org.motivateclock.controller.ServiceController;
    import org.motivateclock.controller.StatisticsController;
    import org.motivateclock.controller.TimeSyncController;
    import org.motivateclock.controller.ToastController;
    import org.motivateclock.controller.command.InstallExtensionCommand;
    import org.motivateclock.controller.command.LoadTempProcessCommand;
    import org.motivateclock.controller.command.StartupCommand;
    import org.motivateclock.controller.command.UpdateHelpTextCommand;
    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.enum.StateEnum;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Process;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.update.UpdaterController;

    public class Controller
    {
        private var _model:Model;
        private var _view:DisplayObject;
        private var _currentProject:Project;

        public function Controller(model:Model, view:DisplayObject)
        {
            _model = model;
            _view = view;

            initialize();
        }

        private function initialize():void
        {
            var command:ICommand = new StartupCommand(_model, _view);
            command.execute();

            _model.dataBase.addEventListener(McEvent.DB_LOADED, dbLoadedHandler, false, 0, true);

            _model.projectModel.addEventListener(McEvent.LOAD_COMPLETE, projectsLoadedHandler, false, 0, true);
            _model.projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, projectEventHandler, false, 0, true);
            _model.projectModel.addEventListener(ProjectsModel.PROJECT_REMOVED, projectEventHandler, false, 0, true);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);
            _model.addEventListener(ModelEvent.INITIALIZE_STATE_CHANGE, model_initialize_state_changeHandler);

            _model.addEventListener(ModelEvent.COLOR_TONE_CHANGE, model_color_tone_changeHandler);

            _view.addEventListener(ViewEvent.INSTALL_EXTENSION, installExtensionHandler, false, 0, true);

            NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, userIdleHandler);
            NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, userPresentHandler);

            model_color_tone_changeHandler();

            if (_model.dataBase.isReady)
            {
                dbLoadedHandler();
            }
        }

        private function model_color_tone_changeHandler(event:ModelEvent = null):void
        {
            _model.skinManager.setColorTone(_model.colorTone);
        }

        private function userPresentHandler(event:Event):void
        {
            _model.currentType = _model.previousType;
        }

        private function userIdleHandler(event:Event):void
        {
            _model.currentType = _model.settingModel.settings.idleTarget;

            if (_model.currentType != TypeEnum.REST || !_currentProject)
            {
                return;
            }

            /**
             * If predefined state for user IDLE event is rest,
             * then create fake process with name: Desktop;
             */
            const desktopProcess:IProcess = new Process(ProcessTypeEnum.APP, ProcessTypeEnum.DESKTOP, ProcessTypeEnum.DESKTOP);

            _currentProject.processModel.setCurrentProcess(desktopProcess);
        }

        private function initializeControllers():void
        {
            new AnalyticsController(_model, _view.stage);
            new ProjectController(_model);
            new ProcessController(_model, _view);
            new ServiceController(_model);
            new ClockController(_model);
            new UpdaterController(_model);
            new StatisticsController(_model, _view);
            new TimeSyncController(_model);
            new ToastController(_model);
        }

        private function projectsLoadedHandler(event:McEvent):void
        {
            _model.initializeState = StateEnum.INITIALIZE_PROJECTS_COMPLETE;
        }

        private function model_initialize_state_changeHandler(event:ModelEvent):void
        {
            switch (_model.initializeState)
            {
                case StateEnum.INITIALIZE_UI_COMPLETE:
                    // initialize projects;
                    _model.projectModel.load();
                    break;
                case StateEnum.INITIALIZE_PROJECTS_COMPLETE:
                    new KeyController(_model);
                    initializeControllers();
                    break;
            }
        }

        private function installExtensionHandler(event:ViewEvent):void
        {
            var command:ICommand = new InstallExtensionCommand(event.browserId, _model);
            command.execute();
        }

        private function languageChangeHandler(event:McEvent):void
        {
            projectEventHandler();
        }

        private function projectEventHandler(event:Event = null):void
        {
            _currentProject = _model.projectModel.currentProject;

            _currentProject.processModel.addEventListener(ModelEvent.PROCESS_CHANGE, process_changeHandler, false, 0, true);

            new UpdateHelpTextCommand(_model).execute();
        }

        private function dbLoadedHandler(event:McEvent = null):void
        {
            var command:ICommand = new LoadTempProcessCommand(_model);
            command.execute();
        }

        private function process_changeHandler(event:ModelEvent):void
        {
            if (_currentProject.isManual || !_currentProject.isAuto)
            {
                return;
            }

            var currentProcess:IProcess = _currentProject.processModel.currentProcess;

            trace(this, currentProcess);

            _model.currentType = currentProcess && currentProcess.isMarked ? TypeEnum.WORK : TypeEnum.REST;
        }
    }
}
