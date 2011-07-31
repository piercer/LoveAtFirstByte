/**
 * Created by IntelliJ IDEA.
 * User: conrad
 * Date: 15/06/2011
 * Time: 06:46
 * To change this template use File | Settings | File Templates.
 */
package
{
    import flash.display.Sprite;

    [SWF(backgroundColor="#FF0000",height="500",width="500",frameRate="60")]
    public class MathTest extends Sprite
    {
        public function MathTest()
        {
            var a:Number = 1.2;
            Math.sin(2.7/a);
        }
    }
}
