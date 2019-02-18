/**
 * User: Valeriy Bashtovoy
 * Date: 23.11.13
 */
package org.motivateclock.view.projects.setting
{

    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;

    import org.motivateclock.Model;
    import org.motivateclock.enum.BrowserEnum;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.events.ViewEvent;
    import org.motivateclock.resource.ResourceImage;
    import org.motivateclock.utils.DisplayObjectUtils;
    import org.motivateclock.view.components.SmartContainer;
    import org.motivateclock.view.components.TextArea;

    public class BrowserInstallView extends Sprite
    {
        private static const GAP_VERTICAL:int = 6;
        private static const GAP_HORIZONTAL:int = 1;

        private var _helpField:TextArea;
        private var _smartContainer:SmartContainer;
        private var _iconHolder:Sprite;
        private var _iconContainer:SmartContainer;

        private var _fireFoxIcon:SimpleButton;
        private var _chromeIcon:SimpleButton;
        private var _operaIcon:SimpleButton;
        private var _model:Model;

        public function BrowserInstallView(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            _iconHolder = new Sprite();

            _smartContainer = new SmartContainer(this, SmartContainer.VERTICAL);
            _smartContainer.offset = GAP_VERTICAL;

            _helpField = new TextArea();
            _helpField.initialize(169, 50, 0x5e6064, 12, TextArea.LIB_MYRIAD_PRO_SEMIBOLD);
            _helpField.autoSize = TextFieldAutoSize.CENTER;
            _helpField.align = TextFormatAlign.CENTER;

            createBrowsersIcon();

            _smartContainer.addItem(_helpField);
            _smartContainer.addItem(_iconHolder);

            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler, false, 0, true);

            languageChangeHandler();
        }

        private function createBrowsersIcon():void
        {
            _iconContainer = new SmartContainer(_iconHolder, SmartContainer.HORIZONTAL);
            _iconContainer.skipInvisible = true;
            _iconContainer.offset = GAP_HORIZONTAL;

            _chromeIcon = createButton(BrowserEnum.CHROME, ResourceImage.CHROME_ICON_UP, ResourceImage.CHROME_ICON_OVER);
            _operaIcon = createButton(BrowserEnum.OPERA_LAUNCHER, ResourceImage.OPERA_ICON_UP, ResourceImage.OPERA_ICON_OVER);
            _fireFoxIcon = createButton(BrowserEnum.FIREFOX, ResourceImage.FIREFOX_ICON_UP, ResourceImage.FIREFOX_ICON_OVER);
        }

        private function createButton(id:String, upState:Class, overState:Class, visible:Boolean = true):SimpleButton
        {
            var button:SimpleButton = DisplayObjectUtils.createButton(upState, overState);
            button.name = id;
            button.visible = visible;
            button.addEventListener(MouseEvent.CLICK, button_clickHandler, false, 0, true);

            _iconContainer.addItem(button);

            return button;
        }

        private function updatePosition():void
        {
            _smartContainer.update();
            _iconContainer.update();
            _iconHolder.x = (_helpField.width - _iconHolder.width) / 2;
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _helpField.htmlText = _model.languageModel.getText(TextKeyEnum.PROCESSES_INSTALL_EXTENSION);
            updatePosition();
        }

        private function button_clickHandler(event:MouseEvent):void
        {
            var e:ViewEvent = new ViewEvent(ViewEvent.INSTALL_EXTENSION, true);
            e.browserId = SimpleButton(event.currentTarget).name;
            dispatchEvent(e);
        }
    }
}
