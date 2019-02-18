/**
 * Created by Valeriy Bashtovoy on 01.09.2015.
 */
package org.motivateclock.model
{

    import caurina.transitions.Tweener;

    import flash.display.DisplayObjectContainer;

    import org.motivateclock.interfaces.ISkinManager;

    public class SkinManager implements ISkinManager
    {
        private static const ANIMATION_TIME:int = 2;

        private var _displayObjectList:Vector.<DisplayObjectContainer> = new <DisplayObjectContainer>[];
        private var _colorTone:int = 0;

        public function SkinManager()
        {
        }

        public function registerDisplayObject(item:DisplayObjectContainer)
        {
            if (!item)
            {
                trace(this, "Warning. DisplayObject can't be null;");
                return;
            }

            _displayObjectList.push(item);

            updateColorTone();
        }

        public function unregisterDisplayObject(item:DisplayObjectContainer)
        {
            if (!item)
            {
                trace(this, "Warning. DisplayObject can't be null;");
                return;
            }

            var length:int = _displayObjectList.length;
            var displayObject:DisplayObjectContainer;

            for (var i:int = 0; i < length; i++)
            {
                displayObject = _displayObjectList[i];

                if (item != displayObject)
                {
                    continue;
                }

                _displayObjectList.splice(i, 1);

                return;
            }
        }

        public function setColorTone(tone:int)
        {
            _colorTone = tone;

            updateColorTone(ANIMATION_TIME);
        }

        private function updateColorTone(animationTime:int = 0):void
        {
            for each (var displayObject:DisplayObjectContainer in _displayObjectList)
            {
                Tweener.addTween(displayObject, {_hue: _colorTone, time: animationTime});
            }
        }

        public function setColor(color:uint)
        {
        }
    }
}
