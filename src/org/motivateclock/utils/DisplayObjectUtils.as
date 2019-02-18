/**
 * User: Valeriy Bashtovoy
 * Date: 24.11.13
 */
package org.motivateclock.utils
{

    import flash.display.DisplayObject;
    import flash.display.SimpleButton;
    import flash.filters.ColorMatrixFilter;

    public class DisplayObjectUtils
    {
        public function DisplayObjectUtils()
        {
        }

        public static function setGrayscale(target:DisplayObject):void
        {
            var rc:Number = 1 / 3;
            var gc:Number = rc;
            var bc:Number = rc;

            target.filters = [new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0])];
        }

        public static function createButton(upState:Class, overState:Class = null, downState:Class = null, hitTestState:Class = null):SimpleButton
        {
            var button:SimpleButton = new SimpleButton();
            button.upState = new upState();
            button.overState = overState ? new overState() : new upState();
            button.downState = downState ? new downState() : button.overState;
            button.hitTestState = hitTestState ? new hitTestState() : button.overState;

            return button;
        }
    }
}
