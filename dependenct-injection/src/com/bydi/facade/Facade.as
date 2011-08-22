package com.bydi.facade
{
    import org.swiftsuspenders.Injector;

    public class Facade
    {

        public static var _injector:Injector;

        public function Facade()
        {
        }

        public static function get injector():Injector
        {
            if (!_injector)
            {
                _injector = new Injector();
            }
            return _injector;
        }
    }
}
