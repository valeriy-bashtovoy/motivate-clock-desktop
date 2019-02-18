package org.motivateclock.view.alert
{

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author Valeriy Bashtovoy
     */
    public class ConfirmButton extends Sprite
    {
        private var _gfx:MovieClip;
        private var _upLayer:MovieClip;
        private var _downLayer:MovieClip;
        private var _overLayer:MovieClip;
        private var _labelHolder:MovieClip;
        private var _shadowHolder:MovieClip;
        private var _labelField:TextField;
        private var _shadowField:TextField;
        private var _enabled:Boolean = true;

        private var _gap:int = 9;

        public function ConfirmButton()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_CONFIRM_BUTTON) as MovieClip;
            addChild(_gfx);

            _upLayer = _gfx["up"] as MovieClip;
            _downLayer = _gfx["down"] as MovieClip;
            _overLayer = _gfx["over"] as MovieClip;

            _labelHolder = _gfx["labelHolder"] as MovieClip;
            _shadowHolder = _gfx["shadowHolder"] as MovieClip;

            _labelField = _labelHolder["field"] as TextField;
            _shadowField = _shadowHolder["field"] as TextField;

            _labelField.autoSize = TextFieldAutoSize.LEFT;
            _shadowField.autoSize = TextFieldAutoSize.LEFT;

            _downLayer.visible = false;
            _overLayer.visible = false;

            this.buttonMode = true;
            this.mouseChildren = false;

            this.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            this.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);
            this.addEventListener(MouseEvent.MOUSE_DOWN, buttonEventHandler);
            this.addEventListener(MouseEvent.MOUSE_UP, buttonEventHandler);
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            _downLayer.visible = false;
            _overLayer.visible = false;
            _upLayer.visible = false;

            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    _overLayer.visible = true;
                    break;
                case MouseEvent.MOUSE_UP:
                case MouseEvent.MOUSE_OUT:
                    _upLayer.visible = true;
                    RegularUtils.setColor(_labelHolder, 0x263032);
                    RegularUtils.setColor(_shadowHolder, 0xffffff);
                    break;
                case MouseEvent.MOUSE_DOWN:
                    _downLayer.visible = true;
                    RegularUtils.setColor(_labelHolder, 0xf0efe8);
                    RegularUtils.setColor(_shadowHolder, 0x4f4f4f);
                    break;
            }
        }

        public function setLabel(label:String):void
        {
            _labelField.text = label;
            _shadowField.text = label;

            setSize(_labelField.width + _gap, 0);
        }

        public function setSize(width:int, height:int):void
        {
            _upLayer.width = width;
            _downLayer.width = width;
            _overLayer.width = width;
        }

        public function set enabled(value:Boolean):void
        {
            _enabled = value;

            this.mouseEnabled = _enabled;
            this.alpha = _enabled ? 1 : 0.6;
        }

        public function get enabled():Boolean
        {
            return _enabled;
        }
    }
}
