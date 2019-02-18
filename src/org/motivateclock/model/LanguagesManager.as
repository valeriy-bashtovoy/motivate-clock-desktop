package org.motivateclock.model
{

    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.system.Capabilities;

    import org.motivateclock.Model;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceCommon;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class LanguagesManager extends EventDispatcher
    {
        private var _languagesXml:XML;
        private var _sysLanguage:String;
        private var _currentLanguage:String;
        private var _languageData:XMLList;

        private var _isFirstLaunch:Boolean = false;
        private var _linkXML:XML;
        private var _model:Model;

        public function LanguagesManager(model:Model)
        {
            _model = model;


            _linkXML = XML(new ResourceCommon.LINKS);

            _sysLanguage = Capabilities.language;
            _currentLanguage = _model.settingModel.settings.language;
            _isFirstLaunch = Boolean(_currentLanguage == "");

            if (_isFirstLaunch)
            {
                switch (_sysLanguage)
                {
                    case "ru":
                    case "ua":
                        _currentLanguage = _sysLanguage;
                        break;
                    default:
                        _currentLanguage = "en";
                }
            }

            load();
        }

        public function setLanguage(value:String):void
        {
            _currentLanguage = value;

            _model.settingModel.settings.language = _currentLanguage;

            if (_isFirstLaunch)
            {
                _isFirstLaunch = false;
                _model.settingModel.save();
            }

            var language:XMLList = _languagesXml.*.(@ID == _currentLanguage);

            if (language)
            {
                _languageData = language.*;
            }

            dispatchEvent(new McEvent(McEvent.LANGUAGE_CHANGED));
        }

        public function getLangugesList():XMLList
        {
            var languageList:XML = _languagesXml.copy();

            for each (var node:XML in languageList.*)
            {
                delete node.TEXT;
            }

            return languageList.*;
        }

        public function getText(id:String):String
        {
            var text:String = _languageData.(@ID == id);

            if (text == "")
            {
                text = id;
            }

            return text;
        }

        public function getLink(id:String):String
        {
            var languageLinksXML:XMLList = _linkXML.*.(@lang == _currentLanguage);

            if (!languageLinksXML)
            {
                return "";
            }

            return languageLinksXML.*.(@id == id);
        }

        public function load():void
        {
            var file:File = File.applicationDirectory.resolvePath("text.xml");
            var rawData:String;

            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.READ);
            try
            {
                rawData = stream.readUTFBytes(stream.bytesAvailable);
            }
            catch (error:Error)
            {
            }

            _languagesXml = XML(rawData);

            if (!_languagesXml)
            {
                trace(this, "Warning. Language xml load error;");
                return;
            }

            stream.close();

            setLanguage(_currentLanguage);
        }
    }
}
