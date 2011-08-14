package away3d.visualisation.axes
{

    public class XYAxisGrid extends SegmentGrid
    {
        public function XYAxisGrid( xMin:Number, yMin:Number, xMax:Number, yMax:Number )
        {
            super( xMin, yMin, xMax, yMax );
            setMajorGridLines( 50, 50, 0, 2 );
            setMinorGridLines( 10, 10, 0x888888 );
            showMinorLines = true;
            generateGrid();
        }
    }

}
