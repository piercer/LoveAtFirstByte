package away3d.textures
{

    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;

    public class ContourMapTexture extends Sprite
    {

        private static const WIDTH:Number = 512;
        private static const HEIGHT:Number = 512;

        private static const colours:Vector.<uint> = new <uint>[0x0000A0,0x0000FF,0x00A040,0x00FF00,0xFFFF00,0xFFCC00,0xFF0000];

        public function ContourMapTexture()
        {

        }

        public function get texture():BitmapData
        {
            var nColours:uint = 7;
            var colorWidth:Number = WIDTH / nColours;

            var g:Graphics = graphics;

            for ( var i:uint = 0; i < 7; i++ )
            {
                g.beginFill( colours[i], 1 );
                g.drawRect( i * colorWidth, 0, colorWidth, HEIGHT );
                g.endFill();
            }

            var bData:BitmapData = new BitmapData( WIDTH, HEIGHT );
            bData.draw( this );
            return bData;
        }


    }
}
