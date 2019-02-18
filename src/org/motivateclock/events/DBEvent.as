package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.interfaces.IProcess;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class DBEvent extends Event
    {

        public static const DB_COMPLETE:String = "db_complete";
        public static const DB_PROJECT_LIST_LOADED:String = "db_project_list_loaded";
        public static const DB_PROJECT_ADDED:String = "db_project_added";

        public static const DB_PROCESS_SYNC_COMPLETE:String = "db_process_sync_complete";
        public static const DB_PROCESS_SYNC_ERROR:String = "db_process_sync_error";

        public static const DB_PROCESSES_LOAD_COMPLETE:String = "db_processes_load_complete";
        public static const DB_PROJECT_TIME_LOAD_COMPLETE:String = "db_project_time_load_complete";
        public static const DB_PROCESSES_TIME_LOAD_COMPLETE:String = "db_processes_time_load_complete";

        public static const DB_STATISTICS_LOAD_COMPLETE:String = "db_statistics_load_complete";

        public var projectId:String = "";
        public var processList:Vector.<IProcess>;
        public var projectTime:Number = 0;
        public var processesTime:Number = 0;

        public function DBEvent(type:String, projectId:String = "")
        {
            this.projectId = projectId;

            super(type, false, false);
        }
    }
}
