package
{

    import org.flexunit.asserts.assertEquals;

    public class InfixToPostfixConverterTest
    {

        private var _converter:InfixToPostfixConverter;

        public function InfixToPostfixConverterTest()
        {
        }

        [Before]
        public function setup():void
        {
            _converter = new InfixToPostfixConverter();
        }

        [Test]
        public function testTwoReturnsTwo():void
        {
            var result:TokenStack = _converter.convert( "2" );
            assertEquals( "2", result.toString() );
        }

        [Test]
        public function testBinaryOperation():void
        {
            var result:TokenStack = _converter.convert( "2+3" );
            assertEquals( "2 3 +", result.toString() );
        }

        [Test]
        public function testOperatorPrecedence():void
        {
            var result:TokenStack = _converter.convert( "2+3*5+4*5" );
            assertEquals( "2 3 5 * + 4 5 * +", result.toString() );
        }

        [Test]
        public function testBrackets():void
        {
            var result:TokenStack = _converter.convert( "2+(3+5)*2" );
            assertEquals( "2 3 5 + 2 * +", result.toString() );
        }

        [Test]
        public function testBrackets2():void
        {
            var result:TokenStack = _converter.convert( "(3+5)*(1+9)" );
            assertEquals( "3 5 + 1 9 + *", result.toString() );
        }

        [Test]
        public function testNestedBrackets():void
        {
            var result:TokenStack = _converter.convert( "5*(1+(9+3*(2+2)))" );
            assertEquals( "5 1 9 3 2 2 + * + + *", result.toString() );
        }

        [Test]
        public function testAll():void
        {
            var result:TokenStack = _converter.convert( "3+4*2/(1-5)^2^3" );
            assertEquals( "3 4 2 * 1 5 - 2 3 ^ ^ / +", result.toString() );
        }

        [Test]
        public function testFunction():void
        {
            var result:TokenStack = _converter.convert( "y+3*cos(alpha)" );
            assertEquals( "y 3 alpha cos * +", result.toString() );
        }

        [Test]
        public function testNestedFunction1():void
        {
            var result:TokenStack = _converter.convert( "y+3*cos(alpha/(2*sin(t)))" );
            assertEquals( "y 3 alpha 2 t sin * / cos * +", result.toString() );
        }

        [Test]
        public function testNestedFunction2():void
        {
            var result:TokenStack = _converter.convert( "y+3*cos(alpha/2*sin(t))" );
            assertEquals( "y 3 alpha 2 / t sin * cos * +", result.toString() );
        }

        [Test]
        public function testDividedFunctions():void
        {
            var result:TokenStack = _converter.convert( "sin(x)/cos(x)" );
            assertEquals( "x sin x cos /", result.toString() );
        }

    }

}
