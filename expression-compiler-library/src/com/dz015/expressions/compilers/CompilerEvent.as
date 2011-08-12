package com.dz015.expressions.compilers
{
    import flash.events.Event;

    public class CompilerEvent extends Event
    {

        public static const COMPILE_COMPLETE:String = "compileComplete";

        private var _klass:Class;

        public function CompilerEvent( type:String, klass:Class = null, bubbles:Boolean = false, cancelable:Boolean = false )
        {
            super( type, bubbles, cancelable );
            _klass = klass;
        }

        public function get klass():Class
        {
            return _klass;
        }

    }
}