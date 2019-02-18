package org.motivateclock.view.statistic
{

    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.utils.Timer;

    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.interfaces.IIconViewer;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.resource.ResourceImage;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.services.ActiveProcessService;
    import org.motivateclock.utils.DisplayObjectUtils;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.utils.TimeUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.projects.IconItemRenderer;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class StatisticItemRenderer extends Sprite implements IIconViewer, IDisposable
    {
        private static const ICON_TOP_MARGIN:Number = 3.5;

        private static const COLOR_GREEN:uint = 0x8d8e15;
        private static const COLOR_GREY:uint = 0x5c5c5c;

        private static const ICON_DISPLAY_DELAY:uint = 180;

        private var _nameField:TextField;
        private var _timeField:TextField;
        private var _daysBox:MovieClip;
        private var _separator:MovieClip;
        private var _numDays:TextField;
        private var _iconItemRenderer:IconItemRenderer;
        private var _process:IProcess;
        private var _gfx:MovieClip;
        private var _timer:Timer;
        private var _enabled:Boolean;
        private var _swapButton:SimpleButton;

        public function StatisticItemRenderer(process:IProcess)
        {
            _process = process;
            _process.addEventListener(ModelEvent.PROCESS_TIME_CHANGE, process_process_time_changeHandler, false, 0, true);

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_STATISTIC_ITEM_RENDERER) as MovieClip;
            addChild(_gfx);

            _nameField = _gfx["nameField"];
            _timeField = _gfx["timeField"];
            _daysBox = _gfx["daysBox"];
            _separator = _gfx["separator"];

            _gfx.removeChild(_gfx["changeButton"]);

            _separator.visible = false;

            _iconItemRenderer = new IconItemRenderer(_process);
            _iconItemRenderer.y = ICON_TOP_MARGIN;
            // temporary disabled, because lack of time;
//            _iconItemRenderer.addEventListener(MouseEvent.MOUSE_OVER, iconOverHandler, false, 0, true);
            addChild(_iconItemRenderer);

            _numDays = _daysBox.getChildByName('numDays') as TextField;

            updateTime();

            if (!_daysBox.visible)
            {
                _nameField.width = 95;
            }

            _nameField.selectable = false;

            var styleSheet:StyleSheet;

            var label:String = RegularUtils.truncateString(_nameField,
                    _process.name != 'null' ? _process.name : _process.path);

            if (_process.type == ProcessTypeEnum.SITE)
            {
                styleSheet = new StyleSheet();
                styleSheet.parseCSS("a {text-decoration: none; color: #1489ac;} a:hover {text-decoration: underline; color:#c76900;}");

                if (_process.path != ActiveProcessService.BLANK_TAB && _process.path.search(/:{1}\/{2}/i) == -1)
                {
                    _nameField.styleSheet = styleSheet;
                    _nameField.htmlText = "<a href='event:'>" + label + "</a>";
                }
                else
                {
                    _nameField.htmlText = label;
                }

                _nameField.textColor = 0x0a5b74;
            }
            else
            {
                _nameField.htmlText = label;
            }

            addEventListener(MouseEvent.MOUSE_OVER, overHandler, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, outHandler, false, 0, true);

            _nameField.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);

            _timer = RegularUtils.callFunctionWithDelay(showIcon, ICON_DISPLAY_DELAY);

            if (process.isMarked)
                setColor(COLOR_GREEN);

            createSwapButton();
        }

        private function createSwapButton():void
        {
            _swapButton = DisplayObjectUtils.createButton(
                    _process.isMarked ? ResourceImage.SWAP_BUTTON_REMOVE : ResourceImage.SWAP_BUTTON_ADD);
            _swapButton.name = _process.isMarked ? ViewEvent.PROCESS_REMOVE : ViewEvent.PROCESS_ADD;
            _swapButton.y = ICON_TOP_MARGIN;
            _swapButton.visible = false;
            _swapButton.addEventListener(MouseEvent.MOUSE_OUT, swapButtonHandler, false, 0, true);
            _swapButton.addEventListener(MouseEvent.CLICK, swapButtonHandler, false, 0, true);
            addChild(_swapButton);
        }

        private function swapButtonHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OUT:
                    _swapButton.visible = false;
                    break;
                case MouseEvent.CLICK:
                    var e:ViewEvent = new ViewEvent(_swapButton.name);
                    e.process = _process;
                    dispatchEvent(e);
                    break;
            }
        }

        private function linkHandler(event:TextEvent):void
        {
            // TODO check what is going on.
            var scheme:String = (_process.path.search(/:\/+/i) == -1) ? "http://" : "file:///";
            navigateToURL(new URLRequest(scheme + _process.path));
        }

        public function get time():int
        {
            return _process.time;
        }

        public function updateTime():void
        {
            setTime(_process.time);
        }

        public function get process():IProcess
        {
            return _process;
        }

        private function setTime(seconds:Number):void
        {
            var t:Object = TimeUtils.convertSeconds(seconds, 24);
            _timeField.text = t.hour + ":" + t.min + ":" + t.sec;
            _daysBox.visible = Boolean(t.day);
            _numDays.text = t.day;
        }

        private function iconOverHandler(event:MouseEvent):void
        {
            _swapButton.visible = true;
        }

        public function showIcon():void
        {
            _iconItemRenderer.showIcon();
        }

        private function setColor(value:uint):void
        {
            _timeField.textColor = value;
        }

        private function outHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
        }

        private function overHandler(event:MouseEvent):void
        {
            if (_process.type == ProcessTypeEnum.SITE)
            {
                if (_process.name.length > _nameField.text.length)
                    Hint.getInstance().show(this.stage.nativeWindow, _process.name);
            }
            else
            {
                Hint.getInstance().show(this.stage.nativeWindow, _process.name + '\n' + _process.path);
            }
        }

        public function dispose():void
        {
            _process.removeEventListener(ModelEvent.PROCESS_TIME_CHANGE, process_process_time_changeHandler);
            _iconItemRenderer.dispose();
            _timer.stop();
            _timer = null;
        }

        public function set enabled(value:Boolean):void
        {
            _enabled = value;

            if (!_enabled)
                setColor(COLOR_GREY);
        }

        private function process_process_time_changeHandler(event:ModelEvent):void
        {
            updateTime();
        }
    }
}
