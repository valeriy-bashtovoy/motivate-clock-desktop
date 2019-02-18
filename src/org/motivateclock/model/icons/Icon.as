package org.motivateclock.model.icons
{

    import flash.display.Bitmap;

    /**
     * @author: Valeriy Bashtovoy
     */
    public class Icon extends Object
    {

        private var _iconPath:String;
        private var _iconBitmap:Bitmap;

        public function Icon()
        {
        }

        public function set bitmap(value:Bitmap):void
        {
            _iconBitmap = value;
        }

        public function get bitmap():Bitmap
        {
            return _iconBitmap;
        }

        public function set path(value:String):void
        {
            _iconPath = value;
        }

        public function get path():String
        {
            return _iconPath;
        }
    }
}
