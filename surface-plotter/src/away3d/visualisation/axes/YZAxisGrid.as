package away3d.visualisation.axes
{
    public class YZAxisGrid extends SegmentGrid
    {
        public function YZAxisGrid( xMin:Number, yMin:Number, xMax:Number, yMax:Number )
        {
            super( xMin, yMin, xMax, yMax );
            setMajorGridLines( 50, 50, 0, 2 );
            setMinorGridLines( 10, 10, 0xFF8888 );
            showMinorLines = true;
            generateGrid();
            rotationY = 90;
        }
    }
}
