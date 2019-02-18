package org.motivateclock.model.vo
{

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class ProcessVO
    {
        public var type:String;
        public var label:String;
        public var path:String;
        public var title:String;
        public var browserPath:String;

        public var mode:String;
        public var seconds:Number = 0;

        public function ProcessVO(type:String = "", path:String = "")
        {
            this.type = type;
            this.path = path;
        }

        public function toString():String
        {
            return type + "$" + label + "$" + path + "$" + browserPath + "\t";
        }
    }
}
