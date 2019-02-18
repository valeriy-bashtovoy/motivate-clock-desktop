/**
 * User: Valeriy Bashtovoy
 * Date: 16.01.14
 */
package org.motivateclock.controller.command
{

    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.text.Font;

    import org.motivateclock.Model;
    import org.motivateclock.enum.StateEnum;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.resource.ResourceCommon;

    public class InitializeUICommand implements ICommand
    {
        private var _view:DisplayObject;
        private var _model:Model;

        public function InitializeUICommand(model:Model, view:DisplayObject)
        {
            _model = model;
            _view = view;
        }

        public function execute():void
        {
            var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
            context.allowCodeImport = true;

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            _view.stage.addChild(loader);
            loader.loadBytes(new ResourceCommon.UI(), context);
        }

        private function completeHandler(event:Event):void
        {
            registerFonts(event.target.applicationDomain);

            _model.initializeState = StateEnum.INITIALIZE_UI_COMPLETE;
        }

        private function registerFonts(applicationDomain:ApplicationDomain):void
        {
            var MyriadProSemibold:Class = applicationDomain.getDefinition("MyriadProSemibold") as Class;
            Font.registerFont(MyriadProSemibold);

        }
    }
}
