/**
 * Created by Valeriy on 22.06.2015.
 */
package org.motivateclock.controller
{

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.ProjectSyncCommand;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;

    public class ProjectController
    {
        private var _model:Model;
        private var _projectModel:ProjectsModel;
        private var _currentProject:IProject;

        public function ProjectController(model:Model)
        {
            _model = model;
            _projectModel = _model.projectModel;

            initialize();
        }

        private function initialize():void
        {
            _projectModel.addEventListener(ModelEvent.PROJECT_CHANGE, projectModel_project_changeHandler);

            projectModel_project_changeHandler();
        }

        private function projectModel_project_changeHandler(event:ModelEvent = null):void
        {
            new ProjectSyncCommand(_model, _projectModel.currentProject).execute();

            if (_currentProject)
            {
                _currentProject.processModel.removeEventListener(ModelEvent.PROCESS_ADD, processModel_process_Handler);
                _currentProject.processModel.removeEventListener(ModelEvent.PROCESS_REMOVE, processModel_process_Handler);
            }

            _currentProject = _projectModel.currentProject;

            _currentProject.processModel.addEventListener(ModelEvent.PROCESS_ADD, processModel_process_Handler, false, 0, true);
            _currentProject.processModel.addEventListener(ModelEvent.PROCESS_REMOVE, processModel_process_Handler, false, 0, true);

            Project(_currentProject).updateProjectMode();
        }

        private function processModel_process_Handler(event:ModelEvent):void
        {
            _currentProject.isChanged = true;

            Project(_currentProject).updateProjectMode();
        }
    }
}
