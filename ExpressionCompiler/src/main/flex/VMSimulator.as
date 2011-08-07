package
{
    import com.dz015.expressions.tokens.Token;

    public class VMSimulator
    {

        private var _stack:Vector.<Number>;
        private var _instructions:Vector.<Token>;

        public function VMSimulator( instructions:Vector.<Token> )
        {
            _instructions = instructions;
        }

        public function f( x:Number ):Number
        {
            _stack = new Vector.<Number>();
            var nInstructions:uint = _instructions.length;

            for ( var i:uint = 0; i < nInstructions; i++ )
            {
                var token:Token = _instructions[i];

                switch ( token.type )
                {
                    case Token.SYMBOL:
                        _stack.push( x );
                        break;

                    case Token.NUMERIC:
                        _stack.push( token.value );
                        break;

                    case Token.FUNCTION:

                        switch ( token.value )
                        {

                            case 'sin':
                                _stack.push( Math.sin( _stack.pop() ) )
                                break;
                            case 'cos':
                                _stack.push( Math.cos( _stack.pop() ) )
                                break;
                            case 'tan':
                                _stack.push( Math.tan( _stack.pop() ) )
                                break;
                        }
                        break;

                    case Token.OPERATOR:
                        switch ( token.value )
                        {
                            case '^':
                                var n1:Number = _stack.pop();
                                var n2:Number = _stack.pop();
                                _stack.push( Math.pow( n2, n1 ) );
                                break;

                            case '*':
                                _stack.push( _stack.pop() * _stack.pop() );
                                break;
                            case '/':
                                var n1:Number = _stack.pop();
                                var n2:Number = _stack.pop();
                                _stack.push( n2 / n1 );
                                break;
                            case '+':
                                _stack.push( _stack.pop() + _stack.pop() );
                                break;
                            case '-':
                                var n1:Number = _stack.pop();
                                var n2:Number = _stack.pop();
                                _stack.push( n2 - n1 );
                                break;
                        }
                        break;
                }

            }
            return _stack.pop();
        }
    }

}
