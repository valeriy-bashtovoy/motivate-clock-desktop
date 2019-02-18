package org.motivateclock.view.components
{

    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.NativeWindow;
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.Timer;

    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Hint extends Sprite
    {

        private static var instance:Hint;
        private static var isSingleton:Boolean = false;

        private var _back:MovieClip;
        private var _label:TextField;
        private var _showTimer:Timer;
        private var _currentHolder:DisplayObjectContainer;
        private var _windowWidth:int;
        private var _windowHeight:Number;
        private var _window:NativeWindow;
        private var _gfx:MovieClip;

        public static function getInstance():Hint
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new Hint();
                isSingleton = false;
            }

            return instance;
        }

        public function Hint()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + "is singletone, use getInstance();");
            }

            init();
        }

        private function init():void
        {
            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_HINT) as MovieClip;
            addChild(_gfx);

            _back = _gfx["back"];
            _label = _gfx["label"];

            this.visible = false;
            this.cacheAsBitmap = true;

            _label.autoSize = TextFieldAutoSize.LEFT;
            _label.multiline = true;

            _showTimer = new Timer(500, 1);
            _showTimer.addEventListener(TimerEvent.TIMER, timerHandler);
        }

        public function show(window:NativeWindow, text:String):void
        {
            _showTimer.stop();

            _window = window;
            _windowWidth = window.width - 11;
            _windowHeight = window.height;
            _currentHolder = window.stage;

            if (!_currentHolder)
            {
                return;
            }

            _currentHolder.addChild(this);

            var padding:int = 50;

            _label.wordWrap = false;
            _label.text = text;

            if ((_label.width + padding) >= _windowWidth)
            {
                _label.wordWrap = true;
                _label.width = _windowWidth - padding;
            }

            _label.text = text;

            var lineLength:int = 0;
            var lineIndex:int = 0;
            var length:int = _label.numLines;

            for (var i:int = 0; i < length; i++)
            {
                if (_label.getLineLength(i) > lineLength)
                {
                    lineLength = _label.getLineLength(i);
                    lineIndex = i;
                }
            }

            var charIndex:int = _label.getLineOffset(lineIndex) + (lineLength - 1);
            var rect:Rectangle = _label.getCharBoundaries(charIndex);

            if (rect)
            {
                _back.width = rect.x + rect.width + 14;
            }
            else
            {
                _back.width = _label.width + 10;
            }

            _back.height = _label.height + 5;

            _showTimer.start();
        }

        public function hide():void
        {
            _showTimer.stop();
            this.visible = false;
        }

        private function timerHandler(event:TimerEvent):void
        {
            this.stage.nativeWindow.orderToFront();

            this.x = Math.min(int(_currentHolder.mouseX), int(_windowWidth - this.width));
            this.y = int(_currentHolder.mouseY + 22);

            var h:int = this.y + this.height;

            if (h > _windowHeight)
            {
                _window.height = h;
            }

            this.visible = true;
        }
    }
}
