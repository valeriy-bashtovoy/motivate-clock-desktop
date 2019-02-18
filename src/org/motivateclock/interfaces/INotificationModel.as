/**
 * Created by Valeriy on 05.04.2015.
 */
package org.motivateclock.interfaces
{

    public interface INotificationModel
    {
        function show(type:String, data:INotificationData):void

        function hide(type:String):void

        function hideAll():void
    }
}
