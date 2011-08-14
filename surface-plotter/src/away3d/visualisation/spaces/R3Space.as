package away3d.visualisation.spaces
{

    public class R3Space
    {

        private var _x0:Number;
        private var _x1:Number;
        private var _y0:Number;
        private var _y1:Number;
        private var _z0:Number;
        private var _z1:Number;

        public function R3Space( x0:Number, x1:Number, y0:Number, y1:Number, z0:Number, z1:Number )
        {
            _x0 = x0;
            _x1 = x1;
            _y0 = y0;
            _y1 = y1;
            _z0 = z0;
            _z1 = z1;
        }

        public function get x0():Number
        {
            return _x0;
        }

        public function get x1():Number
        {
            return _x1;
        }

        public function get y0():Number
        {
            return _y0;
        }

        public function get y1():Number
        {
            return _y1;
        }

        public function get z0():Number
        {
            return _z0;
        }

        public function get z1():Number
        {
            return _z1;
        }
    }

}
