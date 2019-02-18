/**
 * Created by Valeriy Bashtovoy on 29.07.2015.
 */
package org.motivateclock.controller
{

    import flash.display.DisplayObject;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.ProjectSyncCommand;
    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.events.DBEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.StatisticViewEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.interfaces.IStatisticsModel;
    import org.motivateclock.model.Project;

    public class StatisticsController
    {
        private var _view:DisplayObject;
        private var _model:Model;
        private var _statisticsModel:IStatisticsModel;
        private var _currentProcessTime:Number = 0;

        public function StatisticsController(model:Model, view:DisplayObject)
        {
            _model = model;
            _statisticsModel = model.statisticsModel;
            _view = view;

            initialize();
        }

        private function initialize():void
        {
            _model.dataBase.addEventListener(DBEvent.DB_STATISTICS_LOAD_COMPLETE, db_statistics_load_completeHandler);

            _view.addEventListener(StatisticViewEvent.STATISTIC_SELECT, view_statistic_selectHandler);
            _view.addEventListener(ViewEvent.PROJECT_RESET, view_project_resetHandler);
            _view.addEventListener(ViewEvent.EXPORT_PDF, view_export_pdfHandler);
            _view.addEventListener(ViewEvent.EXPORT_CANCEL, view_export_pdfHandler);
        }

        private function db_statistics_load_completeHandler(event:DBEvent):void
        {
            var project:IProject = _statisticsModel.currentProject;

            if (!project || project.id != event.projectId)
            {
                return;
            }

            var length:int = event.processList ? event.processList.length : 0;
            var process:IProcess;

            for (var i:int = 0; i < length; i++)
            {
                process = event.processList[i];
                process.type = getProcessType(process.path);
                process.isMarked = project.processModel.has(process);
            }

            _model.statisticsModel.processList = event.processList;

            process_changeHandler();
            process_process_time_changeHandler();

            trace(this, event.projectId, _model.statisticsModel.processList.length);
        }

        private function getProcessType(path:String):String
        {
            var type:String = ProcessTypeEnum.APP;

            if (path.indexOf("\\") == -1 && path != ProcessTypeEnum.DESKTOP)
            {
                type = ProcessTypeEnum.SITE;
            }

            return type;
        }

        private function view_statistic_selectHandler(event:StatisticViewEvent):void
        {
            trace(this, "view_statistic_selectHandler", event.projectId, event.range, event.category);

            var project:Project = _model.projectModel.getProjectById(event.projectId);

            if (!project)
            {
                return;
            }

            _statisticsModel.currentProject = project;

            if (project.id == _model.projectModel.currentProject.id)
            {
                project.processModel.addEventListener(ModelEvent.PROCESS_CHANGE, process_changeHandler, false, 0, true);
            }
            else
            {
                new ProjectSyncCommand(_model, project).execute();
            }

            _model.dataBase.getStatistics(event.projectId, event.category, event.range, project.processModel.processList);
        }

        private function view_project_resetHandler(event:ViewEvent):void
        {
            trace(this, "view_project_resetHandler", event.projectId);

            _model.projectModel.resetProject(_model.projectModel.getProjectById(event.projectId));

            _statisticsModel.processList = new <IProcess>[];

            _currentProcessTime = 0;
        }

        private function view_export_pdfHandler(event:ViewEvent):void
        {
            switch (event.type)
            {
                case ViewEvent.EXPORT_PDF:
                    trace(this, "view_export_pdfHandler", event.type, event.projectId);
                    _model.exporter.exportToPdf(event.projectId);
                    break;
                case ViewEvent.EXPORT_CANCEL:
                    trace(this, "view_export_pdfHandler", event.type);
                    _model.exporter.cancel();
                    break;
            }
        }

        private function process_changeHandler(event:ModelEvent = null):void
        {
            const currentProject:IProject = _statisticsModel.currentProject;

            if (!currentProject)
            {
                return;
            }

            const process:IProcess = currentProject.processModel.currentProcess;

            if (!process)
                return;

            process.addEventListener(ModelEvent.PROCESS_TIME_CHANGE, process_process_time_changeHandler, false, 0, true);

            if (!_statisticsModel.hasProcess(process))
            {
                _statisticsModel.addProcess(process.clone());
            }

            _statisticsModel.currentProcess = _statisticsModel.getProcess(process.id);

            _currentProcessTime = _statisticsModel.currentProcess.time;
        }

        private function process_process_time_changeHandler(event:ModelEvent = null):void
        {
            var process:IProcess = _statisticsModel.currentProject.processModel.currentProcess;

            if (!process)
                return;

            _statisticsModel.updateCurrentProcess(_currentProcessTime + process.time);
        }
    }
}
