package org.motivateclock.utils
{

    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;

    /**
     * @author Valeriy Bashtovoy
     */
    public class TextFieldUtil
    {
        public static const DESCENDING:uint = 2;
        public static const ASCENDING:uint = 3;

        /**
         * type - default type is ASCENDING, or u can use DESCENDING;
         */
        public static function setTextFieldUnifiedSize(textFieldList:Array, type:uint = 3):void
        {
            if (textFieldList.length == 0)
            {
                return;
            }

            var newSize:int = int(textFieldList[0].getTextFormat().size);
            var textFieldSize:int;
            var textField:TextField;

            for each(textField in textFieldList)
            {
                textFieldSize = int(textField.getTextFormat().size);

                if (type == ASCENDING)
                {
                    if (textFieldSize > newSize)
                    {
                        newSize = textFieldSize;
                        continue;
                    }
                }

                if (type == DESCENDING)
                {
                    if (textFieldSize < newSize)
                    {
                        newSize = textFieldSize;

                    }
                }
            }

            var textFormat:TextFormat;

            for each(textField in textFieldList)
            {
                textFormat = textField.getTextFormat();
                textFormat.size = newSize;
                textField.setTextFormat(textFormat);
            }
        }

        public static function getDynamicTextFieldSize(textField:TextField, maxSize:int):int
        {
            var tempTextField:TextField = new TextField();
            tempTextField.text = textField.text;
            tempTextField.setTextFormat(textField.getTextFormat());

            setDynamicTextFieldSize(tempTextField, maxSize);

            return int(tempTextField.getTextFormat().size);
        }

        public static function setDynamicTextFieldSize(textField:TextField, maxSize:int):void
        {
            textField.autoSize = TextFieldAutoSize.NONE;

            var textFormat:TextFormat = textField.getTextFormat();
            var gap:int = 5;
            var isDecreased:Boolean = false;

//			trace("textFormat.size, before:", textFormat.size, textField.textWidth + gap, textField.width, (textField.textWidth + gap) > textField.width);

            // decrease text size, when it more than text field width;
            while ((textField.textWidth + gap) > textField.width)
            {
                isDecreased = true;
                textFormat.size = int(textFormat.size) - 1;
                textField.setTextFormat(textFormat);
            }

            // increase text size, when it less than text field width;
            while (!isDecreased && textField.textWidth < textField.width && textFormat.size < maxSize)
            {
                textFormat.size = int(textFormat.size) + 1;
                textField.setTextFormat(textFormat);
            }

//			trace("textFormat.size, after increase:", textFormat.size);
        }

        public static function truncateString(text_field:TextField, text:String):String
        {
            if (!text)
            {
                return text;
            }

            text_field.htmlText = text;

            if (text_field.maxScrollH == 0)
            {
                return text;
            }

            var i:int = 0;
            var w:int = 0;
            var r:Rectangle;

            while (i < text_field.text.length)
            {
                r = text_field.getCharBoundaries(i);

                if (r)
                {
                    w += text_field.getCharBoundaries(i).width;
                }

                if (w > text_field.width)
                {
                    break;
                }

                i++;
            }

            return text_field.text.substr(0, i - 6) + "...";
        }

        public static function truncateStringByLength(text:String, length:int):String
        {
            if (text.length > length)
            {
                text = text.slice(0, length - 3) + "...";
            }

            return text;
        }
    }
}
