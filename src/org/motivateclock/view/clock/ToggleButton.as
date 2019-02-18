package org.motivateclock.view.clock
{

    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TextFieldUtil;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ToggleButton extends MovieClip
    {

        private var _labelHolder:MovieClip;
        private var _shadowHolder:MovieClip;
        private var _labelField:TextField;
        private var _shadowField:TextField;
        private var _gfx:MovieClip;

        public function ToggleButton()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_TOGGLE_BUTTON) as MovieClip;
            addChild(_gfx);

            _labelHolder = _gfx["labelHolder"];
            _shadowHolder = _gfx["shadowHolder"];
            _labelField = _labelHolder["field"];
            _shadowField = _shadowHolder["field"];

            this.mouseChildren = false;
            this.buttonMode = true;

            this.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            this.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);

            _gfx.stop();
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    this.over();
                    break;
                case MouseEvent.MOUSE_OUT:
                    this.out();
                    break;
            }
        }

        override public function set enabled(value:Boolean):void
        {
            super.enabled = value;

            if (value)
            {
                this.selected = false;
                _shadowHolder.alpha = 1;
            }
            else
            {
                _gfx.gotoAndStop(4);
                RegularUtils.setColor(_labelHolder, 0xa4a4a4);
                _shadowHolder.alpha = 0;
            }
        }

        public function getTextFieldSize():int
        {
            return int(_labelField.getTextFormat().size);
        }

        public function setTextFieldSize(size:int):void
        {
            var textFormat:TextFormat = new TextFormat("", size);

            _labelField.setTextFormat(textFormat);
            _shadowField.setTextFormat(textFormat);
        }

        public function setLabel(value:String, fontSize:int):void
        {
            _labelField.text = value;
            _shadowField.text = value;

            TextFieldUtil.setDynamicTextFieldSize(_labelField, fontSize);
            TextFieldUtil.setDynamicTextFieldSize(_shadowField, fontSize);

            _shadowHolder.x = _labelHolder.x - 1;
            _shadowHolder.y = _labelHolder.y - 1;
        }

        public function set selected(value:Boolean):void
        {
            if (value)
            {
                _gfx.gotoAndStop(3);
                RegularUtils.setColor(_labelHolder, 0xf0efe8);
                RegularUtils.setColor(_shadowHolder, 0x4f4f4f);
                super.enabled = false;
            }
            else
            {
                _gfx.gotoAndStop(1);
                RegularUtils.setColor(_labelHolder, 0x171717);
                RegularUtils.setColor(_shadowHolder, 0xffffff);
                super.enabled = true;
            }
        }

        public function over():void
        {
            if (!this.enabled)
            {
                return;
            }
            _gfx.gotoAndStop(2);
        }

        public function out():void
        {
            if (!this.enabled)
            {
                return;
            }
            _gfx.gotoAndStop(1);
        }

        override public function get width():Number
        {
            return _labelField.width;
        }
    }
}
