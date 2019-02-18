/**
 * User: Valeriy Bashtovoy
 * Date: 07.09.13
 */
package org.motivateclock.enum
{

    public class BrowserEnum
    {
        public static const OPERA_LAUNCHER:String = "launcher.exe";
        public static const OPERA:String = "opera.exe";
        public static const CHROME:String = "chrome.exe";
        public static const YANDEX:String = "browser.exe";
        public static const FIREFOX:String = "firefox.exe";
        public static const IE:String = "iexplore.exe";

        private static const BROWSERS_REGEXP:RegExp = new RegExp(OPERA_LAUNCHER + "|" + OPERA + "|" + CHROME + "|" + YANDEX + "|" + FIREFOX, "i");

        public function BrowserEnum()
        {
        }

        public static function isBrowser(path:String):Boolean
        {
            return path.search(BROWSERS_REGEXP) != -1;
        }

        public static function isInternetExplorer(path:String):Boolean
        {
            return path && path.search(new RegExp(IE)) != -1;
        }
    }
}
