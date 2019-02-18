/**
 * Created by Valeriy on 22.06.2015.
 */
package org.motivateclock.controller.command
{

    import org.motivateclock.Model;
    import org.motivateclock.events.DBEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.model.statistic.DataBase;

    public class ProjectSyncCommand implements ICommand
    {
        private var _model:Model;
        private var _project:IProject;
        private var _dataBase:DataBase;
        private var _projectTime:Number;
        private var _processesTime:Number;

        public function ProjectSyncCommand(model:Model, project:IProject)
        {
            _model = model;
            _project = project;
            _dataBase = _model.dataBase;
        }

        public function execute():void
        {
            _model.isPending = true;

            if (!_project || _project.isManual || !_project.isAuto)
            {
                _model.isPending = false;
                return;
            }

            _project.workTime = 0;
            _project.restTime = 0;

            _dataBase.addEventListener(DBEvent.DB_PROJECT_TIME_LOAD_COMPLETE, db_project_time_load_completeHandler);
            _dataBase.addEventListener(DBEvent.DB_PROCESSES_TIME_LOAD_COMPLETE, db_processes_time_load_completeHandler);

            _dataBase.getProjectTime(_project.id);
        }

        private function db_project_time_load_completeHandler(event:DBEvent):void
        {
            if (_project.id != event.projectId || event.projectTime == 0)
            {
                _model.isPending = false;
                return;
            }

            _projectTime = event.projectTime;

            _dataBase.getProcessesTime(_project.id, _project.processModel.processList);
        }

        private function db_processes_time_load_completeHandler(event:DBEvent):void
        {
            if (_project.id != event.projectId)
            {
                return;
            }

            _processesTime = event.processesTime;

            updateProjectTime();

            _model.isPending = false;

            _model.dispatchEvent(new ModelEvent(ModelEvent.PROJECT_SYNC_COMPLETE));
        }

        private function updateProjectTime():void
        {
            _project.workTime = _processesTime;
            _project.restTime = _projectTime - _processesTime;

            trace(this, _project.name, "workTime:", _project.workTime, "restTime:", _project.restTime, "idleTime:", _project.idleTime);

            _dataBase.removeEventListener(DBEvent.DB_PROJECT_TIME_LOAD_COMPLETE, db_project_time_load_completeHandler);
            _dataBase.removeEventListener(DBEvent.DB_PROCESSES_TIME_LOAD_COMPLETE, db_processes_time_load_completeHandler);
        }
    }
}
