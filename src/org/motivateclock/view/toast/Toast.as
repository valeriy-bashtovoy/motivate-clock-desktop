/**
 * User: Valeriy Bashtovoy
 * Date: 11/24/2015
 */
package org.motivateclock.view.toast
{

    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.geom.Rectangle;

    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IToast;
    import org.motivateclock.resource.ResourceImage;
    import org.motivateclock.utils.DisplayObjectUtils;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.TextArea;

    public class Toast extends Sprite implements IToast
    {
        protected static const CLOSE_BUTTON_H_GAP:int = 6;
        protected static const CLOSE_BUTTON_V_GAP:int = 5;

        protected static const ICON_H_GAP:int = 10;
        protected static const ICON_V_GAP:int = 9;

        protected static const TEXT_FIELD_V_GAP:int = 3;
        protected static const TEXT_FIELD_H_GAP:int = 10;

        protected var _size:Rectangle;
        protected var _background:Shape;
        protected var _closeButton:SimpleButton;
        protected var _icon:DisplayObject;
        protected var _textArea:TextArea;

        public function Toast()
        {
        }

        public function initialize(size:Rectangle, icon:DisplayObject, text:String):void
        {
            _size = size;
            _icon = icon;

            _background = new Shape();
            addChild(_background);

            const backgroundImage:Bitmap = new ResourceImage.TOAST_BACKGROUND();
            const gap:int = 5;
            const rect:Rectangle = backgroundImage.bitmapData.rect;

            rect.x += gap;
            rect.y += gap;
            rect.width -= gap * 2;
            rect.height -= gap * 2;

            RegularUtils.drawAndScale9Grid(_background, backgroundImage.bitmapData, rect);

            _background.width = size.width;

            if (_icon)
            {
                addChild(_icon);
            }

            _textArea = new TextArea();
            _textArea.addEventListener(TextEvent.LINK, textField_linkHandler, false, 0, true);
            addChild(_textArea);

            _closeButton = DisplayObjectUtils.createButton(ResourceImage.TOAST_CLOSE_BUTTON);
            _closeButton.overState.alpha = 0.5;
            _closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler, false, 0, true);
            addChild(_closeButton);

            this.addEventListener(MouseEvent.CLICK, toast_clickHandler, false, 0, true);

            initializeLayout();

            _textArea.htmlText = text;

            _textArea.highlightUrl();
        }

        private function toast_clickHandler(event:MouseEvent):void
        {
            dispatchEvent(new ViewEvent(ViewEvent.TOAST_CLICK));
        }

        protected function initializeLayout():void
        {
            if (_icon)
            {
                _icon.x = ICON_H_GAP;
                _icon.y = ICON_V_GAP;
            }

            _textArea.x = _icon ? _icon.x + _icon.width + TEXT_FIELD_H_GAP : TEXT_FIELD_H_GAP;
            _textArea.y = TEXT_FIELD_V_GAP;

            _closeButton.x = _background.width - _closeButton.width - CLOSE_BUTTON_H_GAP;
            _closeButton.y = _background.y + CLOSE_BUTTON_V_GAP;

            _textArea.initialize(_background.width - _textArea.x, _background.height, 0x3b3b3b, 15, "MyriadProSemibold", NaN, true, true, -1.5);
        }

        public function dispose():void
        {
            if (_icon is Bitmap)
                Bitmap(_icon).bitmapData.dispose();

            _icon = null;
            _textArea = null;
            _closeButton = null;
            _background = null;
        }

        private function closeButton_clickHandler(event:MouseEvent):void
        {
            event.stopImmediatePropagation();
            dispatchEvent(new ViewEvent(ViewEvent.TOAST_CLOSE));
        }

        private function textField_linkHandler(event:TextEvent):void
        {
            dispatchEvent(event);
        }

        override public function get height():Number
        {
            return _background.height;
        }

        override public function get width():Number
        {
            return _background.width;
        }
    }
}
