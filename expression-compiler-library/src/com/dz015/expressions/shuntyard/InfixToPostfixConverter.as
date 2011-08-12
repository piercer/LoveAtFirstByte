package com.dz015.expressions.shuntyard
{

    import com.dz015.expressions.tokens.IExpressionTokeniser;
    import com.dz015.expressions.tokens.Token;
    import com.dz015.expressions.tokens.TokenStack;

    public class InfixToPostfixConverter
    {

        private var _tokeniser:IExpressionTokeniser;

        public function InfixToPostfixConverter( tokeniser:IExpressionTokeniser )
        {
            _tokeniser = tokeniser;
        }

        public function convert( expression:String ):TokenStack
        {
            var outputStack:TokenStack = new TokenStack();
            var operatorStack:TokenStack = new TokenStack();

            var tokens:Vector.<Token> = _tokeniser.tokenise( expression.replace( ' and ', '&' ).replace( ' or ', '|' ).replace( ' ', '' ) );
            var topToken:Token;

            for each ( var token:Token in tokens )
            {
                if ( token.isOperator )
                {
                    while ( topToken = operatorStack.popOperatorIfHigherPrecedenceThan( token ) )
                    {
                        outputStack.push( topToken );
                    }
                    operatorStack.push( token );
                }
                else if ( token.isLeftBracket || token.isFunction )
                {
                    operatorStack.push( token );
                }
                else if ( token.isRightBracket )
                {
                    topToken = operatorStack.popUntilFunctionCallOrLeftBracket();
                    while ( topToken && !topToken.isFunction )
                    {
                        outputStack.push( topToken );
                        topToken = operatorStack.popUntilFunctionCallOrLeftBracket();
                    }
                    if ( topToken && topToken.isFunction )
                    {
                        outputStack.push( topToken );
                    }
                }
                else
                {
                    outputStack.push( token );
                }
            }

            for each ( var operator:Token in operatorStack.stack.reverse() )
            {
                outputStack.push( operator );
            }
            return outputStack;
        }
    }
}
