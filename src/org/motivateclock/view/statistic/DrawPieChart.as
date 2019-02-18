package org.motivateclock.view.statistic
{

    import flash.display.Shape;

    public class DrawPieChart
    {

        private static var CONVERT_TO_RADIANS:Number = Math.PI / 180;

        public function DrawPieChart()
        {
        }

        public static function drawChart(_shape:Shape, _radius:Number, _percent:Number, _colour:uint = 0xFF0000, _rotationOffset:Number = 0, thickness:Number = 0, lineColor:uint = 0x000000):void
        {
            if (_percent > 1)
            {
                _percent = 1;
            }

            var angle:Number = 360 * _percent;
            var lineAlpha:Number = 1;

            thickness = 0.1;

            _shape.graphics.clear();
            _shape.graphics.lineStyle(thickness, lineColor, lineAlpha);
            _shape.graphics.moveTo(0, 0);
            _shape.graphics.beginFill(_colour, 100);
            _shape.graphics.lineTo(_radius, 0);
            _shape.rotation = _rotationOffset;

            var nSeg:Number = Math.floor(angle / 30);
            var pSeg:Number = angle - nSeg * 30;
            var a:Number = 0.268;

            for (var i:int = 0; i < nSeg; i++)
            {
                var endx:Number = _radius * Math.cos((i + 1) * 30 * CONVERT_TO_RADIANS);
                var endy:Number = _radius * Math.sin((i + 1) * 30 * CONVERT_TO_RADIANS);
                var ax:Number = endx + _radius * a * Math.cos(((i + 1) * 30 - 90) * CONVERT_TO_RADIANS);
                var ay:Number = endy + _radius * a * Math.sin(((i + 1) * 30 - 90) * CONVERT_TO_RADIANS);
                _shape.graphics.curveTo(ax, ay, endx, endy);
            }

            if (pSeg > 0)
            {
                a = Math.tan(pSeg / 2 * CONVERT_TO_RADIANS);
                endx = _radius * Math.cos((i * 30 + pSeg) * CONVERT_TO_RADIANS);
                endy = _radius * Math.sin((i * 30 + pSeg) * CONVERT_TO_RADIANS);
                ax = endx + _radius * a * Math.cos((i * 30 + pSeg - 90) * CONVERT_TO_RADIANS);
                ay = endy + _radius * a * Math.sin((i * 30 + pSeg - 90) * CONVERT_TO_RADIANS);
                _shape.graphics.curveTo(ax, ay, endx, endy);
            }
        }
    }
}
