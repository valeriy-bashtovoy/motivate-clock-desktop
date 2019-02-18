/**
 * Created by Valeriy on 05.04.2015.
 */
package org.motivateclock.view
{

    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowSystemChrome;
    import flash.display.NativeWindowType;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    public class NotificationView extends NativeWindow
    {
        public function NotificationView()
        {
            var options:NativeWindowInitOptions = new NativeWindowInitOptions();
            options.type = NativeWindowType.LIGHTWEIGHT;
            options.resizable = false;
            options.systemChrome = NativeWindowSystemChrome.NONE;
            options.transparent = true;

            super(options);

            initialize();
        }

        private function initialize():void
        {
            this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.align = StageAlign.TOP_LEFT;
            this.alwaysInFront = true;

            var s:Sprite = new Sprite();
            s.graphics.beginFill(0xFFFFFF);
            s.graphics.drawRect(100, 100, 400, 400);
            this.stage.addChild(s)
        }
    }
}
