/**
 * Created by Valeriy Bashtovoy on 30.08.2015.
 */
package org.motivateclock.view.statistic
{

    import flash.display.DisplayObjectContainer;

    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.view.AbstractListView;

    public class StatisticsListView extends AbstractListView
    {
        private var _enabled:Boolean = true;

        public function StatisticsListView(numVisibleItem:int, itemWidth:int, itemHeight:int, itemGap:int)
        {
            super(numVisibleItem, itemWidth, itemHeight, itemGap);
        }

        public function set enabled(value:Boolean):void
        {
            _enabled = value;
        }

        override protected function createItem(data:Object):DisplayObjectContainer
        {
            var itemRenderer:StatisticItemRenderer = new StatisticItemRenderer(data as IProcess);
            itemRenderer.enabled = _enabled;
            return itemRenderer;
        }
    }
}
