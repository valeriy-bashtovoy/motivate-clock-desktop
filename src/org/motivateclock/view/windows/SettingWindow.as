package org.motivateclock.view.windows
{

    import flash.events.Event;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.view.content.ContentToggle;
    import org.motivateclock.view.content.ContentVO;
    import org.motivateclock.view.setting.*;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class SettingWindow extends AbstractWindow
    {
        public static var instance:SettingWindow;
        private static var isSingleton:Boolean = false;

        private var _background:WindowBackground;

        private var _contentToggle:ContentToggle;

        public static function getInstance():SettingWindow
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new SettingWindow();
                isSingleton = false;
            }

            return instance;
        }

        public function SettingWindow()
        {
            if (!isSingleton)
            {
                trace("Error: " + this + " is singletone, use getInstance()");
            }
            else
            {
                super();
            }
        }

        public function showInfo():void
        {
            _contentToggle.showContent(ContentToggle.RIGTH);
            show();
        }

        public function showSetting():void
        {
            _contentToggle.showContent(ContentToggle.LEFT);
            show();
        }

        override public function initialize(model:Model):void
        {
            super.initialize(model);

            _background = new WindowBackground(_model);
            _background.showSeparator(false);
            _background.addEventListener(Event.CLOSE, closeHandler);
            stage.addChild(_background);

            _contentToggle = new ContentToggle(_model);
            _contentToggle.setContentArguments(_model);
            _background.addContent(_contentToggle);

            var content:ContentVO = new ContentVO();
            content.label = TextKeyEnum.SETTINGS;
            content.hint = TextKeyEnum.SETTINGS;
            content.icon = "ui.contenttoggle.settingicon";
            content.content = SettingContent;

            _contentToggle.addContent(ContentToggle.LEFT, content);

            content = new ContentVO();
            content.label = TextKeyEnum.ABOUT_TITLE;
            content.hint = TextKeyEnum.ABOUT_TITLE;
            content.icon = "ui.contenttoggle.infoicon";
            content.content = InfoContent;

            _contentToggle.addContent(ContentToggle.RIGTH, content);

            setSize(_background.width, _model.settingModel.settings.appHeight);
        }

        override public function setSize(newWidth:int, newHeight:int):void
        {
            _background.setHeight(newHeight);
            _contentToggle.setHeight(newHeight - 110);

            super.setSize(newWidth, newHeight);
        }

        override public function hide():void
        {
            super.hide();
            _model.settingModel.save();
            _contentToggle.dispose();
        }

        private function closeHandler(event:Event):void
        {
            hide();
        }
    }
}
