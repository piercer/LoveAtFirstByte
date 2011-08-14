package away3d.visualisation.plots
{

    import away3d.entities.Curve3D;
    import away3d.primitives.LineSegment;
    import away3d.visualisation.maths.IParametricGenerator;

    import flash.geom.Vector3D;

    public class ParametricPlot extends Curve3D
    {

        private var _generator:IParametricGenerator;

        private var _p0:Vector3D;

        public function ParametricPlot( generator:IParametricGenerator, lineColor:uint )
        {
            var p1:Vector3D = new Vector3D( generator.x( 0 ), generator.y( 0 ), generator.z( 0 ) );
            super( p1, lineColor, 1);
            _generator = generator;
        }

        public function initialise( t0:Number ):void
        {
            update( 0 );
        }

        public function update( t:Number ):void
        {
            var p1:Vector3D = new Vector3D( _generator.x( t ), _generator.y( t ), _generator.z( t ) );
            addPoint( p1, 0x000000, 3 );
        }

    }

}
