/**
 * User: Valeriy Bashtovoy
 * Date: 14.06.2014
 */
package org.motivateclock.interfaces
{

    public interface IAnalytics
    {
        function track(type:String, data:Object):void;
    }
}
