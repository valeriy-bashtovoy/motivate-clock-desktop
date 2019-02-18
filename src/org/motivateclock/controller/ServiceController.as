/**
 * User: Valeriy Bashtovoy
 * Date: 02.09.13
 */
package org.motivateclock.controller
{

    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import org.motivateclock.Model;
    import org.motivateclock.controller.command.BrowserListParseCommand;
    import org.motivateclock.enum.BrowserEnum;
    import org.motivateclock.enum.ProcessTypeEnum;
    import org.motivateclock.events.ModelEvent;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.interfaces.IService;
    import org.motivateclock.model.Process;
    import org.motivateclock.model.vo.ProcessVO;
    import org.motivateclock.services.ActiveProcessService;
    import org.motivateclock.services.BrowserExtensionService;
    import org.motivateclock.services.BrowsersService;
    import org.motivateclock.utils.URIUtil;

    public class ServiceController
    {
        private var _browserExtensionService:IService;
        private var _activeWindowService:IService;
        private var _browserVO:ProcessVO;
        private var _browsersService:BrowsersService;
        private var _model:Model;
        private var _postponeTimer:Timer;

        public function ServiceController(model:Model)
        {
            _model = model;

            initialize();
        }

        private function initialize():void
        {
            // data from extension has higher priority, then info about browser's process;
            _postponeTimer = new Timer(650, 1);
            _postponeTimer.addEventListener(TimerEvent.TIMER, postponeTimerHandler, false, 0, true);

            _browserExtensionService = new BrowserExtensionService();
            _browserExtensionService.initializeHandlers(browserServiceDataHandler);
            _browserExtensionService.initialize();

            _activeWindowService = new ActiveProcessService(_model);
            _activeWindowService.initializeHandlers(activeWindowDataHandler);
            _activeWindowService.initialize();

            _browsersService = new BrowsersService();
            _browsersService.initializeHandlers(installedBrowserHandler);
            _browsersService.initialize();

            _model.applicationManager.addEventListener(ModelEvent.APPLICATION_EXITING, application_exitingHandler);
        }

        private function installedBrowserHandler(data:String):void
        {
            var command:ICommand = new BrowserListParseCommand(_model, data);
            command.execute();
        }

        private function browserServiceDataHandler(data:String):void
        {
            _postponeTimer.stop();

            if (!data)
            {
                return;
            }

            var dataJson:Object;

            try
            {
                dataJson = JSON.parse(data);
            }
            catch (e:Error)
            {
            }

            if (!dataJson)
            {
                return;
            }

            var processVO:ProcessVO = new ProcessVO();
            processVO.path = URIUtil.getDomainFromURI(dataJson.url);
            processVO.label = processVO.path;
            processVO.title = dataJson.title;
            processVO.type = ProcessTypeEnum.SITE;
            processVO.browserPath = _browserVO ? _browserVO.path : "";

            updateCurrentProcess(processVO);
        }

        public function activeWindowDataHandler(processVO:ProcessVO):void
        {
            _postponeTimer.stop();

            if (BrowserEnum.isBrowser(processVO.path))
            {
                _browserVO = processVO;
                _postponeTimer.start();
                return;
            }

            updateCurrentProcess(processVO);
        }

        private function postponeTimerHandler(event:TimerEvent):void
        {
            updateCurrentProcess(_browserVO);
        }

        private function application_exitingHandler(event:ModelEvent):void
        {
            if (!_browserExtensionService)
            {
                return;
            }

            _browserExtensionService.dispose();
            _activeWindowService.dispose();
            _browsersService.dispose();
        }

        private function updateCurrentProcess(processVO:ProcessVO):void
        {
            _model.updateCurrentProcess(Process.convert(processVO));
        }
    }
}
