/**
 * User: Valeriy Bashtovoy
 * Date: 20.09.13
 */
package org.motivateclock.view.components
{

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    public class SmartContainer
    {
        public static const HORIZONTAL:String = "horizontal";
        public static const VERTICAL:String = "vertical";

        private var _itemCollection:Vector.<DisplayObject>;
        private var _offset:int = 0;
        private var _target:DisplayObjectContainer;
        private var _type:String;
        private var _skipInvisible:Boolean = true;

        public function SmartContainer(target:DisplayObjectContainer, type:String)
        {
            _target = target;
            _type = type;
            _itemCollection = new <DisplayObject>[];
        }

        public function addItem(item:DisplayObject, index:int = -1):void
        {
            _itemCollection.push(item);

            if (index != -1)
            {
                _target.addChildAt(item, index);
            }
            else
            {
                _target.addChild(item);
            }

            update();
        }

        public function set skipInvisible(value:Boolean):void
        {
            _skipInvisible = value;
        }

        public function set offset(value:int):void
        {
            _offset = value;
            update();
        }

        public function update():void
        {
            var nextY:int = 0;
            var nextX:int = 0;

            for each(var item:DisplayObject in _itemCollection)
            {
                if (_skipInvisible && !item.visible)
                {
                    continue;
                }

                if (_type == VERTICAL)
                {
                    item.y = nextY;
                    nextY += item.height + _offset;
                }
                else
                {
                    item.x = nextX;
                    nextX += item.width + _offset;
                }
            }
        }
    }
}
