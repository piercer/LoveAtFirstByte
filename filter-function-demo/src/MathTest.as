package
{

    import com.dz015.expressions.compilers.CompilerEvent;
    import com.dz015.expressions.compilers.XExpressionCompiler;
    import com.dz015.expressions.shuntyard.InfixToPostfixConverter;
    import com.dz015.expressions.tokens.expression.DefaultExpressionTokeniser;
    import com.dz015.expressions.tokens.expression.DefaultOperatorTokenFactory;
    import com.dz015.expressions.tokens.IExpressionTokeniser;
    import com.dz015.expressions.tokens.TokenStack;

    import flash.display.Sprite;
    import flash.utils.getTimer;

    [SWF(backgroundColor="#FF0000",height="500",width="500",frameRate="60")]
    public class MathTest extends Sprite
    {

        private var _time:int;

        public function MathTest()
        {

            var expression:String = "(2*sin(5+4*cos(x)))/10";
            var tokeniser:IExpressionTokeniser = new DefaultExpressionTokeniser( new DefaultOperatorTokenFactory() );

            var converter:InfixToPostfixConverter = new InfixToPostfixConverter( tokeniser );
            var tokenStack:TokenStack = converter.convert( expression );

            var simulator:VMSimulator = new VMSimulator( tokenStack.stack );

            trace("Test Value: Interpreted ",simulator.f(5));
            _time = getTimer();
            for ( var i:uint = 0; i < 1000000; i++ )
            {
                simulator.f( 3 );
            }
            trace( "Calculating with interpreted expression took", getTimer() - _time, "ms" );


            _time = getTimer();
            var compiler:XExpressionCompiler = new XExpressionCompiler();
            compiler.addEventListener( CompilerEvent.COMPILE_COMPLETE, onCompilerComplete )
            compiler.compile( expression, tokeniser );

        }

        private function onCompilerComplete( event:CompilerEvent ):void
        {
            trace( "Compiling took", getTimer() - _time, "ms" );
            var functionClass:Class = event.klass;
            var instance:* = new functionClass();
            trace("Test Value: Compiled ",instance.f(5));
            _time = getTimer();
            for ( var i:uint = 0; i < 1000000; i++ )
            {
                instance.f( 3 );
            }
            trace( "Calculating with compiled expression took", getTimer() - _time, "ms" );
        }

        public function filterFunction(item:Object):Boolean
        {
            return (item["field1"]+item["field2"]) > 3;
        }
    }
}
