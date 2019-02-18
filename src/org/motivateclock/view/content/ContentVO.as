package org.motivateclock.view.content
{

    /**
     * @author: Valeriy Bashtovoy
     *
     *
     */
    public class ContentVO extends Object
    {

        public var label:String;
        public var icon:String;
        public var hint:String;
        public var content:Class;

        public function ContentVO()
        {
        }

        public function toString():String
        {
            return label + " " + icon + " " + hint + " " + content + "\t";
        }
    }
}
