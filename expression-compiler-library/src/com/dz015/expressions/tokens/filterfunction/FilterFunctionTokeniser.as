package com.dz015.expressions.tokens.filterfunction
{

    import com.dz015.expressions.tokens.IExpressionTokeniser;
    import com.dz015.expressions.tokens.IOperatorTokenFactory;
    import com.dz015.expressions.tokens.Token;

    public class FilterFunctionTokeniser implements IExpressionTokeniser
    {

        private var _tokeniser:RegExp;
        private var _operatorTokenFactory:IOperatorTokenFactory;

        public function FilterFunctionTokeniser( operatorTokenFactory:IOperatorTokenFactory )
        {
            _operatorTokenFactory = operatorTokenFactory;
            _tokeniser = /\s*(sin|tan|cos)|(\d+)|(\w+)|(<=|>=|.)/g;
        }

        public function tokenise( s:String ):Vector.<Token>
        {
            var tokens:Vector.<Token> = new Vector.<Token>();

            var match:Array = _tokeniser.exec( s );

            while ( match != null )
            {
                tokens.push( createTokenFromMatch( match ) );
                match = _tokeniser.exec( s );
            }

            return tokens;
        }

        private function createTokenFromMatch( match:Array ):Token
        {
            var value:String = match[0];
            var token:Token;

            if ( match[1] )
            {
                token = new Token( value, Token.FUNCTION );
            }
            if ( match[2] )
            {
                token = new Token( value, Token.NUMERIC );
            }
            else if ( match[3] )
            {
                token = new Token( value, Token.SYMBOL );
            }
            else if ( match[4] )
            {
                token = _operatorTokenFactory.getOperatorToken( value );
            }
            return token;
        }

    }
}
