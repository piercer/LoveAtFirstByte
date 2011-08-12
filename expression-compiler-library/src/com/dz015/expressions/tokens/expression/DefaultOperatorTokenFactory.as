package com.dz015.expressions.tokens.expression
{

    import com.dz015.expressions.tokens.IOperatorTokenFactory;
    import com.dz015.expressions.tokens.Token;

    public class DefaultOperatorTokenFactory implements IOperatorTokenFactory
    {
        public function DefaultOperatorTokenFactory()
        {
        }

        public function getOperatorToken( symbol:String ):Token
        {
            var operatorToken:Token;

            switch ( symbol )
            {

                case '+':
                case '-':
                    operatorToken = new Token( symbol, Token.OPERATOR, 0, Token.LEFT_ASSOCIATIVE );
                    break;

                case '*':
                case '/':
                    operatorToken = new Token( symbol, Token.OPERATOR, 1, Token.LEFT_ASSOCIATIVE );
                    break;

                case '^':
                    operatorToken = new Token( symbol, Token.OPERATOR, 2, Token.RIGHT_ASSOCIATIVE );
                    break;

                case '(':
                    operatorToken = new Token( symbol, Token.LEFT_BRACKET );
                    break;

                case ')':
                    operatorToken = new Token( symbol, Token.RIGHT_BRACKET );
                    break;

            }

            return operatorToken;
        }
    }

}
