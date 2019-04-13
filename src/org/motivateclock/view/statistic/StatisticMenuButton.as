package org.motivateclock.view.statistic
{

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticMenuButton extends MovieClip
    {

        private var _line:MovieClip;
        private var _label:TextField;
        private var _lineBitmap:Bitmap;
        private var _gfx:MovieClip;

        public function StatisticMenuButton()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_STATISTIC_MENU_BUTTON) as MovieClip;
            addChild(_gfx);

            _line = _gfx["line"];
            _label = _gfx["label"];

            this.buttonMode = true;
            this.mouseChildren = false;

            _label.autoSize = TextFieldAutoSize.LEFT;
            _line.visible = false;
        }

        override public function get width():Number
        {
            return _label.width;//super.width;
        }

        public function set activated(value:Boolean):void
        {
            this.mouseEnabled = value;

            if(value)
            {
                this.enabled ? this.out() : this.over();
            }
            else
            {
                RegularUtils.setColor(this, 0xc0c0c0);
            }
        }

        public function get selected():Boolean
        {
            return !this.enabled;
        }

        public function set selected(value:Boolean):void
        {
            this.enabled = !value;
            if (value)
            {
                over();
            }
            else
            {
                out();
            }
        }

        public function setLabel(value:String):void
        {
            _label.text = value;

            if (_lineBitmap)
            {
                removeChild(_lineBitmap);
            }

            _lineBitmap = RegularUtils.getRasterize(_line, new Rectangle(0, 0, _label.width - 2, 2));
            _lineBitmap.x = int(_line.x);
            _lineBitmap.y = int(_line.y);
            addChild(_lineBitmap);
        }

        public function over():void
        {
            RegularUtils.setColor(this, 0x910303);
        }

        public function out():void
        {
            if (!this.enabled)
            {
                return;
            }
            RegularUtils.setColor(this, 0x267E99);
        }
    }
}
