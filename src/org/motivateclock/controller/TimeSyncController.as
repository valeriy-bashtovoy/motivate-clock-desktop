/**
 * Created by Valeriy Bashtovoy on 15.11.2015.
 */
package org.motivateclock.controller
{

    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.ProjectSyncCommand;
    import org.motivateclock.controller.command.SaveProcessCommand;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;

    public class TimeSyncController
    {
        public static const DELAY:int = 2000;

        private var _model:Model;
        private var _syncTimer:Timer;
        private var _project:Project;

        public function TimeSyncController(model:Model)
        {
            _model = model;

            _syncTimer = new Timer(DELAY, 1);
            _syncTimer.addEventListener(TimerEvent.TIMER, syncTimer_timerHandler);

            _model.projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, projectChangedHandler);
            _model.addEventListener(ModelEvent.APP_PENDING_CHANGE, model_app_pending_changeHandler);

            projectChangedHandler();
        }

        private function process_Handler(event:ModelEvent):void
        {
            _syncTimer.stop();
            _syncTimer.start();
        }

        private function syncTimer_timerHandler(event:TimerEvent):void
        {
            trace(this, "syncTimer_timerHandler");

            _model.isPending = true;

            _model.addEventListener(ModelEvent.PROCESS_SYNC_STATE_CHANGE, model_process_sync_state_changeHandler);

            new SaveProcessCommand(_model).execute();
        }

        private function model_process_sync_state_changeHandler(event:ModelEvent):void
        {
            _model.removeEventListener(ModelEvent.PROCESS_SYNC_STATE_CHANGE, model_process_sync_state_changeHandler);

            new ProjectSyncCommand(_model, _project).execute();
        }

        private function projectChangedHandler(event:Event = null):void
        {
            trace(this, "projectChangedHandler");

            if (_project)
            {
                _project.processModel.removeEventListener(ModelEvent.PROCESS_ADD, process_Handler);
                _project.processModel.removeEventListener(ModelEvent.PROCESS_REMOVE, process_Handler);
            }

            _project = _model.projectModel.currentProject;
            _project.processModel.addEventListener(ModelEvent.PROCESS_ADD, process_Handler);
            _project.processModel.addEventListener(ModelEvent.PROCESS_REMOVE, process_Handler);

            _syncTimer.stop();
        }

        private function model_app_pending_changeHandler(event:ModelEvent):void
        {
            _model.isPending ? _model.clockModel.stop() : _model.clockModel.start();
        }
    }
}
