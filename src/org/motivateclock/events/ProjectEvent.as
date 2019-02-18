package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.model.vo.ProcessVO;

    /**
     * @author: Valeriy Bashtovoy
     *
     *
     * org.motivateclock.common.ProjectEvent
     */
    public class ProjectEvent extends Event
    {

        public static const ACTIVE_APP_CHANGE:String = "activeAppChange";
        public static const APP_ADDED:String = "appAdded";
        public static const APP_REMOVED:String = "appRemoved";

        public var appVO:ProcessVO;

        public function ProjectEvent(type:String, appVO:ProcessVO, bubbles:Boolean = false, cancelable:Boolean = false)
        {
            this.appVO = appVO;
            super(type, bubbles, cancelable);
        }
    }
}
