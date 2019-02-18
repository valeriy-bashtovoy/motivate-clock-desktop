/**
 * Created by Valeriy Bashtovoy on 02.09.2015.
 */
package org.motivateclock.interfaces
{

    import flash.events.IEventDispatcher;

    import org.motivateclock.model.Project;

    public interface IProject extends IEventDispatcher
    {
        function equals(project:Project):Boolean

        function reset():void

        function get isManual():Boolean

        function set isChanged(value:Boolean):void

        function get isChanged():Boolean

        function set isCurrent(value:Boolean):void

        function get isCurrent():Boolean

        function set creationDate(value:Date):void

        function get creationDate():Date

        function set workTime(value:Number):void

        function get workTime():Number

        function set restTime(value:Number):void

        function get restTime():Number

        function set idleTime(value:Number):void

        function get idleTime():Number

        function set id(value:String):void

        function get id():String

        function set name(value:String):void

        function get name():String

        function set applications(value:String):void

        function get applications():String

        function get processModel():IProcessModel

        function set isAuto(value:Boolean):void

        function get isAuto():Boolean
    }
}
