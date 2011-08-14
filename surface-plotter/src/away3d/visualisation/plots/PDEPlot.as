package away3d.visualisation.plots
{

    import away3d.entities.Curve3D;
    import away3d.primitives.LineSegment;
    import away3d.visualisation.maths.IPDEGenerator;

    import flash.geom.Vector3D;

    public class PDEPlot extends Curve3D
    {

        private var _generator:IPDEGenerator;
        private var _p0:Vector3D;
        private var _lineColor:uint;

        public function PDEPlot( start:Vector3D, generator:IPDEGenerator, lineColor:uint )
        {
            super( start, lineColor, 1);
            _generator = generator;
            _lineColor = lineColor;
            _generator.p = start;
        }

        public function update( dt:Number ):void
        {
            //
            // TODO need the R3<->view mapping
            //
            var p:Vector3D = _generator.integrate( dt );
            addPoint( p, _lineColor, 1 );
        }

    }
}
