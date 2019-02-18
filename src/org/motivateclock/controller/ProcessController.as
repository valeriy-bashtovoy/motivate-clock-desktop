/**
 * Created by Valeriy on 23.11.2014.
 */
package org.motivateclock.controller
{

    import flash.display.DisplayObject;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.SaveProcessCommand;
    import org.motivateclock.controller.command.TempSaveProcessCommand;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IProcessModel;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.model.Project;

    public class ProcessController
    {
        private var _model:Model;
        private var _currentProject:Project;
        private var _view:DisplayObject;
        private var _processModel:IProcessModel;
        private var _saveProcessCommand:ICommand;

        public function ProcessController(model:Model, view:DisplayObject)
        {
            _model = model;
            _view = view;

            initialize();
        }

        private function initialize():void
        {
            _saveProcessCommand = new SaveProcessCommand(_model);

            _view.addEventListener(ViewEvent.PROCESS_ADD, view_process_addHandler);
            _view.addEventListener(ViewEvent.PROCESS_REMOVE, view_process_removeHandler);

            _model.projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, projectChangedHandler);
            _model.addEventListener(ModelEvent.NEW_PROCESS_READY, model_new_process_readyHandler);
            _model.clockModel.addEventListener(ModelEvent.CLOCK_TICK, clock_tickHandler);
            _model.applicationManager.addEventListener(ModelEvent.APPLICATION_EXITING, application_exitingHandler);

            projectChangedHandler();
        }

        private function projectChangedHandler(event:ModelEvent = null):void
        {
            _currentProject = _model.projectModel.currentProject;
            _processModel = _currentProject.processModel;
        }

        private function model_new_process_readyHandler(event:ModelEvent):void
        {
            saveProcess();

            _processModel.setCurrentProcess(event.process);
        }

        private function saveProcess():void
        {
            _saveProcessCommand.execute();
        }

        private function clock_tickHandler(event:ModelEvent):void
        {
            _processModel.increaseCurrentProcessTime(event.timeRange);
        }

        private function application_exitingHandler(event:ModelEvent):void
        {
            var command:ICommand;

            if (event.isEmergency)
            {
                command = new TempSaveProcessCommand(_model, _processModel.currentProcess);
                command.execute();
            }
            else
            {
                saveProcess();
            }
        }

        private function view_process_addHandler(event:ViewEvent):void
        {
            trace(this, "view_process_addHandler", event);

            const project:IProject = _model.projectModel.getProjectById(event.projectId);

            if (!project)
            {
                trace(this, "Project with id: " + event.projectId + " can't be found;");
                return;
            }

            project.processModel.add(event.process);
        }

        private function view_process_removeHandler(event:ViewEvent):void
        {
            trace(this, "view_process_removeHandler", event);

            const project:IProject = _model.projectModel.getProjectById(event.projectId);

            if (!project)
            {
                trace(this, "Project with id: " + event.projectId + " can't be found;");
                return;
            }

            project.processModel.remove(event.process);
        }
    }
}
