/**
 * User: Valeriy Bashtovoy
 * Date: 02.09.13
 */
package org.motivateclock.services
{

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;

    import org.motivateclock.interfaces.IService;

    public class BrowserExtensionService implements IService
    {
        private static const HOST:String = "127.0.0.1";
        private static const PORT:int = 1257;

        private var _serverSocket:ServerSocket;
        private var _dataHandler:Function;
        private var _errorHandler:Function;
        private var _response:String = "";

        public function BrowserExtensionService()
        {
        }

        public function initialize():void
        {
            _serverSocket = new ServerSocket();
            _serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, serverSocket_connectHandler);
            _serverSocket.addEventListener(IOErrorEvent.IO_ERROR, serverSocket_ioErrorHandler);

            try
            {
                _serverSocket.bind(PORT, HOST);
                _serverSocket.listen();
            }
            catch (e:Error)
            {
                trace("Warning. " + e.message);
            }
        }

        private function serverSocket_connectHandler(event:ServerSocketConnectEvent):void
        {
            event.socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            event.socket.addEventListener(Event.CLOSE, socketCloseHandler);
        }

        private function socketCloseHandler(event:Event):void
        {
            _response = "";
        }

        private function serverSocket_ioErrorHandler(event:IOErrorEvent):void
        {
            if (_errorHandler)
            {
                _errorHandler(event.text);
            }
        }

        private function socketDataHandler(event:ProgressEvent):void
        {
            var clientSocket:Socket = Socket(event.target);

            _response += clientSocket.readUTFBytes(clientSocket.bytesAvailable);

            var isValid:Boolean = isValidResponse(_response);

            if (!isValid)
            {
                return;
            }

            var data:String = _response.toString();
            var dataList:Array;

            if (!data || !_dataHandler)
            {
                return;
            }

            dataList = data.split("\n");

            _dataHandler(dataList[dataList.length - 1]);

            _response = "";
        }

        public function isValidResponse(response:String):Boolean
        {
            return response.charAt(response.length - 1) == "}";
        }

        public function initializeHandlers(dataHandler:Function, errorHandler:Function = null):void
        {
            _dataHandler = dataHandler;
            _errorHandler = errorHandler;
        }

        public function dispose():void
        {
            try
            {
                _serverSocket.close();
            }
            catch (e:Error)
            {
                trace("Warning. " + e.message);
            }
        }
    }
}
