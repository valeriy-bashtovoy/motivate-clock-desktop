package org.motivateclock.model.settings
{

    import flash.desktop.NativeApplication;
    import flash.net.registerClassAlias;

    import org.motivateclock.enum.TypeEnum;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class Settings
    {

        registerClassAlias("SettingsAlias", Settings);

        public var restState:Boolean = false;
        public var workState:Boolean = false;
        public var mainWindowState:Object;
        public var alwaysInFront:Boolean = true;
        public var language:String = "";
        public var closeToTray:Boolean = true;
        public var restTime:Number = 30;
        public var workTime:Number = 50;
        public var soundEnabled:Boolean = false;
        public var version:int;
        public var idleTarget:String = TypeEnum.IDLE;
        public var versionNumber:String = "";
        public var exportRestStat:Boolean = true;
        public var workingHours:Number = 24; //hour;
        public var colorTone:int = 0;

        private var _idleState:Boolean = true;
        private var _appHeight:int = 517;

        public function Settings()
        {
        }

        public function set autorun(value:Boolean):void
        {
            try
            {
                NativeApplication.nativeApplication.startAtLogin = value;
            }
            catch (error:Error)
            {
            }
        }

        public function get autorun():Boolean
        {
            var autorun:Boolean = true;

            try
            {
                autorun = NativeApplication.nativeApplication.startAtLogin;
            }
            catch (error:Error)
            {
            }

            return autorun;
        }

        public function set idleTime(value:Number):void
        {
            NativeApplication.nativeApplication.idleThreshold = value * 60;
        }

        public function get idleTime():Number
        {
            return NativeApplication.nativeApplication.idleThreshold / 60;
        }

        public function get idleState():Boolean
        {
            return _idleState;
        }

        public function set idleState(value:Boolean):void
        {
        }

        public function get appHeight():int
        {
            return _appHeight;
        }

        public function set appHeight(value:int):void
        {
        }
    }
}
