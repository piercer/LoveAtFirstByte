package com.dz015.expressions.tokens
{

    public interface IOperatorTokenFactory
    {
        function getOperatorToken( symbol:String ):Token;
    }

}
