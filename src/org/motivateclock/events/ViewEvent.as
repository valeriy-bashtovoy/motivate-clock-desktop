package org.motivateclock.events
{

    import flash.events.Event;

    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Project;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ViewEvent extends Event
    {
        public static const PROCESS_ADD:String = "process_add";
        public static const PROCESS_REMOVE:String = "process_remove";

        public static const CREATE_PROJECT:String = "createProject";
        public static const SELECT_PROJECT:String = "selectProject";
        public static const REMOVE_PROJECT:String = "remove_project";
        public static const EDIT_PROJECT_NAME:String = "edit_project_name";
        public static const OPEN_PROJECT_SETTING:String = "open_project_setting";
        public static const DUPLICATE_PROJECT:String = "duplicate_project";

        public static const ALERT_CONFIRM:String = "alert_confirm";
        public static const ALERT_CANCEL:String = "alert_cancel";

        public static const SETTING_SHOW:String = "setting_show";

        public static const WINDOW_POSITION_CHANGE:String = "window_position_change";
        public static const WINDOW_SHOW:String = "window_show";
        public static const WINDOW_HIDE:String = "window_hide";

        public static const SELECT:String = "select";

        public static const INSTALL_EXTENSION:String = "install_extension";

        public static const TOAST_CLOSE:String = "toast_close";
        public static const TOAST_CLICK:String = "toast_click";

        public static const PROJECT_RESET:String = "project_reset";
        public static const EXPORT_PDF:String = "export_pdf";
        public static const EXPORT_CANCEL:String = "export_cancel";

        public var projectLabel:String;
        public var projectId:String;
        public var browserId:String;
        public var project:Project;
        public var process:IProcess;


        public function ViewEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false)
        {
            super(type, bubbles, cancelable);
        }

        override public function clone():Event
        {
            var event:ViewEvent = new ViewEvent(type, bubbles, cancelable);
            event.projectLabel = projectLabel;
            event.projectId = projectId;
            event.browserId = browserId;
            event.project = project;
            event.process = process;
            return event;
        }

    }
}
