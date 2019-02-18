/**
 * User: Valeriy Bashtovoy
 * Date: 10.09.13
 */
package org.motivateclock.model.vo
{

    public class BrowserVO
    {
        public var label:String;
        public var path:String;
        public var id:String;

        public function BrowserVO(id:String, label:String, path:String)
        {
            this.id = id;
            this.label = label;
            this.path = path;
        }

        public function toString():Object
        {
            return "id: " + id + ", label: " + label + ", path: " + path;
        }
    }
}
