package org.motivateclock.view.alert
{

    import caurina.transitions.Tweener;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ConfirmAlert extends MovieClip
    {
        public static const RESET:String = 'reset';
        public static const DELETE:String = 'delete';
        public static const EXPORT:String = 'export';

        public static var instance:ConfirmAlert;
        private static var isSingleton:Boolean = false;

        private var _backing:MovieClip;
        private var _statusField:TextField;
        private var _lockLayer:MovieClip;
        private var _currentType:String;
        private var _projectId:String;

        private var _yesButton:ConfirmButton;
        private var _cancelButton:ConfirmButton;
        private var _buttonList:Array = [];
        private var _gfx:MovieClip;
        private var _model:Model;

        public static function getInstance():ConfirmAlert
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new ConfirmAlert();
                isSingleton = false;
            }

            return instance;
        }

        public function ConfirmAlert()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + "is singletone, use getInstance();");
            }

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_CONFIRM_ALERT) as MovieClip;
            addChild(_gfx);

            _backing = _gfx["backing"];
            _statusField = _gfx["statusField"];
            _lockLayer = _gfx["lockLayer"];

            this.visible = false;
            _backing.mouseChildren = false;
            _statusField.autoSize = TextFieldAutoSize.CENTER;

            _lockLayer.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

            _yesButton = new ConfirmButton();
            _yesButton.addEventListener(MouseEvent.CLICK, mouseClickHandler);
            addChild(_yesButton);
            _buttonList.push(_yesButton);

            _cancelButton = new ConfirmButton();
            _cancelButton.addEventListener(MouseEvent.CLICK, mouseClickHandler);
            addChild(_cancelButton);
            _buttonList.push(_cancelButton);
        }

        public function set model(value:Model):void
        {
            _model = value;

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _yesButton.setLabel(_model.languageModel.getText(TextKeyEnum.YES));
            _cancelButton.setLabel(_model.languageModel.getText(TextKeyEnum.CANCEL));

            repositButton();
        }

        private function confirm():void
        {
            hide();

            var e:McEvent = new McEvent(McEvent.CONFIRMED);
            e.messageType = _currentType;
            e.projectId = _projectId;
            dispatchEvent(e);
        }

        private function cancel():void
        {
            hide();

            var e:McEvent = new McEvent(McEvent.CANCEL);
            e.messageType = _currentType;
            e.projectId = _projectId;
            dispatchEvent(e);
        }

        public function show(type:String, projectId:String = ""):void
        {
            _projectId = projectId;
            _currentType = type;

            languageChangeHandler();

            _yesButton.visible = true;
            _cancelButton.visible = true;

            switch (type)
            {
                case ConfirmAlert.RESET:
                    this.y = 206;
                    _statusField.text = _model.languageModel.getText(TextKeyEnum.CONFIRM_CLEAR);
                    _backing.width = _statusField.width;
                    break;
                case ConfirmAlert.DELETE:
                    this.y = 212;
                    _statusField.text = _model.languageModel.getText(TextKeyEnum.CONFIRM_DELETE);
                    _backing.width = _statusField.width;
                    break;
                case ConfirmAlert.EXPORT:
                    this.y = 206;
                    _backing.width = _statusField.width + 25;
                    _statusField.text = _model.languageModel.getText(TextKeyEnum.CONFIRM_EXPORT);
                    _yesButton.visible = false;
                    //_cancelButton.visible = _statusField.y = (_backing.height - _statusField.height) / 2;
                    break;
            }

            _backing.width += 120;

            this.x = 130;
            this.visible = true;
            this.alpha = 0;

            repositButton();

            Tweener.addTween(this, {alpha: 1, time: 0.5, transition: "easeOutCubic"});
        }

        public function hide():void
        {
            Tweener.addTween(this, {alpha: 0, time: 0.25, onComplete: completeHandler});

            function completeHandler():void
            {
                DisplayObject(this).visible = false;
            }
        }

        private function repositButton():void
        {
            var gap:int = 0;
            var sumWidth:int = 0;
            var button:DisplayObjectContainer;

            for each (button in _buttonList)
            {
                if (button.visible)
                {
                    sumWidth += button.width + gap;
                }
            }

            var nextX:int = -sumWidth / 2;

            for each (button in _buttonList)
            {
                if (button.visible)
                {
                    button.x = nextX;
                    nextX += button.width + gap;
                }
            }
        }

        private function mouseDownHandler(event:MouseEvent):void
        {
            this.stage.nativeWindow.startMove();
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _yesButton:
                    confirm();
                    break;
                case _cancelButton:
                    cancel();
                    break;
            }
        }
    }
}
