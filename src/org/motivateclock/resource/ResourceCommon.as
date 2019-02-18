/**
 * User: Valeriy Bashtovoy
 * Date: 23.11.13
 */
package org.motivateclock.resource
{

    public class ResourceCommon
    {
        [Embed(source="../../../../static/ui.swf", mimeType="application/octet-stream")]
        public static const UI:Class;

        [Embed(source="../../../../resources/developers.xml", mimeType="application/octet-stream")]
        public static const DEVELOPERS_INFO:Class;

        [Embed(source="../../../../resources/config.xml", mimeType="application/octet-stream")]
        public static const CONFIG:Class;

        [Embed(source="../../../../resources/links.xml", mimeType="application/octet-stream")]
        public static const LINKS:Class;
    }
}
