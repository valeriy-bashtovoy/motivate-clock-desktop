package org.motivateclock.view.projects.setting
{

    import caurina.transitions.Tweener;

    import flash.desktop.ClipboardFormats;
    import flash.desktop.NativeDragManager;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.NativeDragEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Process;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.URIUtil;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.components.Scroll;
    import org.motivateclock.view.components.SmartContainer;
    import org.motivateclock.view.components.TextArea;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class InternetSettingView extends MovieClip
    {
        private static const NUM_VISIBLE_ITEMS:int = 8;
        private static const GAP_VERTICAL:int = 9;

        private var _targetArea:MovieClip;
        private var _addButton:SimpleButton;
        private var _urlField:TextField;
        private var _searchBar:MovieClip;

        private var _project:Project;
        private var _scroll:Scroll;
        private var _itemRendererHeight:int = 24;
        private var _baseText:String = "http://";
        private var _scrollContentHolder:Sprite;
        private var _projectsModel:ProjectsModel;
        private var _itemRendererList:Array = [];

        private var _targetField:TextField;
        private var _gfx:MovieClip;
        private var _smartContainer:SmartContainer;
        private var _contentHolder:Sprite;
        private var _browserInstallView:BrowserInstallView;
        private var _dragEnterFrame:MovieClip;
        private var _model:Model;
        private var _helpField:TextArea;

        public function InternetSettingView(project:Project, model:Model)
        {
            _project = project;
            _model = model;
            initialize();
        }

        private function initialize():void
        {
            _projectsModel = _model.projectModel;


            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_INTERNET_SETTING_VIEW) as MovieClip;
            addChild(_gfx);

            _searchBar = _gfx["searchBar"];
            _targetArea = _gfx["targetArea"];
            _addButton = _searchBar["addButton"];
            _urlField = _searchBar["urlField"];
            _targetField = _targetArea["targetField"] as TextField;
            _dragEnterFrame = _targetArea["dragEnterFrame"] as MovieClip;

            _contentHolder = new Sprite();
            _contentHolder.x = 25;
            _contentHolder.y = 46;
            addChild(_contentHolder);

            _browserInstallView = new BrowserInstallView(_model);

            _helpField = new TextArea();
            _helpField.initialize(198, 50, 0x5e6064, 12, TextArea.LIB_MYRIAD_PRO_SEMIBOLD);
            _helpField.autoSize = TextFieldAutoSize.CENTER;
            _helpField.align = TextFormatAlign.CENTER;
            _helpField.x = -15;

            _targetArea.mouseChildren = false;

            _scrollContentHolder = new Sprite();

            _scroll = new Scroll(181, _itemRendererHeight * NUM_VISIBLE_ITEMS, _itemRendererHeight, 0);
            _scroll.x = -10;
            _scroll.setContent(_scrollContentHolder);

            _model.skinManager.registerDisplayObject(_scroll.trackButton);

            _smartContainer = new SmartContainer(_contentHolder, SmartContainer.VERTICAL);
            _smartContainer.offset = GAP_VERTICAL;

            _smartContainer.addItem(_browserInstallView);
            _smartContainer.addItem(_targetArea);
            _smartContainer.addItem(_helpField);
            _smartContainer.addItem(_searchBar);
            _smartContainer.addItem(_scroll);

            languageChangeHandler();

            for each (var process:IProcess in _project.processModel.processList)
            {
                add(process);
            }

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);

            _urlField.addEventListener(FocusEvent.FOCUS_IN, focusHandler, false, 0, true);
            _urlField.addEventListener(FocusEvent.FOCUS_OUT, focusHandler, false, 0, true);

            _targetArea.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler, false, 0, true);
            _targetArea.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler, false, 0, true);
            _targetArea.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragHandler, false, 0, true);

            _addButton.addEventListener(MouseEvent.MOUSE_OVER, addButtonEventHandler, false, 0, true);
            _addButton.addEventListener(MouseEvent.MOUSE_OUT, addButtonEventHandler, false, 0, true);
            _addButton.addEventListener(MouseEvent.CLICK, addButtonEventHandler, false, 0, true);

            this.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler, false, 0, true);
        }

        private function addButtonEventHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.CLICK:
                    addSite(_urlField.text);
                    break;
                case MouseEvent.MOUSE_OUT:
                    Hint.getInstance().hide();
                    break;
                case MouseEvent.MOUSE_OVER:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROCESSES_SITE_ADD));
                    break;
            }
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _helpField.htmlText = _model.languageModel.getText(TextKeyEnum.PROCESSES_SITE_INSERT);
            _targetField.htmlText = _model.languageModel.getText(TextKeyEnum.PROCESSES_SITE_DRAG);

            _smartContainer.update();
        }

        private function dragHandler(event:NativeDragEvent):void
        {
            switch (event.type)
            {
                case NativeDragEvent.NATIVE_DRAG_ENTER:
                    NativeDragManager.acceptDragDrop(_targetArea);
                    setTargetContrast(-1.5);
                    break;
                case NativeDragEvent.NATIVE_DRAG_DROP:
                    addSite(String(event.clipboard.getData(ClipboardFormats.TEXT_FORMAT)));
                case NativeDragEvent.NATIVE_DRAG_EXIT:
                    setTargetContrast(0);
                    break;
            }
        }

        private function setTargetContrast(value:Number):void
        {
            Tweener.addTween(_dragEnterFrame, {_contrast: value, time: 0.5, transition: "easeOutCubic"});
            Tweener.addTween(_targetField, {_contrast: value, time: 0.5, transition: "easeOutCubic"});
        }

        private function keyHandler(event:KeyboardEvent):void
        {
            switch (event.keyCode)
            {
                case Keyboard.ESCAPE:
                    break;
                case Keyboard.ENTER:
                    this.stage.focus = this;
                    addSite(_urlField.text);
                    break;
            }
        }

        private function focusHandler(event:FocusEvent):void
        {
            switch (event.type)
            {
                case FocusEvent.FOCUS_IN:
                    if (_urlField.text == _baseText)
                    {
                        _urlField.text = "";
                        _urlField.textColor = 0x252628;
                    }
                    break;
                case FocusEvent.FOCUS_OUT:
                    if (_urlField.text == "")
                    {
                        _urlField.text = _baseText;
                        _urlField.textColor = 0xB6B6B6;
                    }
                    break;
            }
        }

        public function dispose():void
        {
            _model.skinManager.unregisterDisplayObject(_scroll.trackButton);

            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _urlField.removeEventListener(FocusEvent.FOCUS_IN, focusHandler);
            _urlField.removeEventListener(FocusEvent.FOCUS_OUT, focusHandler);
            _targetArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler);
            _targetArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler);
            _targetArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragHandler);
            _addButton.removeEventListener(MouseEvent.MOUSE_OVER, addButtonEventHandler);
            _addButton.removeEventListener(MouseEvent.MOUSE_OUT, addButtonEventHandler);
            _addButton.removeEventListener(MouseEvent.CLICK, addButtonEventHandler);

            this.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
        }

        private function addSite(url:String):void
        {
            if (url == _baseText)
            {
                return;
            }

            var process:IProcess = new Process(ProcessTypeEnum.SITE);
            process.type = ProcessTypeEnum.SITE;
            process.path = URIUtil.getDomainFromURI(url);
            process.name = process.path;

            if (exist(process) || !process.path)
            {
                return;
            }

            _urlField.text = _baseText;
            _urlField.textColor = 0xB6B6B6;

            var viewEvent:ViewEvent = new ViewEvent(ViewEvent.PROCESS_ADD);
            viewEvent.projectId = _project.id;
            viewEvent.process = process;
            stage.dispatchEvent(viewEvent);
        }

        private function exist(process:IProcess):Boolean
        {
            for each (var itemRenderer:ProcessItemRenderer in _itemRendererList)
            {
                if (itemRenderer.process.id == process.id)
                {
                    return true;
                }
            }

            return false;
        }

        public function add(process:IProcess, withChecking:Boolean = true):void
        {
            if (process.type != ProcessTypeEnum.SITE)
            {
                return;
            }

            if (withChecking && exist(process))
            {
                return;
            }

            var itemRenderer:ProcessItemRenderer = new ProcessItemRenderer(process);
            itemRenderer.enableSiteMode();
            itemRenderer.addEventListener(Event.CLOSE, removeItemRendererHandler);

            _itemRendererList.unshift(itemRenderer);

            reposit();
        }

        private function removeItemRendererHandler(event:Event):void
        {
            var itemRenderer:ProcessItemRenderer = event.currentTarget as ProcessItemRenderer;

            var viewEvent:ViewEvent = new ViewEvent(ViewEvent.PROCESS_REMOVE);
            viewEvent.projectId = _project.id;
            viewEvent.process = itemRenderer.process;
            stage.dispatchEvent(viewEvent);
        }

        private function reposit():void
        {
            var startX:int = 12;
            var startY:int = 14;
            var itemRenderer:ProcessItemRenderer;

            for each (itemRenderer in _itemRendererList)
            {
                itemRenderer.x = startX;
                itemRenderer.y = startY;
                itemRenderer.hideSeparator();

                startY += _itemRendererHeight;
            }

            if (itemRenderer)
            {
                itemRenderer.showSeparator();
            }

            _scroll.reset();
            _scroll.contentHeight = _itemRendererList.length * _itemRendererHeight;
            _scroll.itemRendererCollection = _itemRendererList;
            _scroll.update();
        }

        public function remove(process:IProcess):void
        {
            var itemRenderer:ProcessItemRenderer;
            var length:int = _itemRendererList.length;

            for (var i:int = 0; i < length; i++)
            {
                itemRenderer = _itemRendererList[i];

                if (itemRenderer.process.path != process.path)
                {
                    continue;
                }

                switch (process.type)
                {
                    case ProcessTypeEnum.SITE:
                        _itemRendererList.splice(i, 1);
                        if (itemRenderer.parent)
                        {
                            _scrollContentHolder.removeChild(itemRenderer);
                        }
                        reposit();
                        break;
                    case ProcessTypeEnum.APP:
                    case ProcessTypeEnum.BROWSER:
                        itemRenderer.isChecked = false;
                        break;
                }

                break;
            }
        }

    }
}
