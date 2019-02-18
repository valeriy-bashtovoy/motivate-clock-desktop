package org.motivateclock.view.projects.setting
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.motivateclock.interfaces.IIconViewer;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.projects.IconItemRenderer;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessItemRenderer extends MovieClip implements IIconViewer
    {

        private var _nameField:TextField;
        private var _check:MovieClip;
        private var _separator:MovieClip;
        private var _back:MovieClip;
        private var _checkBack:MovieClip;
        private var _deleteButton:SimpleButton;
        private var _iconItemRenderer:IconItemRenderer;
        private var _process:IProcess;
        private var _isSiteMode:Boolean = false;
        private var _gfx:MovieClip;

        public function ProcessItemRenderer(process:IProcess)
        {
            _process = process;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROCESS_ITEM_RENDERER) as MovieClip;
            addChild(_gfx);

            _nameField = _gfx["nameField"];
            _check = _gfx["check"];
            _separator = _gfx["separator"];
            _back = _gfx["back"];
            _checkBack = _gfx["checkBack"];
            _deleteButton = _gfx["deleteButton"];

            _back.alpha = 0;
            _separator.visible = false;
            _check.visible = false;
            _deleteButton.visible = false;

            this.buttonMode = true;
            this.mouseChildren = false;

            _nameField.text = RegularUtils.truncateString(_nameField, _process.name);
            _nameField.mouseEnabled = false;

            _iconItemRenderer = new IconItemRenderer(process);
            _iconItemRenderer.x = 22;
            _iconItemRenderer.y = -7;
            addChild(_iconItemRenderer);

            addEventListener(MouseEvent.CLICK, mouseClickHandler);
            addEventListener(MouseEvent.MOUSE_OVER, overHandler);
            addEventListener(MouseEvent.MOUSE_OUT, outHandler);
            addEventListener(Event.REMOVED_FROM_STAGE, stageRemoveHandler);
        }

        public function enableSiteMode():void
        {
            _isSiteMode = true;

            this.mouseChildren = true;

            _checkBack.visible = false;
            _check.visible = false;
            removeEventListener(MouseEvent.CLICK, mouseClickHandler);

            _iconItemRenderer.x = _checkBack.x;
            _nameField.x = _iconItemRenderer.x + 20;

            _nameField.width = 122;
            _nameField.text = process.name;
            _nameField.textColor = 0x0a5b74;

            RegularUtils.truncate2String(_nameField);

            _deleteButton.addEventListener(MouseEvent.CLICK, deleteClickHandler);
        }

        private function deleteClickHandler(event:MouseEvent):void
        {
            dispatchEvent(new Event(Event.CLOSE));
        }

        private function stageRemoveHandler(event:Event):void
        {
            _iconItemRenderer.dispose();
        }

        public function get process():IProcess
        {
            return _process;
        }

        public function showIcon():void
        {
            _iconItemRenderer.showIcon();
        }

        public function setOffMode():void
        {
            _iconItemRenderer.alpha = 0.5;
            _nameField.alpha = 0.5;
        }

        public function showSeparator():void
        {
            _separator.visible = true;
        }

        public function hideSeparator():void
        {
            _separator.visible = false;
        }

        public function get processData():String
        {
            return _process.path;
        }

        public function get isChecked():Boolean
        {
            return _check.visible;
        }

        public function set isChecked(value:Boolean):void
        {
            _check.visible = value;
        }

        private function outHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
            Tweener.addTween(_back, {alpha: 0, time: 0.5, transition: "easeOutCubic"});

            _deleteButton.visible = false;
        }

        private function overHandler(event:MouseEvent):void
        {
            _deleteButton.visible = _isSiteMode;

            Hint.getInstance().show(this.stage.nativeWindow, _process.name + '\n' + _process.path);

            Tweener.addTween(_back, {alpha: 1, time: 0.5, transition: "easeOutCubic"});
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            _check.visible = !_check.visible;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
}
