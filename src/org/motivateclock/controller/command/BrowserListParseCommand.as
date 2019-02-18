/**
 * User: Valeriy Bashtovoy
 * Date: 08.09.13
 */
package org.motivateclock.controller.command
{

    import flash.filesystem.File;
    import flash.utils.Dictionary;

    import org.motivateclock.Model;
    import org.motivateclock.interfaces.ICommand;
    import org.motivateclock.model.vo.BrowserVO;

    public class BrowserListParseCommand implements ICommand
    {
        private static const BROWSER_NAME_INDEX:int = 1;
        private static const BROWSER_PATH_INDEX:int = 2;

        private var _data:String;
        private var _model:Model;
        private var _browserDictionary:Dictionary = new Dictionary();

        public function BrowserListParseCommand(model:Model, data:String)
        {
            _model = model;
            _data = data;
        }

        public function execute():void
        {
            var browserList:Vector.<BrowserVO> = new <BrowserVO>[];
            var browserDataList:Array = _data.split("\n");
            var browserInfo:Array;
            var file:File;
            var browserVO:BrowserVO;
            var nativePath:String;

            for each(var data:String in browserDataList)
            {
                data = data.replace(/\r|"/ig, "");

                if (!data)
                {
                    continue;
                }

                browserInfo = data.split("|");
                nativePath = browserInfo[BROWSER_PATH_INDEX];

                //trace("browserInfo", browserInfo);

                if (!nativePath)
                    continue;

                file = new File(nativePath);

                if (!file.exists)
                    continue;

                browserVO = new BrowserVO(file.name.toLowerCase(), browserInfo[BROWSER_NAME_INDEX], file.nativePath);

                // remove similar browsers;
                if (_browserDictionary[browserVO.id])
                {
                    continue;
                }

                _browserDictionary[browserVO.id] = true;

                browserList.push(browserVO);

                //trace("browserVO:", browserVO);
            }

            _model.browserList = browserList;
        }
    }
}
