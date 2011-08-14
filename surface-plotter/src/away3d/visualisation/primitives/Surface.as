package away3d.visualisation.primitives
{

    import away3d.core.base.SubGeometry;
    import away3d.materials.MaterialBase;
    import away3d.primitives.PrimitiveBase;

    import com.dz015.generators.ISurfaceGenerator;

    public class Surface extends PrimitiveBase
    {

        private var _nx:uint;
        private var _ny:uint;
        private var _dx:Number;
        private var _dy:Number;

        private var _nVertices:uint;
        private var _heights:Vector.<Number>;
        private var _width:Number;
        private var _height:Number;
        private var _cellWidth:Number;
        private var _cellHeight:Number;

        private var _builtPlane:Boolean;

        public function Surface( material:MaterialBase, width:Number = 1, height:Number = 1, nx:uint = 100, ny:uint = 100 )
        {
            super( material );

            _width = width;
            _height = height;

            _nx = nx;
            _ny = ny;
            _nVertices = (_nx + 1) * (_ny + 1);

            _cellWidth = width / _nx;
            _cellHeight = height / _ny;
        }

        /**
         * @inheritDoc
         */
        protected override function buildGeometry( target:SubGeometry ):void
        {

            var vertices:Vector.<Number>;
            var indices:Vector.<uint>;
            var i:uint;
            var j:uint;


            if ( !_builtPlane )
            {


                //
                // Create a flat plane of vertices
                //

                vertices = new Vector.<Number>();
                indices = new Vector.<uint>();

                for ( j = 0; j <= _ny; j++ )
                {
                    var y:Number = j * _cellHeight;
                    for ( i = 0; i <= _nx; i++ )
                    {
                        var x:Number = i * _cellWidth;
                        vertices.push( x, y, 0 );
                    }
                }

                //
                // Create an optimised index buffer
                //

                var iLastSquare:uint = (_nx + 1) * _ny - 2;
                var iLastColumn:uint = _nx;

                for ( i = 0; i <= iLastSquare; i++ )
                {
                    if ( i == iLastColumn )
                    {
                        iLastColumn += _nx + 1;
                    }
                    else
                    {
                        var v1:uint = i;
                        var v2:uint = i + 1;
                        var v3:uint = i + _nx + 2;
                        var v4:uint = i + _nx + 1;

                        indices.push( v1, v3, v2, v1, v4, v3 );
                    }
                }

                target.updateIndexData( indices );
                target.updateVertexData( vertices );
                target.autoDeriveVertexNormals = true;
                target.autoDeriveVertexTangents = true;
            }

            if ( _heights )
            {
                var nVertices:uint = (_nx + 1) * (_ny + 1);
                for ( var i:uint = 0; i < nVertices; i++ )
                {
                    vertices[3 * i + 2] = _heights[i];
                }
            }
        }

        override protected function buildUVs( target:SubGeometry ):void
        {
            var i:int;
            var j:int;

            var uvData:Vector.<Number> = new Vector.<Number>();

            for ( j = 0; j <= _ny; j++ )
            {
                for ( i = 0; i <= _nx; i++ )
                {
                    uvData.push( i / _nx, j / _ny );
                }
            }
            target.updateUVData( uvData );
        }

        public function adjustUVCoordinatesForContourColorTexture( nColors:uint ):void
        {
//            var i:uint;
//            var zMin:Number = 0;
//            var zMax:Number = 0;
//            _rawUvBuffer = new Vector.<Number>();
//            for ( i = 0; i < _nVertices; i++ )
//            {
//                var z:Number = _rawVertexBuffer[i * 3 + 2];
//                if ( z < zMin ) zMin = z;
//                if ( z > zMax ) zMax = z;
//            }
//            var range:Number = zMax - zMin;
//            for ( i = 0; i < _nVertices; i++ )
//            {
//                var diff:Number = _rawVertexBuffer[i * 3 + 2] - zMin;
//                _rawUvBuffer.push( diff / range, 0 );
//            }
        }

        public function applyGenerator( generator:ISurfaceGenerator, xMin:Number, xMax:Number, yMin:Number, yMax:Number, zScale:Number = 1 ):void
        {
            var i:uint;
            var j:uint;

            _heights = new <Number>[];

            _dx = (xMax - xMin) / _nx;
            _dy = (yMax - yMin) / _ny;
            for ( j = 0; j <= _ny; j++ )
            {
                var y:Number = yMin + j * _dy;
                for ( i = 0; i <= _nx; i++ )
                {
                    var x:Number = xMin + i * _dx;
                    var z:Number = generator.f( x, y, zScale );
                    _heights[i + j * (_nx + 1)] = z;
                }
            }
            invalidateUVs();
            invalidateGeometry();
        }

    }

}
