/**
 * User: Valeriy Bashtovoy
 * Date: 18.11.13
 */
package org.motivateclock.controller.command
{

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;

    public class UpdateHelpTextCommand implements ICommand
    {
        private var _model:Model;
        private var _projectModel:ProjectsModel;

        public function UpdateHelpTextCommand(model:Model)
        {
            _model = model;
            _projectModel = _model.projectModel;
        }

        public function getUpdateText():String
        {
            var updateText:String = _model.languageModel.getText(TextKeyEnum.ABOUT_UPDATE_NEW) + "<br>" +
                    "<a href='" + _model.updaterModel.downloadUrl + "'>Motivate Clock " + _model.updaterModel.latestVersionLabel + "</a>";

            return updateText;
        }

        public function execute():void
        {
            const projectList:Vector.<Project> = _projectModel.projectsList;
            const project:Project = _projectModel.currentProject;

            if (_model.updaterModel.hasNewVersion)
            {
                _model.projectsHelpText = getUpdateText();
                return;
            }

            if (!project)
            {
                return;
            }

            if (projectList.length == 1)
            {
                _model.projectsHelpText = _model.languageModel.getText(TextKeyEnum.PROJECT_PROMPT_CREATE_NEW);
                return;
            }

            if (project.isAuto || project.isManual)
            {
                _model.projectsHelpText = _model.languageModel.getText(TextKeyEnum.PROJECT_PROMPT_EXTENSION);
            }
            else
            {
                _model.projectsHelpText = _model.languageModel.getText(TextKeyEnum.PROJECT_PROMPT_ADD_APPS);
            }
        }
    }
}
