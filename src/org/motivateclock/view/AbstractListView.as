package org.motivateclock.view
{

    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.Dictionary;

    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.GridScroll;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class AbstractListView extends Sprite
    {
        private var _itemRendererPool:Dictionary = new Dictionary();
        private var _contentHolder:Sprite;
        private var _scroll:GridScroll;
        private var _dataProvider:Vector.<Object>;
        private var _itemGap:int;
        private var _itemWidth:int;
        private var _itemHeight:int;

        // currently displayed data list;
        private var _dataList:Vector.<Object>;
        private var _numVisibleItem:int;
        private var _nextY:int = 0;
        private var _prevScrollPercent:Number = 0;

        public function AbstractListView(numVisibleItem:int, itemWidth:int, itemHeight:int, itemGap:int)
        {
            _numVisibleItem = numVisibleItem;
            _itemWidth = itemWidth;
            _itemGap = itemGap;
            _itemHeight = itemHeight;

            _contentHolder = new Sprite();

            _scroll = new GridScroll();
            _scroll.dynamicTrackButtonHeight = false;
            _scroll.setSize(_itemWidth, (_numVisibleItem + itemGap) * _itemHeight);
            _scroll.setContent(_contentHolder);
            _scroll.displayTrack = false;
            _scroll.addEventListener(Event.CHANGE, scrollChangeHandler, false, 0, true);
            addChild(_scroll);
        }

        public function get scroll():GridScroll
        {
            return _scroll;
        }

        override public function get height():Number
        {
            return _contentHolder.numChildren * _itemHeight;
        }

        public function update():void
        {
            render();
        }

        public function dispose():void
        {
            _scroll.dispose();

            removeItems();
            disposeCurrentPool();

            _scroll = null;
            _dataProvider = null;
            _itemRendererPool = null;
            _dataList = null;
        }

        public function setDataProvider(dataProvider:Vector.<Object>, reset:Boolean = true):void
        {
            trace(this, "setDataProvider()", dataProvider);

            if (!dataProvider || dataProvider == _dataProvider)
            {
                return;
            }

            _dataProvider = dataProvider;

            _scroll.update(_dataProvider.length * (_itemHeight + _itemGap), 1 / _dataProvider.length);

            _scroll.percent = reset ? 0 : _prevScrollPercent;

            render();
        }

        private function scrollChangeHandler(event:Event):void
        {
            render();
        }

        private function render():void
        {
            trace(this, 'render;');

            if (!_dataProvider)
                return;

            // data to be displayed
            const dataList:Vector.<Object> = getDataList();

            if (equal(dataList, _dataList))
            {
                trace(this, "The content is equal to already displayed;");
                return;
            }

            _scroll.displayTrack = _dataProvider.length > _numVisibleItem;
            _prevScrollPercent = _scroll.percent;

            removeItems();

            var data:Object;
            var itemRenderer:DisplayObjectContainer;
            var length:int = dataList.length;
            var pool:Dictionary = new Dictionary();

            for (var i:int = 0; i < length; i++)
            {
                data = dataList[i];

                itemRenderer = getItemFromPool(data);

                if (!itemRenderer)
                    itemRenderer = createItem(data);

                itemRenderer.y = _nextY;
                _contentHolder.addChild(itemRenderer);

                _nextY += int(_itemHeight + _itemGap);

                pool[data] = itemRenderer;
            }

            disposeCurrentPool();

            _dataList = dataList;
            _itemRendererPool = pool;

            dispatchEvent(new Event(Event.CHANGE));
        }

        private function disposeCurrentPool():void
        {
            for each (var item:IDisposable in _itemRendererPool)
            {
                if (item)
                    item.dispose();
            }
        }

        private function getItemFromPool(data:Object):DisplayObjectContainer
        {
            const item:DisplayObjectContainer = _itemRendererPool[data];

            if (item)
            {
                delete _itemRendererPool[data];
            }

            return item;
        }

        private function equal(dataList1:Vector.<Object>, dataList2:Vector.<Object>):Boolean
        {
            if (!dataList1 || !dataList2)
                return false;

            if (dataList1.length != dataList2.length)
                return false;

            var length:int = dataList1.length;

            for (var i:int = 0; i < length; i++)
            {
                if (dataList1[i] != dataList2[i])
                    return false;
            }

            return true;
        }

        private function getDataList():Vector.<Object>
        {
            const startIndex:int = Math.floor((_dataProvider.length - _numVisibleItem) * _scroll.percent);
            const endIndex:int = Math.min(startIndex + _numVisibleItem, _dataProvider.length);

            return _dataProvider.slice(startIndex, endIndex);
        }

        protected function createItem(data:Object):DisplayObjectContainer
        {
            throw new Error("This method must be overridden.");
        }

        protected function removeItems():void
        {
            _nextY = 0;
            RegularUtils.removeAllChildren(_contentHolder, false);
        }
    }
}
