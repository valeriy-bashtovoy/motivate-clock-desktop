package org.motivateclock.view.projects
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.ProjectsModel;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectItemRenderer extends MovieClip implements IDisposable
    {
        private var _background:MovieClip;
        private var _optionsMenu:MovieClip;
        private var _separator:MovieClip;
        private var _area:MovieClip;
        private var _lock:MovieClip;
        private var _indicator:MovieClip;

        private var _project:Project;
        private var _labelEditorView:LabelEditorView;
        private var _selected:Boolean = false;

        private var _highlight:Boolean = false;
        private var _settingButton:SimpleButton;
        private var _editButton:SimpleButton;
        private var _removeButton:SimpleButton;
        private var _gfx:MovieClip;
        private var _model:Model;

        public function ProjectItemRenderer(project:Project, model:Model)
        {
            _project = project;
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECT_ITEM_RENDERER) as MovieClip;
            addChild(_gfx);

            _background = _gfx["background"];
            _optionsMenu = _gfx["optionsMenu"];
            _separator = _gfx["separator"];
            _area = _gfx["area"];
            _lock = _gfx["lock"];
            _indicator = _gfx["indicator"];

            initialize();
        }

        private function initialize():void
        {
            _settingButton = _optionsMenu["settingButton"] as SimpleButton;
            _editButton = _optionsMenu["editButton"] as SimpleButton;
            _removeButton = _optionsMenu["removeButton"] as SimpleButton;

            _background.alpha = 0;
            _optionsMenu.alpha = 0;

            _area.buttonMode = true;
            _lock.visible = false;
            _indicator.visible = false;

            _labelEditorView = new LabelEditorView(_project, _model);
            _labelEditorView.addEventListener(Event.COMPLETE, editCompleteHandler, false, 0, true);
            _gfx.addChildAt(_labelEditorView, 1);

            if (_project.id == ProjectsModel.MANUAL_MODE)
            {
                _lock.visible = true;
                _optionsMenu.visible = false;
                _labelEditorView.setTextColor(0x0a485c);
            }

            _area.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
            _area.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);

            _optionsMenu.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
            _optionsMenu.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);

            this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
        }

        private function editCompleteHandler(event:Event):void
        {
            _area.visible = true;
            _optionsMenu.visible = true;
        }

        private function clickHandler(event:MouseEvent):void
        {
            var viewEvent:ViewEvent;

            switch (event.target)
            {
                case _area:
                    viewEvent = new ViewEvent(ViewEvent.SELECT_PROJECT);
                    break;
                case _settingButton:
                    viewEvent = new ViewEvent(ViewEvent.OPEN_PROJECT_SETTING);
                    break;
                case _editButton:
                    viewEvent = new ViewEvent(ViewEvent.EDIT_PROJECT_NAME);
                    break;
                case _removeButton:
                    viewEvent = new ViewEvent(ViewEvent.REMOVE_PROJECT);
                    break;
            }

            if (!viewEvent)
            {
                return;
            }

            viewEvent.projectId = _project.id;

            dispatchEvent(viewEvent);
        }

        override public function get height():Number
        {
            return Math.ceil(_background.height);
        }

        public function get project():Project
        {
            return _project;
        }

        public function set selected(value:Boolean):void
        {
            _selected = value;

            if (!_selected)
            {
                out();
            }
            else
            {
                over();
            }
        }

        public function highlight(value:Boolean):void
        {
            _highlight = value;

            if (value)
            {
                _background.alpha = 1;
                over();
            }
            else
            {
                _labelEditorView.hideEditor();
                out();
            }
        }

        public function editName(select:Boolean):void
        {
            _area.visible = false;
            _optionsMenu.visible = false;
            _labelEditorView.editName(select);
        }

        public function showIndicator():void
        {
            _indicator.visible = true;
        }

        public function hideIndicator():void
        {
            _indicator.visible = false;
        }

        private function over():void
        {
            Tweener.addTween(_optionsMenu, {alpha: 1, time: .3});
            Tweener.addTween(_background, {alpha: 1, time: 1});
        }

        private function out():void
        {
            if (_highlight)
            {
                return;
            }

            Tweener.addTween(_optionsMenu, {alpha: 0, time: .1});
            Tweener.addTween(_background, {alpha: 0, time: .5});
        }

        private function mouseOverHandler(event:MouseEvent):void
        {
            over();

            switch (event.target)
            {
                case _area:
                    if (_labelEditorView.isRequiredHint)
                    {
                        Hint.getInstance().show(this.stage.nativeWindow, _project.name);
                    }
                    break;
                case _editButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROJECT_EDIT_NAME));
                    break;
                case _removeButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROJECT_DELETE));
                    break;
                case _settingButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROJECT_OPTIONS));
                    break;
            }
        }


        private function mouseOutHandler(event:MouseEvent = null):void
        {
            Hint.getInstance().hide();
            out();
        }

        public function dispose():void
        {
            _labelEditorView.dispose();
        }
    }
}
