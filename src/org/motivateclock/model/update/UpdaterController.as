package org.motivateclock.model.update
{

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.UpdateHelpTextCommand;
    import org.motivateclock.events.DateWatcherEvent;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.model.ToastManager;
    import org.motivateclock.utils.DateWatcher;
    import org.motivateclock.utils.RegularUtils;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class UpdaterController extends Object
    {
        private var _loader:URLLoader;
        private var _model:Model;
        private var _request:URLRequest;
        private var _isLoading:Boolean = false;

        public function UpdaterController(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            _request = new URLRequest(_model.config.UPDATE.@URL);
            _request.method = URLRequestMethod.POST;

            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler, false, 0, true);

            DateWatcher.getInstance().addEventListener(DateWatcherEvent.CHANGE, dateChangeHandler);

            _model.updaterModel.addEventListener(ModelEvent.UPDATE_AVAILABLE, model_update_availableHandler);

            load();
        }

        private function model_update_availableHandler(event:ModelEvent):void
        {
            RegularUtils.callFunctionWithDelay(_model.toastManager.show, 60 * 1000, [ToastManager.UPDATE, 60]);

            new UpdateHelpTextCommand(_model).execute();
        }

        private function dateChangeHandler(event:DateWatcherEvent):void
        {
            load();
        }

        private function load():void
        {
            if (_isLoading)
            {
                return;
            }

            trace(this, "Load update info:", _request.url);

            _isLoading = true;

            _loader.load(_request);
        }

        private function loadErrorHandler(event:IOErrorEvent):void
        {
            _isLoading = false;
        }

        private function completeHandler(event:Event):void
        {
            _isLoading = false;

            var descriptor:XML = new XML(_loader.data);

            if (descriptor == "")
            {
                return;
            }

            var ns:Namespace = descriptor.namespace();

            _model.updaterModel.setUpdateInfo(descriptor.ns::versionNumber, descriptor.ns::versionLabel, descriptor.ns::url, descriptor.ns::description);
        }
    }
}
