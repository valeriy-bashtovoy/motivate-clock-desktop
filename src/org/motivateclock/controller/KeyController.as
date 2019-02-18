/**
 * Created by Valeriy on 08.07.2015.
 */
package org.motivateclock.controller
{

    import flash.desktop.NativeApplication;
    import flash.display.NativeWindow;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import org.motivateclock.Model;

    public class KeyController
    {
        private var _model:Model;
        private var _toneDirection:int = -1;

        public function KeyController(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            const windowList:Array = NativeApplication.nativeApplication.openedWindows;

            var window:NativeWindow;

            for (var i:int = 0; i < windowList.length; i++)
            {
                window = windowList[i];
                window.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            }
        }

        private function keyDownHandler(event:KeyboardEvent):void
        {
            //trace(event.keyCode, Keyboard.C);

            if (event.keyCode == Keyboard.C && event.altKey)
            {
                colorize();
            }
        }

        //TODO should be moved to command;
        private function colorize():void
        {
            var colorTone:int = _model.colorTone;
            var step:int = 30;

            if (colorTone == 180 || colorTone == -180)
            {
                colorTone = 0;
                _toneDirection *= -1;
            }
            else
            {
                colorTone += step * _toneDirection;
            }

            //trace("colorTone", colorTone);

            _model.colorTone = colorTone;
        }
    }
}
