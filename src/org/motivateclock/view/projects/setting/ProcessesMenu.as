package org.motivateclock.view.projects.setting
{

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import org.motivateclock.Model;
    import org.motivateclock.enum.TextKeyEnum;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.resource.ResourceLib;
    import org.motivateclock.utils.RegularUtils;
    import org.motivateclock.view.components.Hint;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessesMenu extends MovieClip
    {
        public static const APP:String = "app";
        public static const SITE:String = "site";

        private var _appButton:MovieClip;
        private var _siteButton:MovieClip;
        private var _appButtonLabel:TextField;
        private var _siteButtonLabel:TextField;
        private var _siteButtonBack:MovieClip;
        private var _appButtonBack:MovieClip;
        private var _siteButtonIcon:MovieClip;
        private var _selected:String;

        private var _gfx:MovieClip;
        private var _model:Model;

        public function ProcessesMenu(model:Model)
        {
            _model = model;

            _gfx = RegularUtils.getInstanceFromLib(ResourceLib.GFX_PROCESS_MENU) as MovieClip;
            addChild(_gfx);

            _appButton = _gfx["appButton"];
            _siteButton = _gfx["siteButton"];

            _appButtonLabel = _appButton["label"];
            _appButtonBack = _appButton["back"];

            _siteButtonLabel = _siteButton["label"];
            _siteButtonBack = _siteButton["back"];
            _siteButtonIcon = _siteButton["icon"];


            _model.languageModel.addEventListener(McEvent.LANGUAGE_CHANGED, languageChangeHandler);

            languageChangeHandler();

            initButton(_appButton);
            initButton(_siteButton);

            appButtonSelected(true);
            siteButtonSelected(false);
        }

        public function dispose():void
        {
        }

        private function languageChangeHandler(event:McEvent = null):void
        {
            _appButtonLabel.text = _model.languageModel.getText(TextKeyEnum.PROCESSES_APP_TITLE);
            _siteButtonLabel.text = _model.languageModel.getText(TextKeyEnum.PROCESSES_SITE_TITLE);
        }

        public function selectApps():void
        {
            appButtonSelected(true);
            siteButtonSelected(false);
            _selected = ProcessesMenu.APP;
            dispatchEvent(new Event(Event.SELECT));
        }

        public function selectSites():void
        {
            siteButtonSelected(true);
            appButtonSelected(false);
            _selected = ProcessesMenu.SITE;
            dispatchEvent(new Event(Event.SELECT));
        }

        public function get selected():String
        {
            return _selected;
        }

        private function appButtonSelected(value:Boolean):void
        {
            _appButton.enabled = !value;
            _appButtonLabel.visible = value;
            _appButtonBack.visible = !value;
        }

        private function siteButtonSelected(value:Boolean):void
        {
            _siteButton.enabled = !value;

            _siteButtonLabel.visible = value;
            _siteButtonBack.visible = !value;

            if (value)
            {
                _siteButtonIcon.x = -84;
            }
            else
            {
                _siteButtonIcon.x = 18;
            }
        }

        private function initButton(target:MovieClip):void
        {
            target.buttonMode = true;
            target.mouseChildren = false;
            target.addEventListener(MouseEvent.CLICK, buttonEventHandler);
            target.addEventListener(MouseEvent.MOUSE_OVER, buttonEventHandler);
            target.addEventListener(MouseEvent.MOUSE_OUT, buttonEventHandler);
        }

        private function buttonEventHandler(event:MouseEvent):void
        {
            if (!event.target.enabled)
            {
                return;
            }

            switch (event.type)
            {
                case MouseEvent.CLICK:
                    setAlpha(event.target, 0, 0);
                    if (event.target == _appButton)
                    {
                        selectApps();
                    }
                    else
                    {
                        selectSites();
                    }
                    Hint.getInstance().hide();
                    break;
                case MouseEvent.MOUSE_OVER:
                    if (event.target == _appButton)
                    {
                        Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROCESSES_APP_HINT));
                    }
                    else
                    {
                        Hint.getInstance().show(this.stage.nativeWindow, _model.languageModel.getText(TextKeyEnum.PROCESSES_SITE_HINT));
                    }
                    setAlpha(event.target, 0.2);
                    break;
                case MouseEvent.MOUSE_OUT:
                    Hint.getInstance().hide();
                    setAlpha(event.target, 0);
                    break;
            }
        }

        private function setAlpha(target:Object, alpha:Number, time:Number = 0.5):void
        {
            if (!target.enabled)
            {
                return;
            }

            var over:MovieClip = target["over"];

            if (over)
            {
                Tweener.addTween(over, {alpha: alpha, time: time, transition: "easeOutCubic"});
            }
        }
    }
}
