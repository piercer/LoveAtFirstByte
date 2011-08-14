package away3d.entities
{
    import away3d.animators.data.AnimationBase;
    import away3d.animators.data.AnimationStateBase;
    import away3d.animators.data.NullAnimation;
    import away3d.arcane;
    import away3d.bounds.BoundingSphere;
    import away3d.bounds.BoundingVolumeBase;
    import away3d.core.base.IRenderable;
    import away3d.core.partition.EntityNode;
    import away3d.core.partition.RenderableNode;
    import away3d.materials.MaterialBase;
    import away3d.materials.SegmentMaterial;

    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Vector3D;

    use namespace arcane;

    public class Curve3D extends Entity implements IRenderable
    {
        private var _material:MaterialBase;
        private var _nullAnimation:NullAnimation;
        private var _animationState:AnimationStateBase;
        private var _vertices:Vector.<Number>;

        private var _numVertices:uint;
        private var _indices:Vector.<uint>;
        private var _numIndices:uint;
        private var _vertexBufferDirty:Boolean;
        private var _indexBufferDirty:Boolean;
        private var _vertexBuffer:VertexBuffer3D;
        private var _indexBuffer:IndexBuffer3D;
        private var _pointCount:uint;

        private var _currentX:Number;
        private var _currentY:Number;
        private var _currentZ:Number;

        private var _currentR:uint;
        private var _currentG:uint;
        private var _currentB:uint;

        private var _currentT:Number;

        public function Curve3D( start:Vector3D, color:uint, thickness:Number )
        {
            super();

            _currentX = start.x;
            _currentY = start.y;
            _currentZ = start.z;

            _currentR = ( ( color >> 16 ) & 0xff ) / 255;
            _currentG = ( ( color >> 8 ) & 0xff ) / 255;
            _currentB = ( color & 0xff ) / 255;

            _currentT = thickness;

            _nullAnimation = new NullAnimation();
            _vertices = new Vector.<Number>();
            _numVertices = 0;
            _indices = new Vector.<uint>();

            material = new SegmentMaterial();

            var index:uint = 0;
            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = _currentT;
            _vertices[index++] = _currentR;
            _vertices[index++] = _currentG;
            _vertices[index++] = _currentB;
            _vertices[index++] = 1;

            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = -_currentT;
            _vertices[index++] = _currentR;
            _vertices[index++] = _currentG;
            _vertices[index++] = _currentB;
            _vertices[index++] = 1;

            _pointCount++;

        }

        public function addPoint( point:Vector3D, color:uint, thickness:Number ):void
        {


            updateCurve( point, color, thickness );

            var index:uint = (_pointCount << 1)+1;

            _indices.push( index - 3, index, index - 2, index - 1, index, index - 3 );

            _numVertices = _vertices.length / 11;
            _numIndices = _indices.length;
            _vertexBufferDirty = true;
            _indexBufferDirty = true;
            _pointCount++;
        }

        arcane function updateCurve( point:Vector3D, color:uint, t:Number ):void
        {
            //
            //TODO add support for curve segment
            //TODO sort our thickness
            //
            var endX:Number = point.x;
            var endY:Number = point.y;
            var endZ:Number = point.z;
            var endR:uint = ( ( color >> 16 ) & 0xff ) / 255;
            var endG:uint = ( ( color >> 8 ) & 0xff ) / 255;
            var endB:uint = ( color & 0xff ) / 255;

            var index:uint = _vertices.length;

            _vertices[index++] = endX;
            _vertices[index++] = endY;
            _vertices[index++] = endZ;
            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = t;
            _vertices[index++] = endR;
            _vertices[index++] = endG;
            _vertices[index++] = endB;
            _vertices[index++] = 1;

            _vertices[index++] = endX;
            _vertices[index++] = endY;
            _vertices[index++] = endZ;
            _vertices[index++] = _currentX;
            _vertices[index++] = _currentY;
            _vertices[index++] = _currentZ;
            _vertices[index++] = -t;
            _vertices[index++] = endR;
            _vertices[index++] = endG;
            _vertices[index++] = endB;
            _vertices[index++] = 1;

            _vertexBufferDirty = true;
            _currentX = endX;
            _currentY = endY;
            _currentZ = endZ;
            _currentR = endR;
            _currentG = endG;
            _currentB = endB;
            _currentT = t;
        }

        protected function clear():void
        {
            _vertices.length = 0;
            _indices.length = 0;
            _vertexBufferDirty = true;
            _indexBufferDirty = true;
        }

        public function getVertexBuffer( context:Context3D, contextIndex:uint ):VertexBuffer3D
        {
            if ( _vertexBufferDirty )
            {
                _vertexBuffer = context.createVertexBuffer( _numVertices, 11 );
                _vertexBuffer.uploadFromVector( _vertices, 0, _numVertices );
                _vertexBufferDirty = false;
            }
            return _vertexBuffer;
        }

        public function getUVBuffer( context:Context3D, contextIndex:uint ):VertexBuffer3D
        {
            return null;
        }

        public function getVertexNormalBuffer( context:Context3D, contextIndex:uint ):VertexBuffer3D
        {
            return null;
        }

        public function getVertexTangentBuffer( context:Context3D, contextIndex:uint ):VertexBuffer3D
        {
            return null;
        }

        public function getIndexBuffer( context:Context3D, contextIndex:uint ):IndexBuffer3D
        {
            if ( _indexBufferDirty )
            {
                _indexBuffer = context.createIndexBuffer( _numIndices );
                _indexBuffer.uploadFromVector( _indices, 0, _numIndices );
                _indexBufferDirty = false;
            }
            return _indexBuffer;
        }

        public function get mouseDetails():Boolean
        {
            return false;
        }

        public function get numTriangles():uint
        {
            return _numIndices / 3;
        }

        public function get sourceEntity():Entity
        {
            return this;
        }

        public function get castsShadows():Boolean
        {
            return false;
        }

        public function get material():MaterialBase
        {
            return _material;
        }

        public function get animation():AnimationBase
        {
            return _nullAnimation;
        }

        public function get animationState():AnimationStateBase
        {
            return _animationState;
        }

        public function set material( value:MaterialBase ):void
        {
            if ( value == _material ) return;
            if ( _material ) _material.removeOwner( this );
            _material = value;
            if ( _material ) _material.addOwner( this );
        }

        override protected function getDefaultBoundingVolume():BoundingVolumeBase
        {
            return new BoundingSphere();
        }

        override protected function updateBounds():void
        {
            // todo: fix bounds
            _bounds.fromExtremes( -100, -100, 0, 100, 100, 0 );
            _boundsInvalid = false;
        }

        override protected function createEntityPartitionNode():EntityNode
        {
            return new RenderableNode( this );
        }
    }
}
