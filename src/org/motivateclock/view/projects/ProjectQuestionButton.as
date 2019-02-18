package org.motivateclock.view.projects
{

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProjectQuestionButton extends Sprite
    {
        private var _label:TextField;
        private var _line:MovieClip;
        private var _lineBitmap:Bitmap;
        private var _gfx:MovieClip;

        public function ProjectQuestionButton()
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROJECT_QUESTION_BUTTON) as MovieClip;
            addChild(_gfx);

            _label = _gfx["label"];
            _line = _gfx["line"];

            _label.autoSize = TextFieldAutoSize.LEFT;

            this.buttonMode = true;
            this.mouseChildren = false;

            _line.visible = false;

            out();

            this.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
            this.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
        }

        public function setLabel(value:String):void
        {
            _label.text = value;

            if (_lineBitmap)
            {
                removeChild(_lineBitmap);
                _lineBitmap = null;
            }

            _lineBitmap = RegularUtils.getRasterize(_line, new Rectangle(0, 0, _label.width - 3, 2));
            _lineBitmap.x = int(_line.x);
            _lineBitmap.y = int(_line.y);
            addChild(_lineBitmap);
        }

        public function over():void
        {
            RegularUtils.setColor(this, 0xc76900);
        }

        public function out():void
        {
            RegularUtils.setColor(this, 0x252628);
        }

        private function overHandler(event:MouseEvent):void
        {
            over();
        }

        private function outHandler(event:MouseEvent):void
        {
            out();
        }
    }
}
