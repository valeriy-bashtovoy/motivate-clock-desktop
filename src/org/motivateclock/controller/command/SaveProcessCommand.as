/**
 * Created by Valeriy on 29.06.2015.
 */
package org.motivateclock.controller.command
{

    import org.motivateclock.Model;
    import org.motivateclock.enum.ProcessStateEnum;
    import org.motivateclock.events.DBEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Project;

    public class SaveProcessCommand implements ICommand
    {
        private var _model:Model;

        public function SaveProcessCommand(model:Model)
        {
            _model = model;

            _model.dataBase.addEventListener(DBEvent.DB_PROCESS_SYNC_COMPLETE, db_process_sync_completeHandler);
            _model.dataBase.addEventListener(DBEvent.DB_PROCESS_SYNC_ERROR, db_process_sync_errorHandler);
        }

        public function execute():void
        {
            const project:Project = _model.projectModel.currentProject;

            if (!project)
            {
                return;
            }

            const process:IProcess = project.processModel.currentProcess;

            if (!process)
            {
                _model.syncState = ProcessStateEnum.PROCESS_SYNC_COMPLETE;
                return;
            }

            const date:String = new Date().toDateString();

            _model.clockModel.tick();

            _model.dataBase.syncProcess(project.id, date, process.path, process.name, process.time);

            process.clear();
        }

        private function db_process_sync_completeHandler(event:DBEvent):void
        {
            _model.syncState = ProcessStateEnum.PROCESS_SYNC_COMPLETE;
        }

        private function db_process_sync_errorHandler(event:DBEvent):void
        {
            _model.syncState = ProcessStateEnum.PROCESS_SYNC_ERROR;
        }
    }
}
