package away3d.visualisation.maths
{

    import flash.geom.Vector3D;

    public interface IPDEGenerator
    {
        function set p( p:Vector3D ):void;
        function get p():Vector3D;
        function integrate( dt:Number ):Vector3D;
    }

}
