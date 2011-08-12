package com.dz015.expressions.tokens
{
    public class TokenStack
    {

        private var _stack:Vector.<Token>;

        public function TokenStack()
        {
            _stack = new Vector.<Token>();
        }

        public function get stack():Vector.<Token>
        {
            return _stack;
        }

        public function push( token:Token ):void
        {
            _stack.push( token );
        }

        public function pop():Token
        {
            return _stack.pop();
        }

        public function popOperatorIfHigherPrecedenceThan( o1:Token ):Token
        {
            if ( _stack.length > 0 )
            {
                var o2:Token = _stack[ _stack.length - 1 ];
                if ( !o2.isLeftBracket && ((o1.isLeftAssociative && o1.precedence <= o2.precedence) || (!o1.isLeftAssociative && o1.precedence < o2.precedence )) )
                {
                    return _stack.pop();
                }
            }
            return null;
        }

        public function popUntilFunctionCallOrLeftBracket():Token
        {
            var top:Token;
            if ( _stack.length > 0 )
            {
                top = _stack.pop();
                if ( top.isLeftBracket )
                {
                    if ( _stack.length > 0 )
                    {
                        var newTop:Token = _stack[ _stack.length - 1 ];
                        if ( newTop.isFunction )
                        {
                            top = _stack.pop();
                        }
                        else
                        {
                            top = null;
                        }
                    }
                    else
                    {
                        top = null;
                    }
                }
            }
            return top;
        }

        public function toString():String
        {
            return _stack.join( " " );
        }

    }

}
