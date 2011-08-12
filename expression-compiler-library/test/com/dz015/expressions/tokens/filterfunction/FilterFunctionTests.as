package com.dz015.expressions.tokens.filterfunction
{
    import com.dz015.expressions.compilers.CompilerEvent;
    import com.dz015.expressions.compilers.FilterFunctionCompiler;

    import mx.collections.ArrayCollection;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.async.Async;
    import org.flexunit.runners.Parameterized;

    Parameterized;

    [RunWith("org.flexunit.runners.Parameterized")]
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

        public static function testFilters():Array
        {
            return [
                [ "income=1", 1 ],
                [ "income-outgoing>0", 5 ],
                [ "weighting=2 or weighting=1", 10 ],
                [ "weighting=2 and weighting=1", 0 ],
                [ "income-outgoing>0 and weighting=2", 0 ],
                [ "income-outgoing>0 or weighting=2", 10 ]
            ];
        }

        [Test(async,dataProvider="testFilters")]
        public function testFilter( filter:String,  nPassing:uint ):void
        {
            Async.handleEvent( this, _filterFunctionCompiler, CompilerEvent.COMPILE_COMPLETE, testFilteredDataIsCorrectLength, 1000, nPassing );
            _filterFunctionCompiler.compile( filter, new FilterFunctionTokeniser( new FilterFunctionOperatorTokenFactory() ) );
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
