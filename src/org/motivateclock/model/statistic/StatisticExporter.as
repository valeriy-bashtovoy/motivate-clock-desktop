package org.motivateclock.model.statistic
{

    import flash.events.EventDispatcher;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.ProjectSyncCommand;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.view.alert.ConfirmAlert;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticExporter extends EventDispatcher
    {
        private var _projectId:String;
        private var _dataBase:DataBase;
        private var _statisticResults:Array;
        private var _pdf:PDF;

        private var _model:Model;

        public function StatisticExporter(model:Model)
        {
            _model = model;

            _dataBase = DataBase.getInstance();
        }

        public function cancel():void
        {
            _dataBase.removeEventListener(McEvent.STATISTIC_BY_DAY_OBTAINED, statisticResultHandler);

            _model.isPending = false;

            if (_pdf)
            {
                _pdf.cancel();
                pdfSaveHandler();
            }
        }

        public function exportToPdf(projectId:String):void
        {
            _projectId = projectId;

            const project:IProject = _model.projectModel.getProjectById(_projectId);

            _model.addEventListener(ModelEvent.PROJECT_SYNC_COMPLETE, model_project_sync_completeHandler);

            new ProjectSyncCommand(_model, project).execute();
        }

        private function model_project_sync_completeHandler(event:ModelEvent):void
        {
            _model.removeEventListener(ModelEvent.PROJECT_SYNC_COMPLETE, model_project_sync_completeHandler);

            getStatistics();
        }

        private function getStatistics():void
        {
            _model.isPending = true;
            _dataBase.addEventListener(McEvent.STATISTIC_BY_DAY_OBTAINED, statisticResultHandler);
            //TODO add ability to get statistics for current project from ProcessModel;
            _dataBase.getStatisticsByDay(_projectId);
        }


        private function statisticResultHandler(event:McEvent):void
        {
            _dataBase.removeEventListener(McEvent.STATISTIC_BY_DAY_OBTAINED, statisticResultHandler);
            _statisticResults = event.result;
            createPdf();
        }

        private function createPdf():void
        {
            _pdf = new PDF(_model);
            _pdf.addEventListener(McEvent.PDF_SAVED, pdfSaveHandler);
            _pdf.create(_projectId, _statisticResults);
        }

        private function pdfSaveHandler(event:McEvent = null):void
        {
            _pdf.removeEventListener(McEvent.PDF_SAVED, pdfSaveHandler);
            _pdf = null;
            ConfirmAlert.getInstance().hide();
            _model.isPending = false;
        }
    }
}
