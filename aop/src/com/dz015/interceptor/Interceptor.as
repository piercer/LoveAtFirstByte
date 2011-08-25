package com.dz015.interceptor
{

    public class Interceptor
    {
        public static function intercept( message:String ):void
        {
            trace("Method called", message);
        }
    }

}