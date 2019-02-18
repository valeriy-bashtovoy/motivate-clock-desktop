/**
 * User: Valeriy Bashtovoy
 * Date: 12/1/2014
 */
package org.motivateclock.controller.command
{

    import flash.filesystem.File;

    import org.motivateclock.Model;
    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.events.StorageEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.utils.Storage;

    public class LoadTempProcessCommand implements ICommand
    {
        private var _model:Model;
        private var _tempFile:File;

        public function LoadTempProcessCommand(model:Model)
        {
            _model = model;
        }

        public function execute():void
        {
            _tempFile = File.applicationStorageDirectory.resolvePath(FileEnum.TEMP);

            if (!_tempFile.exists)
            {
                return;
            }

            var storage:Storage = new Storage(_tempFile);
            storage.addEventListener(StorageEvent.COMPLETE, storage_completeHandler);
            storage.loadString();
        }

        private function storage_completeHandler(event:StorageEvent):void
        {
            const data:String = event.data as String;
            const rawProcessList:Array = data.split("\n");
            const length:int = rawProcessList.length;

            var processInfo:Array;

            var date:String;
            var projectId:String;
            var name:String;
            var path:String;
            var time:Number;

            for (var i:int = 0; i < length; i++)
            {
                processInfo = rawProcessList[i].split("\t");

                if (processInfo.length == 0)
                {
                    continue;
                }

                projectId = processInfo[0];
                date = processInfo[1];
                name = processInfo[2];
                path = processInfo[3];
                time = processInfo[4];

                if (!projectId)
                {
                    continue;
                }

                //trace(this, projectId, date, path, name, time);

                _model.dataBase.syncProcess(projectId, date, path, name, time);
            }

            //trace(this);

            _tempFile.deleteFile();
        }
    }
}
