package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.interfaces.IProcess;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ModelEvent extends Event
    {
        public static const STAT_LIST_CHANGE:String = "stat_list_change";

        public static const PROJECT_LIST_CHANGE:String = "project_list_change";
        public static const PROJECT_CHANGE:String = "project_change";
        public static const PROJECT_NAME_CHANGE:String = "project_name_change";
        public static const PROJECT_TIME_CHANGE:String = "project_time_change";
        public static const PROJECT_SAVE_COMPLETE:String = "project_save_complete";
        public static const PROJECT_SYNC_COMPLETE:String = "project_sync_complete";
        public static const PROJECT_MODE_CHANGE:String = "project_mode_change";

        public static const NEW_PROCESS_READY:String = "new_process_ready";

        public static const PROCESS_CHANGE:String = "process_change";
        public static const PROCESS_ADD:String = "process_add";
        public static const PROCESS_REMOVE:String = "process_remove";
        public static const PROCESS_SYNC_STATE_CHANGE:String = "process_sync_state_change";
        public static const PROCESS_TIME_CHANGE:String = "process_time_change";

        public static const CLOCK_TICK:String = "clock_tick";

        public static const APPLICATION_EXITING:String = "application_exiting";
        public static const APPLICATION_HEIGHT_CHANGE:String = "application_height_change";

        public static const SAVE_TIMER:String = "save_timer";

        public static const COLOR_TONE_CHANGE:String = "color_tone_change";

        public static const SETTING_CHANGE:String = "setting_change";
        public static const SETTING_COMPLETE:String = "setting_complete";

        public static const BROWSER_LIST_CHANGE:String = "browser_list_change";
        public static const PROJECT_HELP_TEXT_CHANGE:String = "project_help_text_change";

        public static const INITIALIZE_STATE_CHANGE:String = "initialize_state_change";

        public static const TYPE_CHANGE:String = "type_change";

        public static const APP_PENDING_CHANGE:String = "app_pending_change";
        public static const USER_IDLE_STATE_CHANGE:String = "user_idle_state_change";
        public static const UPDATE_AVAILABLE:String = "update_available";

        public var projectId:int;
        public var process:IProcess;
        public var propertyKey:String;

        public var isEmergency:Boolean = false;

        // time range in milliseconds is divided on 1000, example: 1.73;
        public var timeRange:Number;

        public function ModelEvent(type:String)
        {
            super(type, true, false);
        }
    }
}
