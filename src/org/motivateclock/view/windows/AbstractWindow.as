package org.motivateclock.view.windows
{

    import flash.desktop.NativeApplication;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowSystemChrome;
    import flash.display.NativeWindowType;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;
    import org.motivateclock.events.ViewEvent;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class AbstractWindow extends NativeWindow
    {
        private var mainWindow:NativeWindow;

        protected var _model:Model;

        public function AbstractWindow()
        {
            var options:NativeWindowInitOptions = new NativeWindowInitOptions();
            options.type = NativeWindowType.UTILITY;
            options.resizable = false;
            options.systemChrome = NativeWindowSystemChrome.NONE;
            options.transparent = true;

            super(options);

            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.stageFocusRect = false;

            mainWindow = NativeApplication.nativeApplication.openedWindows[0];

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
            stage.addEventListener(ViewEvent.INSTALL_EXTENSION, viewEventHandler, false, 0, true);
        }

        private function viewEventHandler(event:ViewEvent):void
        {
            mainWindow.stage.dispatchEvent(event);
        }

        private function keyboardHandler(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ESCAPE)
            {
                hide();
            }
        }

        public function setSize(newWidth:int, newHeight:int):void
        {
            this.width = newWidth;
            this.height = newHeight;
        }

        public function contact():void
        {
            this.x = Math.ceil(mainWindow.x - this.width + 29);
            this.y = Math.ceil(mainWindow.y + 12);
        }

        public function initialize(model:Model):void
        {
            _model = model;
        }

        public function show():void
        {
            if (this.visible)
            {
                return;
            }

            this.alwaysInFront = mainWindow.alwaysInFront;

            _model.applicationManager.hideAllSubWindows();

            contact();
            activate();

            dispatchEvent(new ViewEvent(ViewEvent.WINDOW_SHOW));
        }

        public function hide():void
        {
            this.visible = false;
            _model.applicationManager.activateMainWindow();
            dispatchEvent(new ViewEvent(ViewEvent.WINDOW_HIDE));
        }
    }
}
