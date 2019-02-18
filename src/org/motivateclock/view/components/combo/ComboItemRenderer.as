package org.motivateclock.view.components.combo
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ComboItemRenderer extends MovieClip
    {

        private var _labelFiled:TextField;
        private var _background:MovieClip;
        private var _currentColor:uint = 0x5E6064;
        private var _itemData:String;
        private var _gfx:MovieClip;

        public function ComboItemRenderer(label:String, width:int)
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_COMBO_ITEM_RENDERER) as MovieClip;
            addChild(_gfx);

            _labelFiled = _gfx["labelFiled"];
            _background = _gfx["background"];

            this.buttonMode = true;
            this.mouseChildren = false;

            _labelFiled.width = width - 5;
            this.label = label;

            _background.alpha = 0;
            _background.width = width;
            _background.height = int(_labelFiled.height) - 1;

            addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }

        public function highlight():void
        {
        }

        public function set data(value:String):void
        {
            _itemData = value;
        }

        public function get data():String
        {
            return _itemData;
        }

        public function setColor(color:uint, bold:Boolean):void
        {
            if (bold)
            {
                _labelFiled.htmlText = "<b>" + _labelFiled.text + "</b>";
            }
            _labelFiled.textColor = color;
            _currentColor = color;
        }

        public function get label():String
        {
            return _labelFiled.text;
        }

        public function set label(value:String):void
        {
            _labelFiled.htmlText = RegularUtils.truncateString(_labelFiled, value);
        }

        private function mouseOutHandler(event:MouseEvent):void
        {
            _labelFiled.textColor = _currentColor;
            Tweener.addTween(_background, {alpha: 0, time: .5});
        }

        private function mouseOverHandler(event:MouseEvent):void
        {
            _labelFiled.textColor = 0xffffff;
            Tweener.addTween(_background, {alpha: 1, time: .5});
        }
    }
}
