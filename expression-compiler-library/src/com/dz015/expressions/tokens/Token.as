package com.dz015.expressions.tokens
{
    public class Token
    {

        public static const SYMBOL:uint = 0;
        public static const OPERATOR:uint = 1;
        public static const FUNCTION:uint = 3;
        public static const NUMERIC:uint = 4;
        public static const LEFT_BRACKET:uint = 5;
        public static const RIGHT_BRACKET:uint = 6;

        public static const LEFT_ASSOCIATIVE:uint = 0;
        public static const RIGHT_ASSOCIATIVE:uint = 1;

        private var _value:String;
        private var _type:uint;
        private var _precedence:uint;
        private var _associativity:uint;

        public function Token( value:String, type:uint, precedence:uint = 0, associativity:uint = 0 )
        {
            _value = value;
            _type = type;
            _precedence = precedence;
            _associativity = associativity;
        }

        public function get value():String
        {
            return _value;
        }

        public function get type():uint
        {
            return _type;
        }

        public function get isSymbol():Boolean
        {
            return _type == SYMBOL;
        }

        public function get isOperator():Boolean
        {
            return _type == OPERATOR;
        }

        public function get precedence():uint
        {
            return _precedence;
        }

        public function toString():String
        {
            return _value;
        }

        public function get associativity():uint
        {
            return _associativity;
        }

        public function get isRightBracket():Boolean
        {
            return _type == RIGHT_BRACKET;
        }

        public function get isLeftBracket():Boolean
        {
            return _type == LEFT_BRACKET;
        }

        public function get isLeftAssociative():Boolean
        {
            return _associativity == LEFT_ASSOCIATIVE;
        }

        public function get isNumeric():Boolean
        {
            return _type == NUMERIC;
        }

        public function get isFunction():Boolean
        {
            return _type == FUNCTION;
        }
    }
}
