package
{
    import com.dz015.expressions.tokens.Token;
    import com.dz015.generators.ISurfaceGenerator;

    public class VMSimulator implements ISurfaceGenerator
    {
        private var _instructions:Vector.<Token>;

        public function VMSimulator( instructions:Vector.<Token> )
        {
            _instructions = instructions;
        }

        public function f( x:Number, y:Number, a:Number ):Number
        {
            var n1:Number;
            var n2:Number;
            var _stack:Vector.<Number> = new Vector.<Number>();
            var nInstructions:uint = _instructions.length;

            for ( var i:uint = 0; i < nInstructions; i++ )
            {
                var token:Token = _instructions[i];

                switch ( token.type )
                {
                    case Token.SYMBOL:
                        switch ( token.value )
                        {
                            case "x":
                                _stack.push( x );
                                break;

                            case "y":
                                _stack.push( y );
                                break;

                            case "a":
                                _stack.push( a );
                                break;

                        }
                        break;

                    case Token.NUMERIC:
                        _stack.push( token.value );
                        break;

                    case Token.FUNCTION:

                        switch ( token.value )
                        {

                            case 'sin':
                                _stack.push( Math.sin( _stack.pop() ) );
                                break;
                            case 'cos':
                                _stack.push( Math.cos( _stack.pop() ) );
                                break;
                            case 'tan':
                                _stack.push( Math.tan( _stack.pop() ) );
                                break;
                        }
                        break;

                    case Token.OPERATOR:
                        switch ( token.value )
                        {
                            case '^':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( Math.pow( n2, n1 ) );
                                break;

                            case '*':
                                _stack.push( _stack.pop() * _stack.pop() );
                                break;
                            case '/':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 / n1 );
                                break;
                            case '+':
                                _stack.push( _stack.pop() + _stack.pop() );
                                break;
                            case '-':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 - n1 );
                                break;
                            case '<':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 < n1 );
                                break;
                            case '>=':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 >= n1 );
                                break;
                            case '<=':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 <= n1 );
                                break;
                            case '>':
                                n1 = _stack.pop();
                                n2 = _stack.pop();
                                _stack.push( n2 > n1 );
                                break;
                            case '=':
                                _stack.push( _stack.pop() == _stack.pop() );
                                break;
                            case '&':
                                _stack.push( _stack.pop() && _stack.pop() );
                                break;
                            case '|':
                                _stack.push( _stack.pop() || _stack.pop() );
                                break;

                        }
                        break;
                }

            }
            return _stack.pop();
        }
    }

}
