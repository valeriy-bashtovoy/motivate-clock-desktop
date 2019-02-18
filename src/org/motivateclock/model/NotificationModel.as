/**
 * Created by Valeriy on 04.04.2015.
 */
package org.motivateclock.model
{

    import flash.events.EventDispatcher;

    import org.motivateclock.events.NotificationEvent;
    import org.motivateclock.interfaces.INotificationData;
    import org.motivateclock.interfaces.INotificationModel;

    public class NotificationModel extends EventDispatcher implements INotificationModel
    {
        private var _notificationList:Vector.<String> = new <String>[];

        public function NotificationModel()
        {
        }

        public function show(type:String, data:INotificationData):void
        {
            _notificationList.push(type);

            dispatchEvent(new NotificationEvent(NotificationEvent.SHOW, type, data));
        }

        public function hide(type:String):void
        {
        }

        public function hideAll():void
        {
            dispatchEvent(new NotificationEvent(NotificationEvent.HIDE_ALL));
        }
    }
}
