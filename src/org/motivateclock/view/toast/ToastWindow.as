package org.motivateclock.view.toast
{

    import flash.desktop.NativeApplication;
    import flash.display.DisplayObjectContainer;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowSystemChrome;
    import flash.display.NativeWindowType;
    import flash.display.Screen;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;

    import org.motivateclock.Model;
    import org.motivateclock.interfaces.IToast;
    import org.motivateclock.model.settings.Settings;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ToastWindow extends NativeWindow
    {
        private static const CONTENT_GAP:int = 10;

        private var _mainWindow:NativeWindow;
        private var _settings:Settings;
        private var _model:Model;
        private var _toast:IToast;

        public function ToastWindow(model:Model)
        {
            _model = model;

            var options:NativeWindowInitOptions = new NativeWindowInitOptions();
            options.type = NativeWindowType.LIGHTWEIGHT;
            options.resizable = false;
            options.systemChrome = NativeWindowSystemChrome.NONE;
            options.transparent = true;

            super(options);

            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;
            super.alwaysInFront = true;

            initialize();
        }

        private function initialize():void
        {
            _settings = _model.settingModel.settings;

            _mainWindow = NativeApplication.nativeApplication.openedWindows[0];

            this.visible = false;
        }

        private function update():void
        {
            this.width = DisplayObjectContainer(_toast).width + CONTENT_GAP;
            this.height = DisplayObjectContainer(_toast).height + CONTENT_GAP;

            var mainScreen:Screen = Screen.mainScreen;
            var screenBounds:Rectangle = mainScreen.visibleBounds;

            this.y = screenBounds.y + screenBounds.height - DisplayObjectContainer(_toast).height - CONTENT_GAP;
            this.x = screenBounds.width - DisplayObjectContainer(_toast).width - CONTENT_GAP;
        }

        public function display(toast:IToast):void
        {
            if (_toast)
            {
                stage.removeChild(_toast as DisplayObjectContainer);
                _toast.dispose();
            }

            _toast = toast;

            this.visible = (_toast != null);

            if (!this.visible)
            {
                return;
            }

            stage.addChild(_toast as DisplayObjectContainer);

            update();
        }

        override public function set alwaysInFront(value:Boolean):void
        {
        }
    }
}
