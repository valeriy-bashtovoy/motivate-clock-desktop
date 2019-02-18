/**
 * User: Valeriy Bashtovoy
 * Date: 21.12.13
 */
package org.motivateclock.controller.command
{

    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.filesystem.File;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    import org.motivateclock.Model;
    import org.motivateclock.enum.BrowserEnum;
    import org.motivateclock.enum.LinkEnum;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.model.vo.BrowserVO;

    public class InstallExtensionCommand implements ICommand
    {
        private var _browserId:String;
        private var _model:Model;

        public function InstallExtensionCommand(browserId:String, model:Model)
        {
            _browserId = browserId;
            _model = model;
        }

        public function execute():void
        {
            var browserPath:String = getBrowserPath(_browserId);
            var extensionUrl:String = "";

            switch (_browserId)
            {
                case BrowserEnum.CHROME:
                    extensionUrl = _model.languageModel.getLink(LinkEnum.CHROME_EXTENSION);
                    break;
                case BrowserEnum.YANDEX:
                case BrowserEnum.OPERA_LAUNCHER:
                    extensionUrl = _model.languageModel.getLink(LinkEnum.OPERA_EXTENSION);
                    break;
                case BrowserEnum.FIREFOX:
                    extensionUrl = _model.languageModel.getLink(LinkEnum.FIREFOX_EXTENSION);
                    break;
            }

            if (browserPath)
            {
                runBrowser(browserPath, extensionUrl);
            }
            else
            {
                navigateToURL(new URLRequest(extensionUrl));
            }
        }

        private function getBrowserPath(browserId:String):String
        {
            var browserList:Vector.<BrowserVO> = _model.browserList;

            for each (var browserVO:BrowserVO in browserList)
            {
                if (browserVO.id == browserId)
                {
                    return browserVO.path;
                }
            }

            return null;
        }

        private function runBrowser(browserPath, extensionUrl):void
        {
            var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();

            try
            {
                nativeProcessStartupInfo.executable = File.applicationDirectory.resolvePath(browserPath);
            }
            catch (error:Error)
            {
                trace(error.name + error.message);
                return;
            }

            nativeProcessStartupInfo.arguments = new <String>[extensionUrl];

            var nativeProcess:NativeProcess = new NativeProcess();
            nativeProcess.start(nativeProcessStartupInfo);
        }
    }
}
