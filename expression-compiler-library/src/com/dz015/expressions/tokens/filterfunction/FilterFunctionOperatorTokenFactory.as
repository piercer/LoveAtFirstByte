package com.dz015.expressions.tokens.filterfunction
{

    import com.dz015.expressions.tokens.IOperatorTokenFactory;
    import com.dz015.expressions.tokens.Token;

    public class FilterFunctionOperatorTokenFactory implements IOperatorTokenFactory
    {

        public function FilterFunctionOperatorTokenFactory()
        {
        }

        public function getOperatorToken( symbol:String ):Token
        {
            var operatorToken:Token;

            switch ( symbol )
            {

                case '+':
                case '-':
                    operatorToken = new Token( symbol, Token.OPERATOR, 2, Token.LEFT_ASSOCIATIVE );
                    break;

                case '*':
                case '/':
                    operatorToken = new Token( symbol, Token.OPERATOR, 3, Token.LEFT_ASSOCIATIVE );
                    break;

                case '^':
                    operatorToken = new Token( symbol, Token.OPERATOR, 4, Token.RIGHT_ASSOCIATIVE );
                    break;

                case '>':
                case '<':
                case '=':
                case '>=':
                case '<=':
                    operatorToken = new Token( symbol, Token.OPERATOR, 1, Token.RIGHT_ASSOCIATIVE );
                    break;

                case '(':
                    operatorToken = new Token( symbol, Token.LEFT_BRACKET );
                    break;

                case ')':
                    operatorToken = new Token( symbol, Token.RIGHT_BRACKET );
                    break;

                case '&':
                case '|':
                    operatorToken = new Token( symbol, Token.OPERATOR, 0, Token.RIGHT_ASSOCIATIVE );
                    break;

            }

            return operatorToken;
        }
    }

}
