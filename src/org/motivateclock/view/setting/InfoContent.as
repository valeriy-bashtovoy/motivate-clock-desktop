package org.motivateclock.view.setting
{

    import flash.display.MovieClip;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.Model;
    import org.motivateclock.enum.LinkEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.interfaces.IContent;
    import org.motivateclock.model.update.UpdaterModel;
    import org.motivateclock.resource.ResourceCommon;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.SmartContainer;
    import org.motivateclock.view.components.TextArea;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class InfoContent extends MovieClip implements IContent
    {
        private static const LIB_SEPARATOR:String = "Lib.Separator";

        private var _infoField:TextField;
        private var _siteField:TextField;
        private var _updateField:TextField;
        private var _separatorUp:MovieClip;
        private var _separatorDown:MovieClip;

        private var _offset:int = 6;
        private var _updater:UpdaterModel;
        private var _newsTextArea:TextArea;
        private var _hotkeyTextArea:TextArea;
        private var _smartContainer:SmartContainer;
        private var _gfx:MovieClip;
        private var _developersXML:XML;
        private var _model:Model;

        public function InfoContent(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_INFO_CONTENT) as MovieClip;
            addChild(_gfx);

            _infoField = _gfx["infoField"];
            _siteField = _gfx["siteField"];
            _updateField = _gfx["updateField"];
            _separatorDown = _gfx["separatorDown"];
            _separatorUp = _gfx["separatorUp"];


            _updater = UpdaterModel.getInstance();

            var sheet:StyleSheet = new StyleSheet();
            sheet.parseCSS("a {text-decoration: underline; color: #1489ac;} a:hover {text-decoration: none; color:#c76900;}");

            _developersXML = XML(new ResourceCommon.DEVELOPERS_INFO());

            _updateField.styleSheet = sheet;
            _updateField.mouseWheelEnabled = false;
            _updateField.autoSize = TextFieldAutoSize.CENTER;
            _updateField.wordWrap = true;

            _siteField.styleSheet = sheet;
            _siteField.mouseWheelEnabled = false;
            _siteField.autoSize = TextFieldAutoSize.CENTER;
            _siteField.wordWrap = true;

            _infoField.styleSheet = sheet;
            _infoField.mouseWheelEnabled = false;
            _infoField.autoSize = TextFieldAutoSize.CENTER;
            _infoField.wordWrap = true;

            _newsTextArea = new TextArea();
            _newsTextArea.autoSize = TextFieldAutoSize.CENTER;
            _newsTextArea.initialize(175, 68, 0x252628, 12, TextArea.LIB_MYRIAD_PRO_SEMIBOLD);
            _newsTextArea.highlightUrl();
            _newsTextArea.x = _infoField.x;

            _hotkeyTextArea = new TextArea();
            _hotkeyTextArea.condenseWhite = true;
            _hotkeyTextArea.autoSize = TextFieldAutoSize.CENTER;
            _hotkeyTextArea.initialize(175, 68, 0x252628, 12, TextArea.LIB_MYRIAD_PRO_SEMIBOLD);
            _hotkeyTextArea.highlightUrl();
            _hotkeyTextArea.x = _infoField.x;

            _smartContainer = new SmartContainer(this, SmartContainer.VERTICAL);
            _smartContainer.offset = _offset;

            _smartContainer.addItem(_updateField);
            _smartContainer.addItem(createSeparator(_separatorUp.x, 0));
            _smartContainer.addItem(_newsTextArea);
            _smartContainer.addItem(_separatorUp);
            _smartContainer.addItem(_siteField);
            _smartContainer.addItem(createSeparator(_separatorUp.x, 0));
            _smartContainer.addItem(_infoField);
            _smartContainer.addItem(_separatorDown);
            _smartContainer.addItem(_hotkeyTextArea);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();
        }

        private function createSeparator(x:int, y:int):MovieClip
        {
            var separator:MovieClip = RegularUtils.getInstanceFromLib(LIB_SEPARATOR) as MovieClip;
            separator.x = x;
            separator.y = y;

            return separator;
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            var updateInfo:String = _model.languageModel.getText(TextKeyEnum.ABOUT_UPDATE_CURRENT) + "<br>Motivate Clock " + _updater.currentVersionLabel;
            var homepage:String = _model.languageModel.getLink(LinkEnum.HOME_PAGE);

            if (_updater.hasNewVersion)
            {
                updateInfo = "<a href='" + _updater.downloadUrl + "'>";
                updateInfo += _model.languageModel.getText(TextKeyEnum.ABOUT_UPDATE_NEW) + "<br>Motivate Clock " + _updater.latestVersionLabel + "</a>";
            }

            _updateField.htmlText = updateInfo;

            _siteField.htmlText = _model.languageModel.getText(TextKeyEnum.ABOUT_SITE) + "<br><a href='" + homepage + "'>motivateclock.org</a>";

            _hotkeyTextArea.htmlText = _model.languageModel.getText(TextKeyEnum.ABOUT_HOTKEY);

            if (_updater.description)
            {
                _newsTextArea.htmlText = _updater.description;
            }
            else
            {
                _newsTextArea.visible = false;
                _separatorUp.visible = false;
            }

            _infoField.htmlText = _model.languageModel.getText(TextKeyEnum.ABOUT_DEVELOPERS) + "<br>";

            var language:String = _model.settingModel.settings.language;
            var name:String;

            for each(var developer:XML in _developersXML.*)
            {
                name = developer.*.(@lang == language);

                if (!name)
                    continue;

                if (developer.@link != "")
                {
                    _infoField.htmlText += "<a href='" + developer.@link + "'>" + name + "</a><br>";
                }
                else
                {
                    _infoField.htmlText += name + "<br>";
                }
            }

            _smartContainer.update();
        }

        public function dispose():void
        {
            _model.languageModel.removeEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);
        }
    }
}
