package away3d.visualisation.maths
{
    public interface IParametricGenerator
    {
        function x( t:Number ):Number;

        function y( t:Number ):Number;

        function z( t:Number ):Number;
    }
}
