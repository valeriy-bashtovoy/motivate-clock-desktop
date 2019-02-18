package org.motivateclock.view.projects
{

    import caurina.transitions.Tweener;

    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.filesystem.File;
    import flash.net.URLRequest;

    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.icons.Icon;
    import org.motivateclock.model.icons.IconManager;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class IconItemRenderer extends MovieClip
    {
        private var _removeButton:MovieClip;
        private var _noIcon:MovieClip;
        private var _iconBitmap:Bitmap;
        private var _icon:Icon;
        private var _loader:Loader;
        private var _process:IProcess;
        private var _gfx:MovieClip;

        public function IconItemRenderer(process:IProcess)
        {
            _process = process;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_ICON_ITEM_RENDERER) as MovieClip;
            addChild(_gfx);

            _removeButton = _gfx["removeButton"];
            _noIcon = _gfx["noIcon"];

            if (process.type == ProcessTypeEnum.SITE)
            {
                _noIcon.gotoAndStop(2);
            }

            _removeButton.visible = false;
        }

        public function dispose():void
        {
            if (_iconBitmap && _iconBitmap.bitmapData)
            {
                _iconBitmap.bitmapData.dispose();
            }

            if (_loader)
            {
                _loader.unloadAndStop();
                _loader = null;
            }

            _icon = null;
            _process = null;
        }

        public function enableEditMode():void
        {
            this.buttonMode = true;
            this.mouseChildren = false;

            _removeButton.visible = true;
            _removeButton.alpha = 0;

            var b:Bitmap = RegularUtils.getRasterize(_noIcon);
            b.smoothing = true;

            _noIcon.removeChildAt(0);
            _noIcon.addChild(b);

            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        }

        public function get process():IProcess
        {
            return _process;
        }

        public function get processData():String
        {
            return _process.path;
        }

        public function showIcon():void
        {
            if (_icon)
            {
                return;
            }

            _icon = IconManager.getInstance().getIcon(_process);

            if (!_icon)
            {
                return;
            }

            if (_icon.bitmap)
            {
                _iconBitmap = _icon.bitmap;
                addIcon();
                return;
            }

            switch (process.type)
            {
                case ProcessTypeEnum.BROWSER:
                case ProcessTypeEnum.APP:
                    _icon.path = File.applicationStorageDirectory.resolvePath("ico/" + _icon.path).nativePath;
                    break;
                case ProcessTypeEnum.SITE:
                    break;
            }

            loadIcon();
        }

        private function loadIcon():void
        {
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.load(new URLRequest(_icon.path));
        }

        private function addIcon():void
        {
            if (!_iconBitmap)
            {
                return;
            }

            if (_iconBitmap.height > 16)
            {
                _iconBitmap.smoothing = true;
                _iconBitmap.width = 16;
                _iconBitmap.height = 16;
            }

            _noIcon.visible = false;
            _iconBitmap.x = _noIcon.x;
            _iconBitmap.y = _noIcon.y;
            addChildAt(_iconBitmap, 0);
        }

        private function ioErrorHandler(event:IOErrorEvent):void
        {
            addIcon();
        }

        private function completeHandler(event:Event):void
        {
            if (_loader && _loader.content)
            {
                _iconBitmap = _loader.content as Bitmap;
            }

            if (_iconBitmap && _iconBitmap.width < 16)
            {
                _iconBitmap = null;
            }

            addIcon();
        }

        private function mouseOverHandler(event:MouseEvent):void
        {
            Tweener.addTween(_removeButton, {alpha: 1, time: 0.5});
            Hint.getInstance().show(this.stage.nativeWindow, _process.name);
        }

        private function mouseOutHandler(event:MouseEvent):void
        {
            Tweener.addTween(_removeButton, {alpha: 0, time: 0.5});
            Hint.getInstance().hide();
        }
    }
}
