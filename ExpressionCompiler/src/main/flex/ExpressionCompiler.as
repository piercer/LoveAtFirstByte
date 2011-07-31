package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.utils.getDefinitionByName;

    import org.as3commons.bytecode.abc.AbcFile;
    import org.as3commons.bytecode.abc.Integer;
    import org.as3commons.bytecode.abc.LNamespace;
    import org.as3commons.bytecode.abc.Multiname;
    import org.as3commons.bytecode.abc.NamespaceSet;
    import org.as3commons.bytecode.abc.QualifiedName;
    import org.as3commons.bytecode.abc.enum.Opcode;
    import org.as3commons.bytecode.emit.IAbcBuilder;
    import org.as3commons.bytecode.emit.IClassBuilder;
    import org.as3commons.bytecode.emit.IMethodBuilder;
    import org.as3commons.bytecode.emit.IPackageBuilder;
    import org.as3commons.bytecode.emit.impl.AbcBuilder;
    import org.as3commons.bytecode.emit.impl.MethodArgument;
    import org.as3commons.bytecode.swf.AbcClassLoader;

    [SWF(backgroundColor="#FF0000",height="500",width="500",frameRate="60")]
    public class ExpressionCompiler extends Sprite
    {
        public function ExpressionCompiler()
        {
            var x:Number = Math.sin( 1.2 );
            var abcBuilder:IAbcBuilder = new AbcBuilder();
            var packageBuilder:IPackageBuilder = abcBuilder.definePackage( "com.classes.generated" );
            var classBuilder:IClassBuilder = packageBuilder.defineClass( "RuntimeClass" );
            var methodBuilder:IMethodBuilder = classBuilder.defineMethod( "f" );
//            var argument:MethodArgument = methodBuilder.defineArgument( "Object" );
            methodBuilder.returnType = "Number";

//            methodBuilder.addOpcode( Opcode.getlocal_0 )
//                    .addOpcode( Opcode.pushscope )
//                    .addOpcode( Opcode.getlocal_1 )
//                    .addOpcode( Opcode.dup )
//                    .addOpcode( Opcode.multiply )
//                    .addOpcode( Opcode.returnvalue );

//            var propertyName:Multiname = new Multiname( "p", new NamespaceSet( [LNamespace.PUBLIC] ) );

            var math:QualifiedName = new QualifiedName( "Math", LNamespace.PUBLIC );
            var sin:QualifiedName = new QualifiedName( "sin", LNamespace.PUBLIC );
            var cos:QualifiedName = new QualifiedName( "cos", LNamespace.PUBLIC );
            var tan:QualifiedName = new QualifiedName( "tan", LNamespace.PUBLIC );
            var converter:InfixToPostfixConverter = new InfixToPostfixConverter();
            var outputStack:TokenStack = converter.convert( '2*sin(3/cos(4+97/tan(3))' );

            methodBuilder.addOpcode( Opcode.getlocal_0 );
            methodBuilder.addOpcode( Opcode.pushscope );
//            methodBuilder.addOpcode( Opcode.findpropstrict, [math] );
//            methodBuilder.addOpcode( Opcode.getproperty, [math] );
            methodBuilder.addOpcode( Opcode.getlex, [ math ] );
//            methodBuilder.addOpcode( Opcode.getproperty, [math] );

            methodBuilder.addOpcode( Opcode.setlocal_1 );

            for each ( var token:Token in outputStack.stack )
            {
                switch ( token.type )
                {

                    case Token.NUMERIC:
                        methodBuilder.addOpcode( Opcode.pushdouble, [ new Number( token.value ) ] );
                        trace( "PushDecimal: ", token.value );
                        break;

                    case Token.FUNCTION:
                        methodBuilder.addOpcode( Opcode.getlocal_1 );
                        methodBuilder.addOpcode( Opcode.swap );

                        switch ( token.value )
                        {
                            case 'sin':
                                trace( "sin" );
                                methodBuilder.addOpcode( Opcode.callproperty, [sin,1] );
                                break;
                            case 'cos':
                                trace( "cos" );
                                methodBuilder.addOpcode( Opcode.callproperty, [cos,1] );
                                break;
                            case 'tan':
                                trace( "tan" );
                                methodBuilder.addOpcode( Opcode.callproperty, [tan,1] );
                                break;
                        }
                        break;

                    case Token.OPERATOR:
                        switch ( token.value )
                        {
                            case '*':
                                methodBuilder.addOpcode( Opcode.multiply );
                                trace( "Multiply" );
                                break;
                            case '/':
                                methodBuilder.addOpcode( Opcode.divide )
                                trace( "Divide" );
                                break;
                            case '+':
                                methodBuilder.addOpcode( Opcode.add );
                                trace( "Add" );
                                break;
                            case '-':
                                methodBuilder.addOpcode( Opcode.subtract );
                                trace( "Subtract" );
                                break;
                        }
                        break;
                }

            }
            methodBuilder.addOpcode( Opcode.returnvalue );

            var abcFile:AbcFile = abcBuilder.build();
            var abcLoader:AbcClassLoader = new AbcClassLoader();

            abcLoader.addEventListener( Event.COMPLETE, loadedHandler );
            abcLoader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
            abcLoader.addEventListener( IOErrorEvent.VERIFY_ERROR, errorHandler );

            abcLoader.loadAbcFile( abcFile );
        }

        private function errorHandler( event:IOErrorEvent ):void
        {
            trace( "ERROR: ", event.text );
        }

        private function loadedHandler( event:Event ):void
        {
            var functionClass:Class = Class( getDefinitionByName( "com.classes.generated.RuntimeClass" ) );
            var m:* = new functionClass();
            trace( m.f() );
        }
    }

}
