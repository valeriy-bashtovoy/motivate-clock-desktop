/**
 * Created by Valeriy Bashtovoy on 05.08.2015.
 */
package org.motivateclock.interfaces
{

    import flash.events.IEventDispatcher;

    public interface IStatisticsModel extends IEventDispatcher
    {
        function set processList(value:Vector.<IProcess>):void

        function get processList():Vector.<IProcess>

        function set currentProject(value:IProject):void

        function get currentProject():IProject;

        function set currentProcess(value:IProcess):void;

        function get currentProcess():IProcess;

        function getProcess(id:String):IProcess;

        function hasProcess(process:IProcess):Boolean;

        function addProcess(process:IProcess):void;

        function updateCurrentProcess(time:Number):void;
    }
}
