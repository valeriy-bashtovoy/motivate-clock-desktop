package org.motivateclock.model.settings
{

    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.net.registerClassAlias;

    import org.motivateclock.enum.FileEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.update.UpdaterModel;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class SettingsManager extends EventDispatcher
    {

        private var _settings:Settings;

        public function SettingsManager()
        {
            load();
        }

        public function setProperty(key:String, value:*):void
        {
            if (!_settings.hasOwnProperty(key))
            {
                return;
            }

            _settings[key] = value;

            var e:ModelEvent = new ModelEvent(ModelEvent.SETTING_CHANGE);
            e.propertyKey = key;
            dispatchEvent(e)
        }

        public function get settings():Settings
        {
            return _settings;
        }

        private function createSettings():void
        {
            _settings = new Settings();
            _settings.autorun = true;
            _settings.versionNumber = UpdaterModel.getInstance().currentVersionNumber;
        }

        public function load():void
        {
            registerClassAlias("SettingsAlias", Settings);

            var file:File = File.applicationStorageDirectory.resolvePath(FileEnum.SETTINGS);

            if (!file.exists)
            {
                createSettings();
                return;
            }

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);

            while (stream.bytesAvailable)
            {
                try
                {
                    _settings = stream.readObject() as Settings;
                }
                catch (error:Error)
                {
                }
            }

            if (!_settings)
            {
                createSettings();
                return;
            }

            stream.close();
        }

        public function save():void
        {
            var file:File = File.applicationStorageDirectory.resolvePath(FileEnum.SETTINGS);
            var stream:FileStream = new FileStream();
            stream.openAsync(file, FileMode.WRITE);//Async
            stream.writeObject(_settings);
            stream.close();
        }
    }
}
