package away3d.visualisation.axes
{

    import away3d.entities.SegmentSet;
    import away3d.primitives.LineSegment;

    import flash.geom.Vector3D;

    public class SegmentGrid extends SegmentSet
    {

        private var _xMin:Number;
        private var _yMin:Number;
        private var _xMax:Number;
        private var _yMax:Number;
        private var _xMajorSnap:Number;
        private var _yMajorSnap:Number;
        private var _majorColor:uint;
        private var _majorThickness:Number;

        private var _showTicks:Boolean;
        private var _showMinorLines:Boolean;
        private var _xMinorSnap:Number;
        private var _yMinorSnap:Number;
        private var _minorColor:uint;
        private var _minorThickness:uint;

        public function SegmentGrid( xMin:Number, yMin:Number, xMax:Number, yMax:Number )
        {
            _xMin = xMin;
            _yMin = yMin;
            _xMax = xMax;
            _yMax = yMax;
            _xMajorSnap = 1;
            _yMajorSnap = 1;
            _majorThickness = 1;
            _majorColor = 0;
        }

        public function setMajorGridLines( xMajorSnap:Number, yMajorSnap:Number, majorColor:uint = 0, majorThickness:uint = 1):void
        {
            _xMajorSnap = xMajorSnap;
            _yMajorSnap = yMajorSnap;
            _majorColor = majorColor;
            _majorThickness = majorThickness;
        }

        public function setMinorGridLines( xMinorSnap:Number, yMinorSnap:Number, minorColor:uint = 0, minorThickness:uint = 1):void
        {
            _xMinorSnap = xMinorSnap;
            _yMinorSnap = yMinorSnap;
            _minorColor = minorColor;
            _minorThickness = minorThickness;
        }

        public function generateGrid():void
        {

            clearSegments();

            var firstMajorX:Number = ( _xMin % _xMajorSnap == 0 ) ? _xMin : Math.floor( _xMin / _xMajorSnap ) * ( _xMajorSnap + 1);
            var firstMajorY:Number = ( _yMin % _yMajorSnap == 0 ) ? _yMin : Math.floor( _yMin / _yMajorSnap ) * ( _yMajorSnap + 1);
            var firstMinorX:Number = ( _xMin % _xMinorSnap == 0 ) ? _xMin : Math.floor( _xMin / _xMinorSnap ) * ( _xMinorSnap + 1);
            var firstMinorY:Number = ( _yMin % _yMinorSnap == 0 ) ? _yMin : Math.floor( _yMin / _yMinorSnap ) * ( _yMinorSnap + 1);

            var xLine:Number = firstMinorX;
            var yLine:Number = firstMinorY;

            if ( _showMinorLines )
            {
                while ( xLine <= _xMax )
                {
                    addSegment( new LineSegment( new Vector3D( xLine, _yMin, 0 ), new Vector3D( xLine, _yMax, 0 ), _minorColor, _minorColor, _minorThickness ) );
                    xLine += _xMinorSnap;
                }

                while ( yLine <= _yMax )
                {
                    addSegment( new LineSegment( new Vector3D( _xMin, yLine, 0 ), new Vector3D( _xMax, yLine, 0 ), _minorColor, _minorColor, _minorThickness ) );
                    yLine += _yMinorSnap;
                }
            }

            xLine = firstMajorX;
            yLine = firstMajorY;

            while ( xLine <= _xMax )
            {
                addSegment( new LineSegment( new Vector3D( xLine, _yMin, 0 ), new Vector3D( xLine, _yMax, 0 ), _majorColor, _majorColor, _majorThickness ) );
                xLine += _xMajorSnap;
            }

            while ( yLine <= _yMax )
            {
                addSegment( new LineSegment( new Vector3D( _xMin, yLine, 0 ), new Vector3D( _xMax, yLine, 0 ), _majorColor, _majorColor, _majorThickness ) );
                yLine += _yMajorSnap;
            }

        }

        public function get showMinorLines():Boolean
        {
            return _showMinorLines;
        }

        public function set showMinorLines( value:Boolean ):void
        {
            _showMinorLines = value;
        }
    }
}
