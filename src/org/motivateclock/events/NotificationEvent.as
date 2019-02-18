/**
 * Created by Valeriy on 05.04.2015.
 */
package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.interfaces.INotificationData;

    public class NotificationEvent extends Event
    {
        public static const SHOW:String = "show";
        public static const HIDE_ALL:String = "hide_all";

        public var notificationType:String = "";
        public var notificationData:INotificationData;

        public function NotificationEvent(eventType:String, notificationType:String = "", notificationData:INotificationData = null)
        {
            this.notificationType = notificationType;
            this.notificationData = notificationData;

            super(eventType, false, false);
        }
    }
}
