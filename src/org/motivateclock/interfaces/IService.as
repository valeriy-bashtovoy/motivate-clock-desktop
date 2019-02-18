/**
 * User: Valeriy Bashtovoy
 * Date: 02.09.13
 */
package org.motivateclock.interfaces
{

    public interface IService
    {
        function initialize():void

        function initializeHandlers(dataHandler:Function, errorHandler:Function = null):void

        function dispose():void
    }
}
