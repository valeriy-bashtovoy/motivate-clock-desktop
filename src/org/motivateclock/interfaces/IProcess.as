/**
 * Created by Valeriy on 23.11.2014.
 */
package org.motivateclock.interfaces
{

    import flash.events.IEventDispatcher;

    public interface IProcess extends IEventDispatcher
    {
        function get id():String

        function get type():String

        function set type(value:String):void

        function get name():String

        function set name(value:String):void

        function get path():String

        function set path(value:String):void

        function get time():Number

        function set time(value:Number):void

        function get isMarked():Boolean

        function set isMarked(value:Boolean):void

        function get isSite():Boolean

        function increaseTime(time:Number):void

        function clear():void

        function serialize():String

        function clone():IProcess
    }
}
