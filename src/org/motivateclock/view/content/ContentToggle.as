package org.motivateclock.view.content
{

    import caurina.transitions.Tweener;

    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;

    import org.motivateclock.Model;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.interfaces.IContent;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;
    import org.motivateclock.view.components.Scroll;

    /**
     * @author: Valeriy Bashtovoy
     *
     *
     */
    public class ContentToggle extends Sprite
    {

        public static const LEFT:String = "left";
        public static const RIGTH:String = "right";

        private var _menu:MovieClip;
        private var _leftButton:MovieClip;
        private var _rightButton:MovieClip;
        private var _buttonDictionary:Dictionary;
        private var _buttonArray:Array;
        private var _currentButton:MovieClip;
        private var _content:IContent;
        private var _contentHolder:Sprite;
        private var _scroll:Scroll;
        private var _contentArguments:Array = [];
        private var _isScrollable:Boolean = true;

        private var _scrollStep:int = 16;
        private var _contentOffset:int = 5;
        private var _model:Model;

        public function ContentToggle(model:Model, isScrollable:Boolean = true)
        {
            _model = model;
            _isScrollable = isScrollable;

            this.visible = false;

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            _buttonDictionary = new Dictionary();

            _buttonArray = [];

            _menu = RegularUtils.getInstanceFromLib("ui.contenttoggle") as MovieClip;
            addChild(_menu);

            _contentHolder = new Sprite();

            var scrollWidth:int = _isScrollable ? 187 : 200;

            _scroll = new Scroll(scrollWidth, 100, _scrollStep, 0);
            _scroll.y = int(_menu.y + _menu.height + _contentOffset);
            _scroll.setContent(_contentHolder);
            addChild(_scroll);

            _leftButton = _menu.getChildByName("leftButton") as MovieClip;
            _rightButton = _menu.getChildByName("rightButton") as MovieClip;

            initButton(_leftButton);
            initButton(_rightButton);

            _model.skinManager.registerDisplayObject(_scroll.trackButton);

            addEventListener(MouseEvent.CLICK, clickHandler);
        }

        public function setHeight(height:int):void
        {
            _scroll.setSize(height);
            _scroll.update();
        }

        public function setContentArguments(...arg):void
        {
            _contentArguments = arg;
        }

        public function showContent(type:String):void
        {
            switch (type)
            {
                case ContentToggle.LEFT:
                    _currentButton = _rightButton;
                    select(_leftButton);
                    break;
                case ContentToggle.RIGTH:
                    _currentButton = _leftButton;
                    select(_rightButton);
                    break;
            }
        }

        public function addContent(type:String, content:ContentVO):void
        {
            var button:MovieClip;

            switch (type)
            {
                case ContentToggle.LEFT:
                    button = _leftButton;
                    break;
                case ContentToggle.RIGTH:
                    button = _rightButton;
                    break;
            }

            _buttonDictionary[button] = content;

            button.visible = true;

            var iconHolder:MovieClip = button["iconHolder"] as MovieClip;

            var icon:MovieClip = RegularUtils.getInstanceFromLib(content.icon) as MovieClip;
            iconHolder.addChild(icon);

            if (type == ContentToggle.LEFT)
            {
                button["label"].x = iconHolder.x + iconHolder.width;
            }

            languageChangeHandler();
        }

        private function initButton(target:MovieClip):void
        {
            target.visible = false;
            target.buttonMode = true;
            target.mouseChildren = false;

            target.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            target.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);

            _buttonArray.push(target);
        }

        private function select(target:MovieClip):void
        {
            if (_currentButton)
            {
                _currentButton.enabled = true;
                _currentButton["back"].visible = true;
                _currentButton["label"].visible = false;
            }

            _currentButton = target;
            setAlpha(_currentButton, 0);
            _currentButton.enabled = false;
            _currentButton["back"].visible = false;
            _currentButton["label"].visible = true;

            if (_currentButton == _rightButton)
            {
                _rightButton["iconHolder"].x = -84;
                _rightButton["label"].x = _rightButton["iconHolder"].x + _rightButton["iconHolder"].width;
            }
            else
            {
                _rightButton["iconHolder"].x = 18;
            }

            createContent(ContentVO(_buttonDictionary[target]).content);
        }

        private function createContent(content:Class):void
        {
            if (!content)
            {
                trace("createContent: contentVO hasn't content class!");
                return;
            }

            dispose();

            if (_contentArguments.length > 0)
            {
                _content = new content(_contentArguments[0]) as IContent;
            }
            else
            {
                _content = new content() as IContent;
            }

            if (!_content)
            {
                trace("createContent: content not implement IContent!");
                return;
            }

            _contentHolder.addChild(_content as DisplayObject);

            if (_isScrollable)
            {
                _scroll.reset();
                _scroll.update();
            }

            this.visible = true;
        }

        public function dispose():void
        {
            if (!_content)
            {
                return;
            }

            RegularUtils.removeAllChildren(_contentHolder);

            _content.dispose();
            _content = null;

            this.visible = false;
        }

        private function setAlpha(target:Object, alpha:Number, time:Number = 0.5):void
        {
            if (!target.enabled)
            {
                return;
            }

            var over:MovieClip = target["over"];

            if (over)
            {
                Tweener.addTween(over, {alpha: alpha, time: time, transition: "easeOutCubic"});
            }
        }

        private function showHint(target:Object):void
        {
            if (!target.enabled)
            {
                return;
            }

            var content:ContentVO = _buttonDictionary[target];

            if (content)
            {
                Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(content.hint));
            }

        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var length:int = _buttonArray.length;
            var button:MovieClip;
            var content:ContentVO;

            for (var i:int = 0; i < length; i++)
            {
                button = _buttonArray[i];
                content = _buttonDictionary[button];

                if (content)
                {
                    button["label"].text = _model.languageModel.getText(content.label);
                }
            }

            RegularUtils.callFunctionWithDelay(_scroll.update, 25);
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            switch (event.type)
            {
                case MouseEvent.MOUSE_OVER:
                    showHint(event.target);
                    setAlpha(event.target, 0.2);
                    break;
                case MouseEvent.MOUSE_OUT:
                    Hint.getInstance().hide();
                    setAlpha(event.target, 0);
                    break;
            }
        }

        private function clickHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();

            switch (event.target)
            {
                case _leftButton:
                    select(_leftButton);
                    break;
                case _rightButton:
                    select(_rightButton);
                    break;
            }
        }
    }
}
