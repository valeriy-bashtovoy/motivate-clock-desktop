/**
 * Created by Valeriy Bashtovoy on 01.09.2015.
 */
package org.motivateclock.interfaces
{

    import flash.display.DisplayObjectContainer;

    public interface ISkinManager
    {
        function registerDisplayObject(item:DisplayObjectContainer);

        function unregisterDisplayObject(item:DisplayObjectContainer);

        function setColor(color:uint);

        function setColorTone(tone:int);
    }
}
