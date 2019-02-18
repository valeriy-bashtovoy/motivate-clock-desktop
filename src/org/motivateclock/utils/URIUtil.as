package org.motivateclock.utils
{

    /**
     * @author: Valeriy Bashtovoy
     *
     */
    public class URIUtil
    {

        [Inline]
        public static function getSchemeFromURI(uri:String):String
        {
            return "http://";
        }

        [Inline]
        public static function getDomainFromURI(uri:String):String
        {
            //trace("uri:", uri);

            var schemeFile:String = "file";

            /**
             * source: http://org.wikipedia.org/wiki/URI
             * original regexp: (/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)
             *
             * group 1: scheme with ":" (http:);
             * group 2: scheme (http);
             * group 3: path (//www.site.com/pub/ietf/uri/);
             * group 4: www.
             * group 5: source (site.com);
             * group 6: query (/pub/ietf/uri/);
             */
            var uriGroupCollection:Array = unescape(uri).match(/^(([^:\/?]+):)?(\/*(w{3}\.)*([^\/*]*)([^\?|\#]*))?/i);
            /**/

            var domain:String = uriGroupCollection[5];
            var scheme:String = uriGroupCollection[1];

            // join source and query, if the scheme of URI is "FILE";
            if (uriGroupCollection[2] == schemeFile)
            {
                domain += uriGroupCollection[6];
            }

            if (scheme && domain.search(/\W/i) == -1)
            {
                domain = uriGroupCollection[1] + uriGroupCollection[3];
            }

            // replace all Cyrillic symbols with some English character;
            var temp:String = domain.replace(/[\u0410-\u0451]/ig, "z");

            /**
             * remove domain name, when it has
             * spaces or some punctuation characters
             * (because it looks like search query);
             */
            domain = (domain.search(/\s/ig) != -1) ? "" : domain; // || (temp.search(/\w+\W+\w+/i) == -1)

//			trace("domain:", domain);

            return domain.toLocaleLowerCase();
        }

    }
}
