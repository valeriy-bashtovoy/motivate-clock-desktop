/**
 * User: Valeriy Bashtovoy
 * Date: 11/24/2015
 */
package org.motivateclock.interfaces
{

    import flash.display.DisplayObject;
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;

    public interface IToast extends IDisposable, IEventDispatcher
    {
        function initialize(size:Rectangle, icon:DisplayObject, text:String):void
    }
}
