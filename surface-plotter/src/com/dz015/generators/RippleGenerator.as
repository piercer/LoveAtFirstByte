/**
 * Created by ${PRODUCT_NAME}.
 * User: conrad
 * Date: 08/04/2011
 * Time: 15:37
 * To change this template use File | Settings | File Templates.
 */
package com.dz015.generators
{
    public class RippleGenerator implements ISurfaceGenerator
    {
        public function RippleGenerator()
        {
        }

        public function f( x:Number, y:Number, a:Number ):Number
        {
            return a*Math.sin(x*x+y*y);
        }
    }
}
