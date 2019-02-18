package org.motivateclock.view.windows
{

    import flash.events.Event;

    import org.motivateclock.Model;
    import org.motivateclock.model.Project;
    import org.motivateclock.model.icons.IconManager;
    import org.motivateclock.view.projects.setting.ProcessesContent;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessesWindow extends AbstractWindow
    {

        private static var instance:ProcessesWindow;
        private static var isSingleton:Boolean = false;

        private var _processesContent:ProcessesContent;
        private var _background:WindowBackground;

        public static function getInstance():ProcessesWindow
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new ProcessesWindow();
                isSingleton = false;
            }

            return instance;
        }

        public function ProcessesWindow()
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

        override public function initialize(model:Model):void
        {
            super.initialize(model);

            _background = new WindowBackground(_model);
            stage.addChild(_background);

            _background.showSeparator(false);
            _background.title = "";
            _background.addEventListener(Event.CLOSE, closeHandler);

            _processesContent = new ProcessesContent(_model);
            _processesContent.y += 5;
            _processesContent.addEventListener(Event.CLOSE, closeHandler);

            _background.setHeight(440);

            setSize(_background.width, _model.settingModel.settings.appHeight);

            stage.addChild(_processesContent);
        }

        public function showSiteSelector():void
        {
            _processesContent.showSiteSelector();
            show();
        }

        public function showAppSelector():void
        {
            _processesContent.showAppSelector();
            show();
        }

        public function setProject(value:Project):void
        {
            _processesContent.setProject(value);
        }

        private function closeHandler(event:Event):void
        {
            hide();
            _processesContent.dispose();
            IconManager.getInstance().save();
        }

        override public function setSize(newWidth:int, newHeight:int):void
        {
            _background.setHeight(newHeight);

            super.setSize(newWidth, newHeight);
        }
    }
}
