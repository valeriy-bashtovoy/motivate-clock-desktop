/**
 * User: Valeriy Bashtovoy
 * Date: 16.01.14
 */
package org.motivateclock.controller.command
{

    import caurina.transitions.properties.ColorShortcuts;

    import flash.desktop.NativeApplication;
    import flash.display.DisplayObject;
    import flash.filesystem.File;

    import org.motivateclock.Model;
    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.model.ErrorLog;

    public class StartupCommand implements ICommand
    {
        private var _model:Model;
        private var _view:DisplayObject;
        private var _errorLog:ErrorLog;

        public function StartupCommand(model:Model, view:DisplayObject)
        {
            _model = model;
            _view = view;
        }

        public function execute():void
        {
            ColorShortcuts.init();

            NativeApplication.nativeApplication.autoExit = false;

            _errorLog = ErrorLog.getInstance();
            _errorLog.init(_view.loaderInfo);

            var dataBaseFile:File = File.applicationStorageDirectory.resolvePath(FileEnum.DATA_BASE);

            _model.isFirstLaunch = !dataBaseFile.exists;

            // initialize ui;
            var command:ICommand = new InitializeUICommand(_model, _view);
            command.execute();

            _model.applicationManager.applyWindowPosition();
        }
    }
}
