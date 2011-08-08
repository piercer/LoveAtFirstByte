package com.dz015.expressions
{
    import com.dz015.expressions.compilers.CompilerEvent;
    import com.dz015.expressions.compilers.FilterFunctionCompiler;
    import com.dz015.expressions.tokens.FilterFunctionOperatorTokenFactory;
    import com.dz015.expressions.tokens.FilterFunctionTokeniser;

    import mx.collections.ArrayCollection;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;
    import org.flexunit.async.Async;

    public class FilterFunctionTests
    {

        private var _data:ArrayCollection;
        private var _filterFunctionCompiler:FilterFunctionCompiler;

        public function FilterFunctionTests()
        {
        }

        [Before]
        public function createDataProvider():void
        {
            _data = new ArrayCollection();

            for ( var i:uint = 0; i < 10; i++ )
            {
                if ( i > 4 )
                {
                    _data.addItem( new FilterFunctionTestObject( i, i / 2, 1, 2 ) );
                }
                else
                {
                    _data.addItem( new FilterFunctionTestObject( i, i * 2, 2, 1 ) );
                }
            }
            _filterFunctionCompiler = new FilterFunctionCompiler();
        }

        [Test(async)]
        public function test1():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 1 );
            generateFilterFunction( "income=1" );
        }

        [Test(async)]
        public function test2():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 5 );
            generateFilterFunction( "income-outgoing>0" );
        }

        [Test(async)]
        public function test3():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 10 );
            generateFilterFunction( "weighting=2 or weighting=1" );
        }

        [Test(async)]
        public function test4():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 0 );
            generateFilterFunction( "weighting=2 and weighting=1" );
        }

        [Test(async)]
        public function test5():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 0 );
            generateFilterFunction( "income-outgoing>0 and weighting=2" );
        }

        [Test(async)]
        public function test6():void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, 10 );
            generateFilterFunction( "income-outgoing>0 or weighting=2" );
        }

        private function generateFilterFunction( filterExpression:String ):void
        {
            _filterFunctionCompiler.compile( filterExpression, new FilterFunctionTokeniser( new FilterFunctionOperatorTokenFactory() ) );
        }

        private function testFilteredDataIsCorrectLength( event:CompilerEvent, length:uint ):void
        {
            var filterClass:Class = event.klass;
            var filterer:* = new filterClass();
            _data.filterFunction = filterer.filterFunction;
            _data.refresh();
            assertEquals( "Data is not filtered correctly", length, _data.length );
        }

    }
}
