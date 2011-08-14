package away3d.flex
{

    import away3d.cameras.Camera3D;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;

    import flash.events.Event;

    import spark.core.SpriteVisualElement;

    public class Sprite3DVisualElement extends SpriteVisualElement
    {

        private var _view:View3D;

        public function Sprite3DVisualElement()
        {
            _view = new View3D();
            _view.antiAlias = 4;
            _view.backgroundColor = 0xCCCCCC;

            addChild( _view );
        }

        public function get view():View3D
        {
            return _view;
        }

        override public function set height( value:Number ):void
        {
            _view.height = value;
            super.height = value;
        }

        override public function set width( value:Number ):void
        {
            _view.width = value;
            super.width = value;
        }

        public function get scene():Scene3D
        {
            return _view.scene;
        }

        public function get camera():Camera3D
        {
            return _view.camera;
        }

        public function startRendering():void
        {
            _view.addEventListener( Event.ENTER_FRAME, onEnterFrame );
        }

        public function stopRendering():void
        {
            _view.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
        }

        private function onEnterFrame( e:Event ):void
        {
            _view.render();
        }

    }

}
