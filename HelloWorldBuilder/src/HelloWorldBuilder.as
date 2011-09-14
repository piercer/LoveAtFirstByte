package
{

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;

    import org.as3commons.bytecode.abc.LNamespace;
    import org.as3commons.bytecode.abc.QualifiedName;
    import org.as3commons.bytecode.abc.enum.Opcode;
    import org.as3commons.bytecode.emit.IAbcBuilder;
    import org.as3commons.bytecode.emit.IClassBuilder;
    import org.as3commons.bytecode.emit.IMethodBuilder;
    import org.as3commons.bytecode.emit.impl.AbcBuilder;

    public class HelloWorldBuilder extends Sprite
    {
        public function HelloWorldBuilder()
        {

            var abcBuilder:IAbcBuilder = new AbcBuilder();
            var classBuilder:IClassBuilder = abcBuilder.definePackage( "com.classes.generated" ).defineClass( "HelloWorldClass" );

            var methodBuilder:IMethodBuilder = classBuilder.defineMethod();
            methodBuilder.name = "greet";
            methodBuilder.defineArgument( "String" );
            methodBuilder.returnType = "void";

            //
            // An example of a name
            //
            var trace:QualifiedName = new QualifiedName( "trace", LNamespace.PUBLIC );

            //
            // CRUCIAL STEP!
            //
            methodBuilder.addOpcode( Opcode.getlocal_0 );
            methodBuilder.addOpcode( Opcode.pushscope );

            //
            // Get reference to 'trace'
            //
            methodBuilder.addOpcode( Opcode.findpropstrict, [ trace ] );

            //
            // Build our string to be traced
            //
            methodBuilder.addOpcode( Opcode.pushstring, [ "Hello "] );
            methodBuilder.addOpcode( Opcode.getlocal_1 );
            methodBuilder.addOpcode( Opcode.add );
            methodBuilder.addOpcode( Opcode.callproperty, [ trace, 1 ] );

            //
            // Return nicely
            //
            methodBuilder.addOpcode( Opcode.returnvoid );

            //
            // Load the class into memory
            //
            abcBuilder.addEventListener( Event.COMPLETE, loadedHandler );
            abcBuilder.buildAndLoad();
        }

        private function loadedHandler( event:Event ):void
        {
            var helloWorldClass:Class = Class( getDefinitionByName( "com.classes.generated.HelloWorldClass" ) );
            var helloWorldInstance:* = new helloWorldClass();
            helloWorldInstance.greet( "World!" );
            helloWorldInstance.greet( "all the people at my talk" );
        }

    }
}
