package away3d.visualisation.primitives
{

    import away3d.core.base.SubGeometry;
    import away3d.materials.MaterialBase;
    import away3d.primitives.PrimitiveBase;

    import com.dz015.expressions.ISurfaceGenerator;

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
        private var _vertices:Vector.<Number>;

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

            var indices:Vector.<uint>;
            var i:uint;
            var j:uint;


            if ( !_builtPlane )
            {


                //
                // Create a flat plane of vertices
                //

                _vertices = new Vector.<Number>();
                indices = new Vector.<uint>();

                for ( j = 0; j <= _ny; j++ )
                {
                    var y:Number = j * _cellHeight;
                    for ( i = 0; i <= _nx; i++ )
                    {
                        var x:Number = i * _cellWidth;
                        _vertices.push( x, y, 0 );
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

                _builtPlane = true;

                target.updateIndexData( indices );
                target.autoDeriveVertexNormals = true;
                target.autoDeriveVertexTangents = true;
            }

            if ( _heights )
            {
                var nVertices:uint = (_nx + 1) * (_ny + 1);
                for ( i = 0; i < nVertices; i++ )
                {
                    _vertices[3 * i + 2] = _heights[i];
                }
            }
            target.updateVertexData( _vertices );

        }

        override protected function buildUVs( target:SubGeometry ):void
        {
            var i:int;
            var j:int;
            var uvData:Vector.<Number> = new Vector.<Number>();
            if ( _heights )
            {


                var zMin:Number = 0;
                var zMax:Number = 0;

                for ( i = 0; i < _nVertices; i++ )
                {
                    var z:Number = _heights[i];
                    if ( z < zMin ) zMin = z;
                    if ( z > zMax ) zMax = z;
                }

                var range:Number = zMax - zMin;
                for ( i = 0; i < _nVertices; i++ )
                {
                    var diff:Number = target.vertexData[i * 3 + 2] - zMin;
                    uvData.push( diff / range, 0 );
                }
            }
            else
            {
                for ( j = 0; j <= _ny; j++ )
                {
                    for ( i = 0; i <= _nx; i++ )
                    {
                        uvData.push( 0, 0 );
                    }
                }

            }
            target.updateUVData( uvData );
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
            invalidateGeometry();
            invalidateUVs();
        }

    }

}
