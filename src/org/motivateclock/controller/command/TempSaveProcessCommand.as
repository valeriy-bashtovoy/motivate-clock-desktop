/**
 * User: Valeriy Bashtovoy
 * Date: 12/1/2014
 */
package org.motivateclock.controller.command
{

    import flash.filesystem.File;
    import flash.filesystem.FileMode;

    import org.motivateclock.Model;
    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.utils.Storage;

    public class TempSaveProcessCommand implements ICommand
    {
        private var _model:Model;
        private var _process:IProcess;

        public function TempSaveProcessCommand(model:Model, process:IProcess)
        {
            _model = model;
            _process = process;
        }

        public function execute():void
        {
            _model.clockModel.tick();

            const separator:String = "\t";
            const date:String = new Date().toDateString();
            const projectId:String = _model.projectModel.currentProject.id;
            const tempFile:File = File.applicationStorageDirectory.resolvePath(FileEnum.TEMP);

            const data:String = projectId + separator + date + separator + _process.name + separator + _process.path + separator + _process.time + "\n";

            const storage:Storage = new Storage(tempFile);
            storage.saveString(data, FileMode.WRITE);

            //trace(this, "save, data:", data);
        }
    }
}
