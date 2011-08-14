package away3d.visualisation.axes
{

    public class XZAxisGrid extends SegmentGrid
    {
        public function XZAxisGrid( xMin:Number, yMin:Number, xMax:Number, yMax:Number )
        {
            super( xMin, yMin, xMax, yMax );
            setMajorGridLines( 50, 50, 0, 2 );
            setMinorGridLines( 10, 10, 0x88FF88 );
            showMinorLines = true;
            generateGrid();
            rotationX = 90;
        }
    }

}
