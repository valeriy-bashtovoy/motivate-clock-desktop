package org.motivateclock.model.statistic
{

    import flash.data.SQLConnection;
    import flash.data.SQLMode;
    import flash.data.SQLResult;
    import flash.data.SQLStatement;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.SQLErrorEvent;
    import flash.events.SQLEvent;
    import flash.filesystem.File;

    import org.motivateclock.enum.TypeEnum;
    import org.motivateclock.events.DBEvent;
    import org.motivateclock.events.McEvent;
    import org.motivateclock.interfaces.IProcess;
    import org.motivateclock.model.Process;
    import org.motivateclock.model.Project;

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class DataBase extends EventDispatcher
    {

        public static const INSERT_COMPLETE:String = "insertComplete";
        public static const PROJECT_UPDATED:String = "projectUpdated";

        private static var instance:DataBase;
        private static var isSingleton:Boolean = false;

        private var _sqlConnection:SQLConnection;
        private var _isReady:Boolean = false;

        public static function getInstance():DataBase
        {
            if (!instance)
            {
                isSingleton = true;
                instance = new DataBase();
                isSingleton = false;
            }

            return instance;
        }

        public function DataBase()
        {
            if (!isSingleton)
            {
                throw new Error("Error: " + this + "is singletone, use getInstance();");
            }
        }

        public function initialize():void
        {
            var file:File = File.applicationStorageDirectory.resolvePath("statistic.db");

            _sqlConnection = new SQLConnection();
            _sqlConnection.addEventListener(SQLEvent.OPEN, openHandler);
            _sqlConnection.openAsync(file, SQLMode.CREATE);
        }

        public function get isReady():Boolean
        {
            return _isReady;
        }

        private function openHandler(event:SQLEvent):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.sqlConnection = _sqlConnection;
            // sql.text = 'DROP TABLE IF EXISTS statistic';
            sql.text = "CREATE TABLE IF NOT EXISTS statistic(id INTEGER PRIMARY KEY AUTOINCREMENT, projectId TEXT, usedDate DATE, appPath TEXT, appName TEXT, time INTEGER)";
            sql.execute();
            //
            sql = new SQLStatement();
            sql.sqlConnection = _sqlConnection;
            sql.text = "CREATE TABLE IF NOT EXISTS projects(id INTEGER PRIMARY KEY AUTOINCREMENT, projectId TEXT, name TEXT, creationDate DATE, isCurrent INTEGER, workTime INTEGER, restTime INTEGER, isAuto INTEGER, applications TEXT)";
            sql.execute();

            _isReady = true;

            dispatchEvent(new McEvent(McEvent.DB_LOADED));
        }

        public function getProjects():void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, sqlResultHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "SELECT projectId as id, name, creationDate, isAuto, isCurrent, workTime, restTime, applications FROM projects";
            sql.itemClass = Project;
            sql.execute();

            function sqlResultHandler(event:SQLEvent):void
            {
                var e:McEvent = new McEvent(McEvent.PROJECTS_OBTAINED);
                e.result = SQLStatement(event.target).getResult().data;
                if (!e.result)
                {
                    e.result = [];
                }
                dispatchEvent(e);
            }
        }

        public function removeProject(id:String):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLErrorEvent.ERROR, errorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "DELETE FROM projects WHERE projectId = @id";
            sql.parameters["@id"] = id;
            sql.execute();

            function errorHandler(event:SQLErrorEvent):void
            {
            }
        }

        public function addProject(project:Project):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, resultHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, errorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "INSERT INTO projects(projectId, name, creationDate, workTime, restTime, applications, isCurrent) VALUES(@id, @name, @date, @workTime, @restTime, @apps, @isCurrent)";
            sql.parameters["@id"] = project.id;
            sql.parameters["@name"] = project.name;
            sql.parameters["@date"] = project.creationDate;
            sql.parameters["@workTime"] = project.workTime;
            sql.parameters["@restTime"] = project.restTime;
            sql.parameters["@apps"] = project.applications;
            sql.parameters["@isCurrent"] = project.isCurrent;

            sql.execute();

            function errorHandler(event:SQLErrorEvent):void
            {
                dispatchEvent(new Event(DataBase.INSERT_COMPLETE));
            }

            function resultHandler(event:SQLEvent):void
            {
                dispatchEvent(new Event(DataBase.INSERT_COMPLETE));
            }
        }

        public function updateProject(project:Project):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, resultHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, errorHandler);
            sql.sqlConnection = _sqlConnection;

            sql.text = "UPDATE projects SET name = @name, creationDate = @date, workTime = @work, restTime = @rest, applications = @apps, isCurrent = @isCurrent WHERE projectId = @id";
            sql.parameters["@id"] = project.id;
            sql.parameters["@name"] = project.name;
            sql.parameters["@date"] = project.creationDate;

            sql.parameters["@work"] = int(project.workTime);
            sql.parameters["@rest"] = int(project.restTime);

            sql.parameters["@apps"] = project.applications;
            sql.parameters["@isCurrent"] = project.isCurrent;

            sql.execute();

            function resultHandler(event:SQLEvent):void
            {
                dispatchEvent(new Event(DataBase.PROJECT_UPDATED));
            }

            function errorHandler(event:SQLErrorEvent):void
            {
                dispatchEvent(new Event(DataBase.PROJECT_UPDATED));
            }
        }

        public function syncProcess(project_id:String, used_date:String, app_path:String, app_name:String, time:int):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, syncSelectCompleteHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, syncProcessErrorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "SELECT id, time FROM statistic WHERE projectId = @id AND usedDate = @used_date AND appPath = @app_path AND appName = @app_name";
            sql.parameters["@id"] = project_id;
            sql.parameters["@used_date"] = new Date(used_date);
            sql.parameters["@app_path"] = app_path;
            sql.parameters["@app_name"] = app_name;
            sql.execute();

            function syncSelectCompleteHandler(event:SQLEvent):void
            {
                var result:SQLResult = SQLStatement(event.target).getResult();

                if (!result.data)
                {
                    addProcess(project_id, used_date, app_path, app_name, time);
                    return;
                }

                var item:Object = result.data[0];

                updateProcess(item.id, item.time + time);
            }
        }

        private function syncProcessErrorHandler(event:SQLErrorEvent):void
        {
            dispatchEvent(new DBEvent(DBEvent.DB_PROCESS_SYNC_ERROR));
        }

        private function updateProcess(id:Number, time:int):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, syncProcessCompleteHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, syncProcessErrorHandler);
            sql.sqlConnection = _sqlConnection;

            sql.text = "UPDATE statistic SET time = @time WHERE id = @id";
            sql.parameters["@id"] = id;
            sql.parameters["@time"] = time;

            sql.execute();
        }

        private function addProcess(project_id:String, used_date:String, app_path:String, app_name:String, time:int):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, syncProcessCompleteHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, syncProcessErrorHandler);
            sql.sqlConnection = _sqlConnection;

            sql.text = "INSERT INTO statistic(projectId, usedDate, appPath, appName, time) VALUES(@id, @used_date, @app_path, @app_name, @time)";
            sql.parameters["@id"] = project_id;
            sql.parameters["@used_date"] = new Date(used_date);
            sql.parameters["@app_path"] = app_path;
            sql.parameters["@app_name"] = app_name;
            sql.parameters["@time"] = time;

            sql.execute();
        }

        private function syncProcessCompleteHandler(event:SQLEvent):void
        {
            dispatchEvent(new DBEvent(DBEvent.DB_PROCESS_SYNC_COMPLETE));
        }

        public function loadProcesses(projectId:String):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, projectProcessesHandler);
            sql.sqlConnection = _sqlConnection;
            // TODO should be grouped by time, if it's possible;
            sql.text = "SELECT appName as name, appPath as path, total(time) as time FROM statistic WHERE projectId = @id GROUP BY appPath";
            sql.parameters["@id"] = projectId;
            sql.itemClass = Process;
            sql.execute();
        }

        public function getProjectTime(projectId:String):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, projectTimeHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "SELECT total(time) as time FROM statistic WHERE projectId = @id";
            sql.parameters["@id"] = projectId;
            sql.execute();
        }

        private function projectTimeHandler(event:SQLEvent):void
        {
            var result:SQLResult = SQLStatement(event.target).getResult();
            var projectId:String = SQLStatement(event.target).parameters["@id"];
            var dbEvent:DBEvent = new DBEvent(DBEvent.DB_PROJECT_TIME_LOAD_COMPLETE, projectId);

            if (result.data)
            {
                dbEvent.projectTime = Number(result.data[0].time);
                trace(this, "projectTime", dbEvent.projectTime);
                dispatchEvent(dbEvent);
            }
        }

        private function convertList2QueryList(processList:Vector.<IProcess>):String
        {
            if (!processList)
            {
                return '';
            }

            return "'" + processList.join("', '") + "'";
        }

        public function getProcessesTime(projectId:String, processList:Vector.<IProcess>):void
        {
            var query:String = "SELECT total(time) as time FROM statistic WHERE projectId = @id AND appPath IN (" +
                                convertList2QueryList(processList) +
                                ")";

            trace(this, "getProcessesTime(), query:", query);

            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, processesTimeHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = query;
            sql.parameters["@id"] = projectId;
            sql.execute();
        }

        private function processesTimeHandler(event:SQLEvent):void
        {
            var result:SQLResult = SQLStatement(event.target).getResult();
            var projectId:String = SQLStatement(event.target).parameters["@id"];
            var dbEvent:DBEvent = new DBEvent(DBEvent.DB_PROCESSES_TIME_LOAD_COMPLETE, projectId);

            if (result.data)
            {
                dbEvent.processesTime = Number(result.data[0].time);
                trace(this, "processesTime", dbEvent.processesTime);
                dispatchEvent(dbEvent);
            }
        }

        private function projectProcessesHandler(event:SQLEvent):void
        {
            var result:SQLResult = SQLStatement(event.target).getResult();

            var dbEvent:DBEvent = new DBEvent(DBEvent.DB_PROCESSES_LOAD_COMPLETE);
            dbEvent.projectId = SQLStatement(event.target).parameters["@id"];

            if (result.data)
            {
                dbEvent.processList = Vector.<IProcess>(result.data);
            }

            dispatchEvent(dbEvent);
        }

        public function getStatistics(projectId:String, category:String = "", range:String = "", processList:Vector.<IProcess> = null):void
        {
            trace(this, "getStatistics(), arguments:", arguments);

            var query:String = "SELECT appPath as path, appName as name, total(time) as time FROM statistic WHERE projectId = @id";

            if (category && processList && processList.length > 0)
            {
                query += " AND appPath" + (category == TypeEnum.WORK ? "" : " NOT") + " IN (" + convertList2QueryList(processList) + ")";
            }

            query += " GROUP BY appPath";

            trace(this, "getStatistics(), query:", query);

            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, statisticsResultHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = query;//"SELECT appPath as path, appName as name, total(time) as time FROM statistic WHERE projectId = @id GROUP BY appPath";
            sql.parameters["@id"] = projectId;
            sql.itemClass = Process;
            sql.execute();
        }

        private function statisticsResultHandler(event:SQLEvent):void
        {
            var result:SQLResult = SQLStatement(event.target).getResult();

            var dbEvent:DBEvent = new DBEvent(DBEvent.DB_STATISTICS_LOAD_COMPLETE);
            dbEvent.projectId = SQLStatement(event.target).parameters["@id"];

            if (result.data)
            {
                dbEvent.processList = Vector.<IProcess>(result.data);
            }

            dispatchEvent(dbEvent);
        }

        public function getStatisticsByDay(id:String):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, resultsByDayHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "SELECT appName, STRFTIME('%Y-%m-%d', usedDate) AS usedDate, total(time) as time, appPath FROM statistic WHERE projectId = @id GROUP BY usedDate, appName";
            sql.parameters["@id"] = id;
            sql.execute();
        }

        private function resultsByDayHandler(event:SQLEvent):void
        {
            var result:SQLResult = SQLStatement(event.target).getResult();
            var itemsCollection:Array = result.data;

            var e:McEvent = new McEvent(McEvent.STATISTIC_BY_DAY_OBTAINED);
            e.result = itemsCollection;
            dispatchEvent(e);
        }

        private function sqlErrorHandler(event:SQLErrorEvent):void
        {
            trace("DataBase: " + event.error);
        }

        public function resetProjectStatistic(id:String):void
        {
            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "DELETE FROM statistic " + "WHERE projectId = @id";
            sql.parameters["@id"] = id;
            sql.execute();
        }

        public function getStatisticsByDate(startDate:Date, endDate:Date, projectId:String):void
        {
            //trace(this, "getStatisticsByDate, startDate:", startDate.toDateString(), "endDate:", endDate.toDateString());

            var sql:SQLStatement = new SQLStatement();
            sql.addEventListener(SQLEvent.RESULT, sqlResultHandler);
            sql.addEventListener(SQLErrorEvent.ERROR, sqlErrorHandler);
            sql.sqlConnection = _sqlConnection;
            sql.text = "SELECT appName, total(time) AS time, usedDate, appPath FROM statistic WHERE projectId = @id AND STRFTIME('%Y-%m-%d', usedDate) BETWEEN STRFTIME('%Y-%m-%d', @startDate) AND STRFTIME('%Y-%m-%d', @endDate) GROUP BY appPath";
            sql.parameters["@id"] = projectId;
            sql.parameters["@startDate"] = startDate;
            sql.parameters["@endDate"] = endDate;
            sql.execute();

            function sqlResultHandler(event:SQLEvent):void
            {
            }
        }
    }
}
