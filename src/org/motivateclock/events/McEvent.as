package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.model.vo.ProcessVO;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class McEvent extends Event
    {

        public static const APP_ADD:String = "appAdd";

        public static const PROJECT_SELECTED:String = "projectSelected";
        public static const LOAD_COMPLETE:String = "loadComplete";
        public static const OPEN_STATISTIC:String = "openStatistic";
        public static const CLOSE_STATISTIC:String = "closeStatistic";
        public static const ITEM_SELECTED:String = "itemSelected";
        public static const CONFIRMED:String = "confirmed";
        public static const CANCEL:String = "cancel";
        public static const OPEN:String = "open";
        public static const RESIZE:String = "resize";
        public static const DATA_OBTAINED:String = "dataObtained";
        public static const PROJECTS_OBTAINED:String = "projectsObtained";
        public static const DB_LOADED:String = "dbLoaded";
        public static const RESIZE_MAIN:String = "resizeMain";
        public static const STATISTIC_BY_DAY_OBTAINED:String = "statisticByDayObtained";
        public static const PDF_SAVED:String = "pdfSaved";
        public static const LANGUAGE_CHANGED:String = "languageChanged";

        public var projectId:String;
        public var height:int;
        public var openType:String;
        public var messageType:String;
        public var result:Array;
        public var data:String;
        public var size:int;
        public var time:Number;
        public var pdfPath:String;

        public var appVO:ProcessVO;

        public function McEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }
    }
}
