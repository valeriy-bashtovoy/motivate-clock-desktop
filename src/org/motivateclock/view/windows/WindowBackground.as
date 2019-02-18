package org.motivateclock.view.windows
{

    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class WindowBackground extends MovieClip
    {
        private var _closeButton:SimpleButton;
        private var _titleFiled:TextField;
        private var _substrate:MovieClip;
        private var _background:MovieClip;
        private var _separator:MovieClip;
        private var _contentHolder:MovieClip;
        private var _gfx:MovieClip;
        private var _model:Model;

        public function WindowBackground(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_WINDOW_BACKGROUND) as MovieClip;
            addChild(_gfx);

            _closeButton = _gfx["closeButton"];
            _titleFiled = _gfx["titleFiled"];
            _substrate = _gfx["substrate"];
            _background = _gfx["background"];
            _separator = _gfx["separator"];
            _contentHolder = _gfx["contentHolder"];

            _background.mouseEnabled = false;
            _background.mouseChildren = false;

            _model.skinManager.registerDisplayObject(_background);

            addEventListener(MouseEvent.CLICK, mouseClickHandler);

            _closeButton.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            _closeButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }

        public function addContent(content:DisplayObject):void
        {
            _contentHolder.addChild(content);
        }

        public function showSeparator(value:Boolean):void
        {
            _separator.visible = value;
        }

        public function set title(value:String):void
        {
            _titleFiled.htmlText = value;
        }

        public function setHeight(h:int):void
        {
            _substrate.height = h - 55;
            _background.height = h;
        }

        private function mouseOutHandler(event:MouseEvent):void
        {
            Hint.getInstance().hide();
        }

        private function mouseOverHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _closeButton:
                    Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.CLOSE));
                    break;
            }
        }

        private function mouseClickHandler(event:MouseEvent):void
        {
            switch (event.target)
            {
                case _closeButton:
                    dispatchEvent(new Event(Event.CLOSE));
                    break;
            }
        }
    }
}
