package
{

    import com.dz015.expressions.compilers.CompilerEvent;
    import com.dz015.expressions.compilers.FilterFunctionCompiler;
    import com.dz015.expressions.shuntyard.InfixToPostfixConverter;
    import com.dz015.expressions.tokens.filterfunction.FilterFunctionOperatorTokenFactory;
    import com.dz015.expressions.tokens.filterfunction.FilterFunctionTokeniser;
    import com.dz015.expressions.tokens.IExpressionTokeniser;
    import com.dz015.expressions.tokens.TokenStack;

    import flash.display.Sprite;
    import flash.utils.getTimer;

    import mx.collections.ArrayCollection;

    [SWF(backgroundColor="#FF0000",height="500",width="500",frameRate="60")]
    public class FilterFunctionTest extends Sprite
    {

        private var _time:int;
        private var _data:ArrayCollection;

        public function FilterFunctionTest()
        {

            var expression:String = "a>b and b>c or a<c";
            var tokeniser:IExpressionTokeniser = new FilterFunctionTokeniser( new FilterFunctionOperatorTokenFactory() );

            var converter:InfixToPostfixConverter = new InfixToPostfixConverter( tokeniser );
            var tokenStack:TokenStack = converter.convert( expression );

            var simulator:FilterFunctionVMSimulator = new FilterFunctionVMSimulator( tokenStack.stack );

            _data = new ArrayCollection();
            var i:uint;
            for ( i = 0; i < 200000; i++ )
            {
                _data.addItem( { a: Math.random(), b: Math.random(), c:Math.random() } );
            }

            _data.filterFunction = simulator.filterFunction;
            _time = getTimer();
            _data.refresh();
            trace( "Calculating with interpreted expression took", getTimer() - _time, "ms" );


            _time = getTimer();
            var compiler:FilterFunctionCompiler = new FilterFunctionCompiler();
            compiler.addEventListener( CompilerEvent.COMPILE_COMPLETE, onCompilerComplete )
            compiler.compile( expression, tokeniser );

        }

        private function onCompilerComplete( event:CompilerEvent ):void
        {
            trace( "Compiling took", getTimer() - _time, "ms" );
            var functionClass:Class = event.klass;
            var instance:* = new functionClass();

            _data.filterFunction = instance.filterFunction;
            _time = getTimer();
            _data.refresh();
            trace( "Calculating with compiled expression took", getTimer() - _time, "ms" );
        }

    }
}
