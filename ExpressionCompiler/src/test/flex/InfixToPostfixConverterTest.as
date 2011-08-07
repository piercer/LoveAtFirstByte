package
{

    import com.dz015.expressions.shuntyard.InfixToPostfixConverter;
    import com.dz015.expressions.tokens.TokenStack;

    import org.flexunit.asserts.assertEquals;

    import org.flexunit.runners.Parameterized;
    Parameterized;

    [RunWith("org.flexunit.runners.Parameterized")]
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

        public static function testStatements():Array
        {
            return [
                [ "2", "2" ],
                [ "2+3", "2 3 +" ],
                [ "2+3*5+4*5", "2 3 5 * + 4 5 * +" ],
                [ "2+(3+5)*2", "2 3 5 + 2 * +" ],
                [ "(3+5)*(1+9)", "3 5 + 1 9 + *" ],
                [ "5*(1+(9+3*(2+2)))", "5 1 9 3 2 2 + * + + *" ],
                [ "3+4*2/(1-5)^2^3", "3 4 2 * 1 5 - 2 3 ^ ^ / +" ],
                [ "y+3*cos(alpha)", "y 3 alpha cos * +" ],
                [ "y+3*cos(alpha/(2*sin(t)))", "y 3 alpha 2 t sin * / cos * +" ],
                [ "y+3*cos(alpha/2*sin(t))", "y 3 alpha 2 / t sin * cos * +" ],
                [ "sin(x)/cos(x)", "x sin x cos /" ]
            ];
        }

        [Test(dataProvider="testStatements")]
        public function testConverter( infix:String,  postfix:String):void
        {
            var result:TokenStack = _converter.convert( infix );
            assertEquals( postfix, result.toString() );
        }

    }

}
