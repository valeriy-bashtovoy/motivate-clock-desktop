package org.motivateclock.utils
{

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;

    import org.motivateclock.interfaces.IDisposable;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class RegularUtils
    {

        public function RegularUtils()
        {
        }

        static public function drawAndScale9Grid(s:Shape, bitmapData:BitmapData, rect:Rectangle):void
        {
            const gridX:Vector.<Number> = Vector.<Number>([rect.left, rect.right, bitmapData.width]);
            const gridY:Vector.<Number> = Vector.<Number>([rect.top, rect.bottom, bitmapData.height]);

            const g:Graphics = s.graphics;
            g.clear();

            var left:Number = 0;
            var i:int = 0;
            var j:int = 0;

            const n:uint = gridX.length, m:uint = gridY.length;

            while (i < n)
            {
                j = 0; // reset j
                var top:Number = 0;
                while (j < m)
                {
                    // draw shape with special coords of bitmapdata
                    g.beginBitmapFill(bitmapData);
                    g.drawRect(left, top, gridX[i] - left, gridY[j] - top);
                    g.endFill();

                    top = gridY[j];

                    j++;
                }
                left = gridX[i];

                i++;
            }
            s.scale9Grid = rect;
        }

        public static function getFontInstanceFromLib(name:String):Font
        {
            var instance:Class = getDefinitionByName(name) as Class;
            Font.registerFont(instance);
            return new instance();
        }

        public static function getInstanceFromLib(name:String):DisplayObject
        {
            var instance:Class = getDefinitionByName(name) as Class;
            return new instance();
        }

        public static function getPdfFieldWidthByString(text:String, format:TextFormat):Number
        {
            var tf:TextField = new TextField();
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.multiline = false;
            tf.htmlText = text;
            tf.setTextFormat(format);

            return tf.width;
        }

        public static function forceGarbageCollector():void
        {
            var gif:Array = [71, 73, 70, 56, 57, 97, 1, 0, 1, 0, -128, 0, 0, -1, -1, -1, 0, 0, 0, 33, -7, 4, 0, 7, 0, -1, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 68, 1, 0, 59];
            var byteArray:ByteArray = new ByteArray();
            var index:int = 0;

            while (index < gif.length)
            {
                byteArray.writeByte(gif[index]);
                index++;
            }

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complteteHandler);
            loader.loadBytes(byteArray);

            function complteteHandler(event:Event):void
            {
                try
                {
                    loader.unloadAndStop();
                }
                catch (error:Error)
                {
                    trace("forceGarbageCollector: FP10+ is required");
                }
            }
        }

        public static function setColor(target:DisplayObject, color:uint):void
        {
            var ct:ColorTransform = new ColorTransform();
            if (color != 0)
            {
                ct.color = color;
            }
            target.transform.colorTransform = ct;
        }

        public static function callFunctionWithDelay(functionToCall:Function, delay:uint, params:Array = null):Timer
        {
            var timer:Timer = new Timer(delay, 1);
            var timedFunction:Function = function (event:TimerEvent):void
            {
                functionToCall.apply(this, params);
                timer.removeEventListener(TimerEvent.TIMER, timedFunction);
            };
            timer.addEventListener(TimerEvent.TIMER, timedFunction);
            timer.start();

            return timer;
        }

        public static function removeAllChildren(target:DisplayObjectContainer, dispose:Boolean = true):void
        {
            var displayObject:IDisposable;

            while (target.numChildren > 0)
            {
                displayObject = target.getChildAt(0) as IDisposable;

                if (displayObject && dispose)
                {
                    displayObject.dispose();
                }

                target.removeChildAt(0);
            }
        }

        public static function getRasterize(target:DisplayObject, clipRect:Rectangle = null):Bitmap
        {
            var w:Number = target.width;
            var h:Number = target.height;

            if (clipRect)
            {
                w = clipRect.width;
                h = clipRect.height;
            }

            var bd:BitmapData = new BitmapData(w, h, true, 0x0);
            bd.draw(target, null, null, null, clipRect);

            return new Bitmap(bd);
        }

        public static function getProcessNameByPath(processPath:String):String
        {
            //return new File().resolvePath(processPath).name;

            if (!processPath)
            {
                return "";
            }

            var path:Array = processPath.split(/\\/);

            var name:String = path[path.length - 1].split(".")[0];
            name = name.substr(0, 1).toUpperCase() + name.substr(1);

            return name;
        }

        public static function checkProcessPath(processPath:String):Boolean
        {
            var re:RegExp = /\w:\\.*\.[A-Za-z]{3}$/;
            return re.test(processPath);
        }

        public static function truncate2String(textField:TextField, appendText:String = "..."):void
        {
            var i:int = 0;
            var x:int = 0;

            while (i < textField.text.length)
            {
                x = textField.getCharBoundaries(i).right;

                if (x > textField.width)
                {
                    textField.text = textField.text.substr(0, i - appendText.length) + appendText;
                    break;
                }

                i++;
            }
        }

        public static function truncateString(text_field:TextField, text:String):String
        {
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
