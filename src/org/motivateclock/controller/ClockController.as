/**
 * Created by Valeriy on 31.10.2014.
 */
package org.motivateclock.controller
{

    import org.motivateclock.Model;
    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;

    public class ClockController
    {
        private var _model:Model;

        public function ClockController(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            _model.clockModel.addEventListener(ModelEvent.CLOCK_TICK, clock_tickHandler);

            _model.clockModel.initialize();
        }

        private function clock_tickHandler(event:ModelEvent):void
        {
            updateProjectTime(_model.projectModel.currentProject, event.timeRange);
        }

        private function updateProjectTime(project:Project, timeRange:Number):void
        {
            if (!project)
            {
                trace(this, "Warning. Project can't be found;");
                return;
            }

            switch (_model.currentType)
            {
                case TypeEnum.REST:
                    project.restTime += timeRange;
                    break;
                case TypeEnum.WORK:
                    project.workTime += timeRange;
                    break;
                case TypeEnum.IDLE:
                    project.idleTime += timeRange;
                    break;
            }
        }
    }
}
