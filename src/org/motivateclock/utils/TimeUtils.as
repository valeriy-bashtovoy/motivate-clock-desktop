package org.motivateclock.utils
{

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class TimeUtils extends Object
    {

        public static var monthsCollection:Array = [];
        private static var daysInMonth:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

        public function TimeUtils()
        {
        }

        public static function getNumDayInMonth(year:int, monthIndex:int):int
        {
            var dayNum:int = daysInMonth[monthIndex];
            var date:Date;

            if (monthIndex == 1)
            {
                date = new Date(year, monthIndex, 29);
                if (date.getMonth() == 1)
                {
                    dayNum = 29;
                }
            }

            return dayNum;
        }

        public static function getMonthNameByIndex(index:int):String
        {
            return monthsCollection[index];
        }

        [Inline]
        public static function convertSeconds(seconds:Number, workingHours:int = 24):Object
        {
            var minInHour:Number = 60;
            var secInHour:Number = 3600;
            var secInDay:Number = secInHour * workingHours;

            var date:Object = {};

            date.day = Math.floor(seconds / secInDay);
            date.hour = setDoubleFormat(int((seconds % secInDay) / secInHour));
            date.min = setDoubleFormat(int((seconds % secInHour) / minInHour));
            date.sec = setDoubleFormat(int(seconds % minInHour));

            return date;
        }

        [Inline]
        public static function setDoubleFormat(value:Number):String
        {
            var s:String = "";

            if (value < 10)
            {
                s += "0";
            }

            s += value;

            return s;
        }

        public static function getDeclensionNumberName(number:int, nameCollection:Array):String
        {
            for (var i:int = 0; i < 3; i++)
            {
                if (!nameCollection[i])
                {
                    nameCollection[i] = nameCollection[0];
                }
            }

            var n1:int = number % 100;
            var n2:int = n1 % 10;

            if (n1 > 10 && n1 < 20)
            {
                return nameCollection[2];
            }

            if (n2 > 1 && n2 < 5)
            {
                return nameCollection[1];
            }

            if (n2 == 1)
            {
                return nameCollection[0];
            }

            return nameCollection[2];
        }
    }
}
