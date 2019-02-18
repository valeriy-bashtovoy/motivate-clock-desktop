/**
 * User: Valeriy Bashtovoy
 * Date: 01.09.13
 */
package org.motivateclock.view.components
{

    import flash.text.AntiAliasType;
    import flash.text.Font;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    import org.motivateclock.utils.RegularUtils;

    public class TextArea extends TextField
    {
        public static const LIB_MYRIAD_PRO_SEMIBOLD:String = "MyriadProSemibold";
        public static const LIB_MYRIAD_PRO_REGULAR:String = "MyriadProRegular";

        private var _styleSheet:StyleSheet;
        private var _align:String = TextFormatAlign.LEFT;

        public function TextArea()
        {
            super();

            _styleSheet = new StyleSheet();
            _styleSheet.parseCSS("a {text-decoration: underline; color: #009acc;} a:hover {text-decoration: none; color:#c76900;}");
        }

        public function set align(value:String):void
        {
            _align = value;

            var tf:TextFormat = this.getTextFormat();
            tf.align = _align;

            this.defaultTextFormat = tf;
            this.setTextFormat(tf);
        }

        public function initialize(width:int, height:int, textColor:uint = 0x0, fontSize:Number = 12, libFontName:String = "", backgroundColor:uint = NaN, multiline:Boolean = true, wordWrap:Boolean = true, leading:Number = 0):void
        {
            if (!libFontName)
                libFontName = LIB_MYRIAD_PRO_REGULAR;

            this.selectable = false;
            this.embedFonts = true;
            this.antiAliasType = AntiAliasType.ADVANCED;
            this.mouseWheelEnabled = false;
            this.multiline = multiline;
            this.wordWrap = wordWrap;
            this.sharpness = 20;
            this.mouseWheelEnabled = false;

            if (backgroundColor)
            {
                this.background = true;
                this.backgroundColor = backgroundColor;
            }

            this.width = width;
            this.height = height;

            var font:Font = RegularUtils.getFontInstanceFromLib(libFontName);
            defaultTextFormat = new TextFormat(font.fontName, fontSize, textColor, null, null, null, null, null, _align, null, null, null, leading);
        }

        public function highlightUrl():void
        {
            this.styleSheet = _styleSheet;
        }
    }
}
