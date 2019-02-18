package org.motivateclock.model.update
{

    import flash.desktop.NativeApplication;
    import flash.events.EventDispatcher;

    import org.motivateclock.events.ModelEvent;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class UpdaterModel extends EventDispatcher
    {

        public static var instance:UpdaterModel;
        private static var isSingleton:Boolean = false;

        private var _currentVersionNumber:String;
        private var _currentVersionLabel:String;

        private var _latestVersionNumber:String;
        private var _latestVersionLabel:String;

        private var _downloadUrl:String;
        private var _description:String;
        private var _applicationName:String;

        public static function getInstance():UpdaterModel
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new UpdaterModel();
                isSingleton = false;
            }

            return instance;
        }

        public function UpdaterModel()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + "is singletone, use getInstance();");
            }

            var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
            var ns:Namespace = descriptor.namespace();

            _currentVersionNumber = descriptor.ns::versionNumber;
            _currentVersionLabel = descriptor.ns::versionLabel;
            _applicationName = descriptor.ns::name;

            trace(_applicationName, "v." + _currentVersionLabel);
        }

        public function setUpdateInfo(latestVersionNumber:String, latestVersionLabel:String, downloadUrl:String, description:String):void
        {
            _downloadUrl = downloadUrl;
            _description = description;
            _latestVersionNumber = latestVersionNumber;
            _latestVersionLabel = latestVersionLabel;

            if (!hasNewVersion)
            {
                return;
            }

            dispatchEvent(new ModelEvent(ModelEvent.UPDATE_AVAILABLE));
        }

        public function get description():String
        {
            return _description;
        }

        public function get downloadUrl():String
        {
            return _downloadUrl;
        }

        public function get currentVersionNumber():String
        {
            return _currentVersionNumber;
        }

        public function get latestVersionNumber():String
        {
            return _latestVersionNumber;
        }

        public function get currentVersionLabel():String
        {
            return _currentVersionLabel;
        }

        public function get latestVersionLabel():String
        {
            return _latestVersionLabel;
        }

        public function get hasNewVersion():Boolean
        {
            if (!_latestVersionLabel)
            {
                return false;
            }

            return _latestVersionNumber != _currentVersionNumber || _latestVersionLabel != _currentVersionLabel;
        }

        public function get applicationName():String
        {
            return _applicationName;
        }
    }
}
