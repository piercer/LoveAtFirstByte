package com.dz015.expressions.tokens.expression
{
    import com.dz015.expressions.tokens.*;

    import org.flexunit.asserts.assertEquals;

    public class DefaultExpressionTokeniserTest
    {

        private var _tokeniser:IExpressionTokeniser;

        public function DefaultExpressionTokeniserTest()
        {
        }

        [Before]
        public function setup():void
        {
            _tokeniser = new DefaultExpressionTokeniser( new DefaultOperatorTokenFactory() );
        }

        [Test]
        public function testSimpleString():void
        {
            var result:Vector.<Token> = _tokeniser.tokenise( "2" );
            assertEquals( "Wrong number of tokens returned with simple string", 1, result.length );
            assertEquals( "Wrong token value returned with simple string", "2", result[0].value );
            assertEquals( "Wrong token type returned with simple string", Token.NUMERIC, result[0].type );
        }

        [Test]
        public function testBinaryOperations():void
        {
            var result:Vector.<Token> = _tokeniser.tokenise( "2+3-yVal" );
            assertEquals( "Wrong number of tokens returned with simple string", 5, result.length );
            assertEquals( "Wrong token returned with simple string", "2", result[0].value );
            assertEquals( "Wrong token type returned with simple string", Token.NUMERIC, result[0].type );
            assertEquals( "Wrong token returned with simple string", "+", result[1].value );
            assertEquals( "Wrong token type returned with simple string", Token.OPERATOR, result[1].type );
            assertEquals( "Wrong token returned with simple string", "3", result[2].value );
            assertEquals( "Wrong token type returned with simple string", Token.NUMERIC, result[2].type );
            assertEquals( "Wrong token returned with simple string", "-", result[3].value );
            assertEquals( "Wrong token type returned with simple string", Token.OPERATOR, result[3].type );
            assertEquals( "Wrong token returned with simple string", "yVal", result[4].value );
            assertEquals( "Wrong token type returned with simple string", Token.SYMBOL, result[4].type );
        }

        [Test]
        public function testBigWords():void
        {
            var result:Vector.<Token> = _tokeniser.tokenise( "apple/orange" );
            assertEquals( "Wrong number of tokens returned with simple string", 3, result.length );
            assertEquals( "Wrong token value returned with simple string", "apple", result[0].value );
            assertEquals( "Wrong token type returned with simple string", Token.SYMBOL, result[0].type );
            assertEquals( "Wrong token value returned with simple string", "/", result[1].value );
            assertEquals( "Wrong token type returned with simple string", Token.OPERATOR, result[1].type );
            assertEquals( "Wrong token value returned with simple string", "orange", result[2].value );
            assertEquals( "Wrong token type returned with simple string", Token.SYMBOL, result[2].type );
        }

        [Test]
        public function testFunctions():void
        {
            var result:Vector.<Token> = _tokeniser.tokenise( "y+3*sin(x)" );
            assertEquals( "Wrong number of tokens returned with simple string", 8, result.length );
            assertEquals( "Wrong token value returned with simple string", "y", result[0].value );
            assertEquals( "Wrong token type returned with simple string", Token.SYMBOL, result[0].type );
            assertEquals( "Wrong token value returned with simple string", "+", result[1].value );
            assertEquals( "Wrong token type returned with simple string", Token.OPERATOR, result[1].type );
            assertEquals( "Wrong token value returned with simple string", "3", result[2].value );
            assertEquals( "Wrong token type returned with simple string", Token.NUMERIC, result[2].type );
            assertEquals( "Wrong token value returned with simple string", "*", result[3].value );
            assertEquals( "Wrong token type returned with simple string", Token.OPERATOR, result[3].type );
            assertEquals( "Wrong token value returned with simple string", "sin", result[4].value );
            assertEquals( "Wrong token type returned with simple string", Token.FUNCTION, result[4].type );
            assertEquals( "Wrong token value returned with simple string", "(", result[5].value );
            assertEquals( "Wrong token type returned with simple string", Token.LEFT_BRACKET, result[5].type );
            assertEquals( "Wrong token value returned with simple string", "x", result[6].value );
            assertEquals( "Wrong token type returned with simple string", Token.SYMBOL, result[6].type );
            assertEquals( "Wrong token value returned with simple string", ")", result[7].value );
            assertEquals( "Wrong token type returned with simple string", Token.RIGHT_BRACKET, result[7].type );
        }

    }
}
