/**
 * User: Valeriy Bashtovoy
 * Date: 14.06.2014
 */
package org.motivateclock.model
{

    import com.google.analytics.GATracker;

    import flash.display.Stage;
    import flash.events.EventDispatcher;

    import org.motivateclock.interfaces.IAnalytics;

    public class GoogleAnalytics extends EventDispatcher implements IAnalytics
    {
        private var _analytics:GATracker;
        private var _appName:String;

        public function GoogleAnalytics(account:String, appName:String, root:Stage)
        {
            _appName = appName;
            _analytics = new GATracker(root, account);
        }

        public function track(type:String, data:Object):void
        {
            var info:String = JSON.stringify(data);

            trace(this, type, info);

            _analytics.trackEvent(_appName, type, info);
        }
    }
}
