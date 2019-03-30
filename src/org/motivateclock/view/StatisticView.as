package org.motivateclock.view
{

    import caurina.transitions.Tweener;

    import flash.desktop.NativeApplication;
    import flash.display.MovieClip;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowDisplayState;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.NativeWindowDisplayStateEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.StatisticViewEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IProject;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.model.icons.IconManager;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.alert.ConfirmAlert;
    import org.motivateclock.view.components.HSelector;
    import org.motivateclock.view.components.combo.ComboBox;
    import org.motivateclock.view.components.combo.ComboItemRenderer;
    import org.motivateclock.view.statistic.StatisticChartView;
    import org.motivateclock.view.statistic.StatisticMenu;
    import org.motivateclock.view.statistic.StatisticsListView;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticView extends Sprite
    {
        private static const PANEL_GAP:int = 179;
        private static const CLOSE_HEIGHT:int = 29;

        private static const PANEL_CHART_GAP:int = 3;

        private static const ITEM_RENDERER_HEIGHT:Number = 22;
        private static const NUM_VISIBLE_ITEMS:int = 9;

        private var _openButton:SimpleButton;
        private var _closeButton:SimpleButton;
        private var _arrow:MovieClip;
        private var _background:MovieClip;
        private var _labelHolder:MovieClip;
        private var _projectSelector:ComboBox;
        private var _holder:Sprite;
        private var _chartView:StatisticChartView;
        private var _menu:StatisticMenu;
        private var _scrollRect:Rectangle;
        private var _label:TextField;
        private var _labelShadow:TextField;
        private var _appListScrollRect:Rectangle;

        private var _appIsMinimized:Boolean = false;
        private var _isOpen:Boolean = false;
        private var _gfx:MovieClip;
        private var _model:Model;
        private var _mainWindow:NativeWindow;
        private var _listView:StatisticsListView;
        private var _dateRangeSelector:HSelector;

        public function StatisticView(model:Model)
        {
            _model = model;

            _mainWindow = NativeApplication.nativeApplication.openedWindows[0] as NativeWindow;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_STATISTIC_VIEW) as MovieClip;
            addChild(_gfx);

            _openButton = _gfx["openButton"];
            _closeButton = _gfx["closeButton"];
            _arrow = _gfx["arrow"];
            _background = _gfx["background"];
            _labelHolder = _gfx["labelHolder"];
        }

        public function initialize():void
        {
            _label = _labelHolder["label"];
            _labelShadow = _labelHolder["shadow"];

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _closeButton.visible = false;
            _openButton.visible = !_closeButton.visible;

            _openButton.addEventListener(MouseEvent.CLICK, mouseClickHandler);
            _closeButton.addEventListener(MouseEvent.CLICK, mouseClickHandler);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);

            languageChangeHandler();
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            if (event.ctrlKey && event.keyCode == Keyboard.S)
            {
                _isOpen ? close() : open();
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var id:String;

            if (!_isOpen)
            {
                id = TextKeyEnum.STATISTIC_OPEN;
            }
            else
            {
                id = TextKeyEnum.STATISTIC_CLOSE;
            }

            _label.htmlText = _model.languageModel.getText(id);
            _labelShadow.htmlText = _label.text;

            initializeDateRangeSelector();
        }

        private function open():void
        {
            _isOpen = true;

            dispatchEvent(new Event(Event.OPEN, true));

            Tweener.removeTweens(_background);

            init();

            _arrow.rotation = 180;
            _openButton.visible = false;
            Tweener.addTween(_background, {width: 204, time: 0.1, transition: "easeOutCubic"});
            _closeButton.visible = true;

            Tweener.removeTweens(_chartView);
            _chartView.alpha = 0;
            Tweener.addTween(_chartView, {alpha: 1, time: 0.4, transition: "easeOutCubic"});

            languageChangeHandler();

            setSize(_model.settingModel.settings.appHeight - PANEL_GAP);
        }

        public function close(time:Number = 0.1):void
        {
            _isOpen = false;

            _arrow.rotation = 0;
            languageChangeHandler();
            Tweener.removeTweens(_background);
            Tweener.addTween(_background, {width: 164, time: 0.1, transition: "easeOutCubic"});

            IconManager.getInstance().save();

            setSize(CLOSE_HEIGHT, time);

            dispose();
        }

        private function init():void
        {
            if (_holder)
            {
                return;
            }

            _scrollRect = new Rectangle(-90, 0, 250, 1);

            _holder = new Sprite();
            _holder.scrollRect = _scrollRect;
            _holder.x = _scrollRect.x;
            addChild(_holder);

            _chartView = new StatisticChartView(_model);
            _chartView.x = -88;
            _holder.addChild(_chartView);

            _listView = new StatisticsListView(NUM_VISIBLE_ITEMS, 170, ITEM_RENDERER_HEIGHT, 0);
            _listView.x = -88;
            _listView.y = 79;
            _listView.addEventListener(ViewEvent.PROCESS_ADD, process_swap_Handler, false, 0, true);
            _listView.addEventListener(ViewEvent.PROCESS_REMOVE, process_swap_Handler, false, 0, true);
            _holder.addChild(_listView);

            _appListScrollRect = new Rectangle(0, 0, 250, 1);

            _menu = new StatisticMenu(_model);
            _menu.x = -90;
            _menu.y = 57;
            _holder.addChild(_menu);

            _menu.addEventListener(Event.SELECT, menuSelectHandler, false, 0, true);
            _menu.addEventListener(ViewEvent.PROJECT_RESET, menu_project_resetHandler, false, 0, true);
            _menu.addEventListener(ViewEvent.EXPORT_PDF, menu_export_pdfHandler, false, 0, true);

            _projectSelector = new ComboBox(21);
            _projectSelector.init();
            _projectSelector.setSize(175);
            _projectSelector.x = -94;
            _projectSelector.y = 30;
            _holder.addChild(_projectSelector);
            _projectSelector.addEventListener(McEvent.ITEM_SELECTED, projectSelectHandler, false, 0, true);

            _model.skinManager.registerDisplayObject(_listView.scroll.trackButton);
            _model.skinManager.registerDisplayObject(_projectSelector.trackButton);
            _model.skinManager.registerDisplayObject(_projectSelector.openButton);

            addProjects();

            _projectSelector.selectItemByData(_model.projectModel.currentProject.id);

            ConfirmAlert.getInstance().addEventListener(McEvent.CONFIRMED, confirmHandler);
            ConfirmAlert.getInstance().addEventListener(McEvent.CANCEL, exportCancelHandler);

            _mainWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler, false, 0, true);

            _model.statisticsModel.addEventListener(ModelEvent.STAT_LIST_CHANGE, stat_list_changeHandler);
            _model.addEventListener(ModelEvent.APP_PENDING_CHANGE, model_app_pending_changeHandler);
        }

        private function model_app_pending_changeHandler(event:ModelEvent):void
        {
            _listView.update()
        }

        private function initializeDateRangeSelector():void
        {
            if (!_dateRangeSelector)
            {
                return;
            }

            const labelList:Array = _model.languageModel.getText(TextKeyEnum.STATISTIC_DATE_RANGE).split(",");
            const dataProvider:Vector.<Object> = new <Object>[];
            const length:int = labelList.length;

            var label:String;

            for (var i:int = 0; i < length; i++)
            {
                label = labelList[i];
                dataProvider.push({label: label, data: i});
            }

            _dateRangeSelector.setDataProvider(dataProvider);
        }

        /**
         * Created because if application is minimized and setSize method is called,
         * then the application restores.
         */
        private function displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void
        {
            if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
            {
                _appIsMinimized = true;
            }
            else
            {
                _appIsMinimized = false;
            }
        }

        private function dispose():void
        {
            if (!_holder)
            {
                return;
            }

            _model.skinManager.unregisterDisplayObject(_listView.scroll.trackButton);
            _model.skinManager.unregisterDisplayObject(_projectSelector.trackButton);
            _model.skinManager.unregisterDisplayObject(_projectSelector.openButton);

            removeChild(_holder);

            _chartView.dispose();
            _chartView = null;

            if (_dateRangeSelector)
            {
                _dateRangeSelector.dispose();
                _dateRangeSelector.removeEventListener(ViewEvent.SELECT, dateRangeSelector_selectHandler);
                _dateRangeSelector = null;
            }

            _listView.dispose();
            _listView.removeEventListener(ViewEvent.PROCESS_ADD, process_swap_Handler, false);
            _listView.removeEventListener(ViewEvent.PROCESS_REMOVE, process_swap_Handler, false);
            _listView = null;

            _holder = null;
            _menu = null;
            _projectSelector = null;

            _appIsMinimized = false;

            ConfirmAlert.getInstance().removeEventListener(McEvent.CONFIRMED, confirmHandler);
            ConfirmAlert.getInstance().removeEventListener(McEvent.CANCEL, exportCancelHandler);

            _model.statisticsModel.removeEventListener(ModelEvent.STAT_LIST_CHANGE, stat_list_changeHandler);
            _model.removeEventListener(ModelEvent.APP_PENDING_CHANGE, model_app_pending_changeHandler);

            _mainWindow.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
        }

        private function setSize(newHeight:int, time:Number = 0.2):void
        {
            if (_appIsMinimized)
            {
                return;
            }

            if (_chartView)
            {
                _chartView.y = newHeight - _chartView.height + PANEL_CHART_GAP;
            }

            Tweener.addTween(_background, {
                height: newHeight,
                time: time,
                transition: "easeOutCubic",
                onComplete: sizeCompleteHandler,
                onUpdate: sizeUpdateHandler
            });

            var e:McEvent = new McEvent(McEvent.RESIZE_MAIN);
            e.size = newHeight + PANEL_GAP;
            e.time = time;
            dispatchEvent(e);
        }

        private function addProjects():void
        {
            var projects:Vector.<Project> = _model.projectModel.projectsList.concat();

            var item:ComboItemRenderer;

            for each (var project:Project in projects)
            {
                item = new ComboItemRenderer(project.name, 169);
                item.data = project.id;
                _projectSelector.addItem(item, item.height - 6);

                if (project.id == ProjectsModel.MANUAL_MODE)
                {
                    item.setColor(0x0a485c, true);
                }
            }
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _openButton:
                    open();
                    break;
                case _closeButton:
                    close();
                    break;
            }
        }

        private function sizeUpdateHandler():void
        {
            if (_holder)
            {
                _scrollRect.height = _background.height;
                _scrollRect.width = _background.width;
                _holder.scrollRect = _scrollRect;
            }
        }

        private function sizeCompleteHandler():void
        {
            if (!_isOpen)
            {
                _closeButton.visible = false;
                _openButton.visible = !_closeButton.visible;
            }
        }

        private function projectSelectHandler(event:McEvent):void
        {
            updateStatistics();

            _chartView.setProject(_model.projectModel.getProjectById(_projectSelector.data));
        }

        private function updateStatistics():void
        {
            var e:StatisticViewEvent = new StatisticViewEvent(StatisticViewEvent.STATISTIC_SELECT);
            e.projectId = _projectSelector.data;
            e.category = _menu.type;
            e.range = "";
            dispatchEvent(e);
        }

        private function menuSelectHandler(event:Event):void
        {
            updateStatistics();
        }

        private function exportCancelHandler(event:McEvent):void
        {
            if (event.messageType == ConfirmAlert.EXPORT)
            {
                dispatchEvent(new ViewEvent(ViewEvent.EXPORT_CANCEL));
            }
        }

        private function confirmHandler(event:McEvent):void
        {
            if (event.messageType == ConfirmAlert.RESET)
            {
                var e:ViewEvent = new ViewEvent(ViewEvent.PROJECT_RESET);
                e.projectId = _projectSelector.data;
                dispatchEvent(e);
                //update();
            }
        }

        private function menu_project_resetHandler(event:ViewEvent):void
        {
            ConfirmAlert.getInstance().show(ConfirmAlert.RESET);
        }

        private function menu_export_pdfHandler(event:ViewEvent):void
        {
            ConfirmAlert.getInstance().show(ConfirmAlert.EXPORT);

            var e:ViewEvent = new ViewEvent(ViewEvent.EXPORT_PDF);
            e.projectId = _projectSelector.data;
            dispatchEvent(e);
        }

        private function stat_list_changeHandler(event:ModelEvent):void
        {
            const project:IProject = _model.statisticsModel.currentProject;

            _listView.enabled = project.isAuto;
            _listView.setDataProvider(Vector.<Object>(_model.statisticsModel.processList), false);
        }

        private function dateRangeSelector_selectHandler(event:ViewEvent):void
        {
        }

        private function process_swap_Handler(event:ViewEvent):void
        {
            event.stopPropagation();
            // inject current selected project;
            event.projectId = _projectSelector.data;
            dispatchEvent(event);
        }
    }
}
