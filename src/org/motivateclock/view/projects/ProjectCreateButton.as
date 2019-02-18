package org.motivateclock.view.projects
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
    public class ProjectCreateButton extends MovieClip
    {

        private var _labelHolder:MovieClip;
        private var _line:MovieClip;
        private var _min:MovieClip;
        private var _max:MovieClip;
        private var _label:TextField;
        private var _lineBitmap:Bitmap;
        private var _gfx:MovieClip;

        public function ProjectCreateButton()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECT_CREATE_BUTTON) as MovieClip;
            addChild(_gfx);

            _labelHolder = _gfx["labelHolder"];
            _line = _gfx["line"];
            _min = _gfx["min"];
            _max = _gfx["max"];

            _gfx.stop();

            _label = _labelHolder["label"];
            _label.autoSize = TextFieldAutoSize.LEFT;

            this.buttonMode = true;
            this.mouseChildren = false;

            _line.visible = false;
            _min.visible = false;
            _max.visible = false;
        }

        public function setType(value:String):void
        {
            if (value == "open")
            {
                _max.visible = true;
            }
            else
            {
                _min.visible = true;
            }
        }

        public function setLabel(value:String):void
        {
            _label.text = value;

            if (_lineBitmap)
            {
                _gfx.removeChild(_lineBitmap);
                _lineBitmap = null;
            }

            _lineBitmap = RegularUtils.getRasterize(_line, new Rectangle(0, 0, _label.width - 2, 2));
            _lineBitmap.x = int(_line.x) - 2;
            _lineBitmap.y = int(_line.y);
            _gfx.addChild(_lineBitmap);
        }

        public function over():void
        {
            RegularUtils.setColor(_labelHolder, 0xc76900);
            RegularUtils.setColor(_lineBitmap, 0xc76900);
            _gfx.gotoAndStop(2);
        }

        public function out():void
        {
            RegularUtils.setColor(_labelHolder, 0x547807);
            RegularUtils.setColor(_lineBitmap, 0x547807);
            _gfx.gotoAndStop(1);
        }
    }
}
