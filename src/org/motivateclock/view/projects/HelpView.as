/**
 * Created by Valeriy on 02.07.2015.
 */
package org.motivateclock.view.projects
{

    import flash.display.Sprite;
    import flash.events.TextEvent;
    import flash.text.TextFieldAutoSize;

    import org.motivateclock.Model;
    import org.motivateclock.enum.HelpActionEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.interfaces.IDisposable;
    import org.motivateclock.view.components.TextArea;
    import org.motivateclock.view.windows.ProcessesWindow;

    public class HelpView extends Sprite implements IDisposable
    {
        private var _model:Model;
        private var _helpField:TextArea;

        public function HelpView(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            _helpField = new TextArea();
            _helpField.initialize(180, 50, 0x5e6064, 12, TextArea.LIB_MYRIAD_PRO_SEMIBOLD);
            _helpField.autoSize = TextFieldAutoSize.CENTER;
            _helpField.highlightUrl();
            _helpField.addEventListener(TextEvent.LINK, helpTextEventHandler, false, 0, true);
            addChild(_helpField);

            _model.addEventListener(ModelEvent.PROJECT_HELP_TEXT_CHANGE, projectHelpTextChangeHandler, false, 0, true);

            projectHelpTextChangeHandler();
        }

        private function helpTextEventHandler(event:TextEvent):void
        {
            ProcessesWindow.getInstance().setProject(_model.projectModel.currentProject);

            switch (event.text)
            {
                case HelpActionEnum.EXTENSION:
                    ProcessesWindow.getInstance().showSiteSelector();
                    break;
                case HelpActionEnum.SETTING:
                    ProcessesWindow.getInstance().showAppSelector();
                    break;
                case HelpActionEnum.CREATE:
                    dispatchEvent(new ViewEvent(ViewEvent.CREATE_PROJECT));
                    break;
            }
        }

        private function projectHelpTextChangeHandler(event:ModelEvent = null):void
        {
            _helpField.htmlText = _model.projectsHelpText;
        }

        public function dispose():void
        {
            _model.removeEventListener(ModelEvent.PROJECT_HELP_TEXT_CHANGE, projectHelpTextChangeHandler);
        }
    }
}
