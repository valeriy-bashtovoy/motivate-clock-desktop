package org.motivateclock.view.statistic
{

    import caurina.transitions.Tweener;

    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.text.TextField;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.settings.Settings;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.DisplayObjectUtils;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticChartView extends MovieClip
    {
        private var _restTimeField:TextField;
        private var _workTimeField:TextField;
        private var _workPctField:TextField;
        private var _restPctField:TextField;
        private var _restDayBox:MovieClip;
        private var _workDayBox:MovieClip;
        private var _circleMask:MovieClip;
//        private var _restLabel:TextField;
//        private var _workLabel:TextField;

        private var _workNumDays:TextField;
        private var _workNameDays:TextField;
        private var _restNumDays:TextField;
        private var _restNameDays:TextField;
        private var _circleBox:Sprite;

        private var _dayCollection:Array = [];
        private var _currentWorkPercent:int = 0;
        private var _currentRestPercent:int = 0;
        private var _chartShape:Shape;
        private var _project:Project;
        private var _fontSize:int;
        private var _gfx:MovieClip;
        private var _model:Model;
        private var _settings:Settings;

        public function StatisticChartView(model:Model)
        {
            _model = model;
            _settings = _model.settingModel.settings;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_STATISTIC_CHART_VIEW) as MovieClip;
            addChild(_gfx);

            _restTimeField = _gfx["restTimeField"];
            _workTimeField = _gfx["workTimeField"];
            _workPctField = _gfx["workPctField"];
            _restPctField = _gfx["restPctField"];
            _restDayBox = _gfx["restDayBox"];
            _workDayBox = _gfx["workDayBox"];
            _circleMask = _gfx["circleMask"];
//            _restLabel = _gfx["restLabel"];
//            _workLabel = _gfx["workLabel"];

            _circleBox = new Sprite();
            _circleBox.x = 26;
            _circleBox.y = 29.5;
            addChild(_circleBox);

            _circleBox.mask = _circleMask;

            _workNumDays = _workDayBox.getChildByName('numDays') as TextField;
            _workNameDays = _workDayBox.getChildByName('nameDays') as TextField;

            _restNumDays = _restDayBox.getChildByName('numDays') as TextField;
            _restNameDays = _restDayBox.getChildByName('nameDays') as TextField;

//            _workDayBox.alpha = 0;
//            _restDayBox.alpha = 0;

            _chartShape = new Shape();
            _circleBox.addChild(_chartShape);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();
        }

        public function setProject(project:Project):void
        {
            _project = project;

            if (!_project)
            {
                return;
            }

            _project.addEventListener(ModelEvent.PROJECT_TIME_CHANGE, project_time_changeHandler, false, 0, true);

            update();
        }

        public function dispose():void
        {
            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            if (_project)
            {
                _project.removeEventListener(ModelEvent.PROJECT_TIME_CHANGE, project_time_changeHandler);
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _fontSize = 15;

            _dayCollection = _model.languageModel.getText(TextKeyEnum.DAY).split(",");
        }

        override public function get height():Number
        {
            return _restDayBox.y + _restDayBox.height;
        }

        private function update():void
        {
            const totalTime:Number = _project.workTime + _project.restTime;
            const workPercent:int = Math.ceil(_project.workTime / totalTime * 100);
            const restPercent:int = Math.floor(_project.restTime / totalTime * 100);

            if (_currentWorkPercent != workPercent || _currentRestPercent != restPercent)
            {
                drawChart(workPercent / 100, restPercent / 100, 47);
            }

            _currentWorkPercent = workPercent;
            _currentRestPercent = restPercent;

            _workPctField.htmlText = "<b><font size='22'>" + workPercent + "</font><font size='14'> %</font></b>";
            _restPctField.htmlText = "<b><font size='22'>" + restPercent + "</font><font size='14'> %</font></b>";

            var wTime:Object = TimeUtils.convertSeconds(_project.workTime, _settings.workingHours);
            _workTimeField.htmlText = wTime.hour + ":" + wTime.min + ":" + wTime.sec;

            var rTime:Object = TimeUtils.convertSeconds(_project.restTime, _settings.workingHours);
            _restTimeField.htmlText = rTime.hour + ":" + rTime.min + ":" + rTime.sec;

            _workNumDays.htmlText = wTime.day;
            _workNameDays.htmlText = TimeUtils.getDeclensionNumberName(wTime.day, _dayCollection);

            _restNumDays.htmlText = rTime.day;
            _restNameDays.htmlText = TimeUtils.getDeclensionNumberName(rTime.day, _dayCollection);

            dim(_workDayBox, int(wTime.day) == 0);
            dim(_restDayBox, int(rTime.day) == 0);

            if (_workDayBox.visible && _workDayBox.alpha == 0)
            {
                Tweener.addTween(_workDayBox, {alpha: 1, time: 0.3, transition: "easeInCubic"});
            }

            if (_restDayBox.visible && _restDayBox.alpha == 0)
            {
                Tweener.addTween(_restDayBox, {alpha: 1, time: 0.3, transition: "easeInCubic"});
            }
        }

        private function dim(target:DisplayObject, value:Boolean):void
        {
            if (value)
            {
                target.alpha = 0.5;
                DisplayObjectUtils.setGrayscale(target)
            }
            else
            {
                target.alpha = 1;
                target.filters = [];
            }
        }

        private function drawChart(workPct:Number, restPct:Number, radius:Number):void
        {
            var color:uint = 0xb4b51f;

            if (workPct == 0 && restPct == 0)
            {
                color = 0xf0efe8;
            }

            _circleBox.graphics.clear();
            _circleBox.graphics.beginFill(color);
            _circleBox.graphics.drawCircle(0, 0, radius);

            DrawPieChart.drawChart(_chartShape, radius + 1, restPct, 0xbb0d0d, -90, 0, 0xf0efe8);
        }

        private function project_time_changeHandler(event:ModelEvent):void
        {
            update();
        }
    }
}
