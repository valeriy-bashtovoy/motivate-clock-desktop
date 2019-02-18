/**
 * Created by Valeriy on 23.11.2014.
 */
package org.motivateclock.interfaces
{

    import flash.events.IEventDispatcher;

    public interface IProcessModel extends IEventDispatcher
    {
        function initialize(rawProcesses:String):void;

        function setCurrentProcess(process:IProcess):void;

        function get currentProcess():IProcess;

        function add(process:IProcess):void;

        function remove(process:IProcess):void;

        function has(process:IProcess):Boolean;

        function get processList():Vector.<IProcess>

        function increaseCurrentProcessTime(time:Number):void;

        function deserialize(rawProcesses:String):Vector.<IProcess>

        function serialize(processList:Vector.<IProcess>):String
    }
}
