package com.dz015.expressions.compilers
{

    import com.dz015.expressions.shuntyard.InfixToPostfixConverter;
    import com.dz015.expressions.tokens.IExpressionTokeniser;
    import com.dz015.expressions.tokens.Token;
    import com.dz015.expressions.tokens.TokenStack;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.utils.getDefinitionByName;

    import org.as3commons.bytecode.abc.LNamespace;
    import org.as3commons.bytecode.abc.MultinameL;
    import org.as3commons.bytecode.abc.NamespaceSet;
    import org.as3commons.bytecode.abc.QualifiedName;
    import org.as3commons.bytecode.abc.enum.MultinameKind;
    import org.as3commons.bytecode.abc.enum.Opcode;
    import org.as3commons.bytecode.emit.IAbcBuilder;
    import org.as3commons.bytecode.emit.IClassBuilder;
    import org.as3commons.bytecode.emit.IMethodBuilder;
    import org.as3commons.bytecode.emit.impl.AbcBuilder;

    [Event(name="compileComplete", type="com.dz015.expressions.compilers.CompilerEvent")]
    public class FilterFunctionCompiler extends EventDispatcher
    {

        private static var _classNumber:uint = 0;

        public function FilterFunctionCompiler()
        {

        }

        public function compile( expression:String, tokeniser:IExpressionTokeniser ):void
        {

            var abcBuilder:IAbcBuilder = new AbcBuilder();
            var classBuilder:IClassBuilder = abcBuilder.definePackage( "com.classes.generated" ).defineClass( "FilterClass" + _classNumber );

            var methodBuilder:IMethodBuilder = classBuilder.defineMethod();
            methodBuilder.name = "filterFunction";
            methodBuilder.defineArgument( "Object" );
            methodBuilder.returnType = "Boolean";

            var math:QualifiedName = new QualifiedName( "Math", LNamespace.PUBLIC );
            var sin:QualifiedName = new QualifiedName( "sin", LNamespace.PUBLIC );
            var cos:QualifiedName = new QualifiedName( "cos", LNamespace.PUBLIC );
            var tan:QualifiedName = new QualifiedName( "tan", LNamespace.PUBLIC );
            var pow:QualifiedName = new QualifiedName( "pow", LNamespace.PUBLIC );

            var publicPropertyLate:MultinameL = new MultinameL( new NamespaceSet( [ LNamespace.PUBLIC ] ), MultinameKind.MULTINAME_L );

            var converter:InfixToPostfixConverter = new InfixToPostfixConverter( tokeniser );
            var outputStack:TokenStack = converter.convert( expression );

            methodBuilder.addOpcode( Opcode.getlocal_0 );
            methodBuilder.addOpcode( Opcode.pushscope );
            methodBuilder.addOpcode( Opcode.getlex, [ math ] );
            methodBuilder.addOpcode( Opcode.setlocal_2 );

            for each ( var token:Token in outputStack.stack )
            {
                switch ( token.type )
                {
                    case Token.SYMBOL:
                        methodBuilder.addOpcode( Opcode.getlocal_1 );
                        methodBuilder.addOpcode( Opcode.pushstring, [ token.value ] );
                        methodBuilder.addOpcode( Opcode.getproperty, [ publicPropertyLate ] );
                        break;

                    case Token.NUMERIC:
                        methodBuilder.addOpcode( Opcode.pushdouble, [ new Number( token.value ) ] );
                        break;

                    case Token.FUNCTION:
                        methodBuilder.addOpcode( Opcode.getlocal_2 );
                        methodBuilder.addOpcode( Opcode.swap );

                        switch ( token.value )
                        {

                            case 'sin':
                                methodBuilder.addOpcode( Opcode.callproperty, [sin,1] );
                                break;
                            case 'cos':
                                methodBuilder.addOpcode( Opcode.callproperty, [cos,1] );
                                break;
                            case 'tan':
                                methodBuilder.addOpcode( Opcode.callproperty, [tan,1] );
                                break;
                        }
                        break;

                    case Token.OPERATOR:
                        switch ( token.value )
                        {
                            case '^':
                                methodBuilder.addOpcode( Opcode.setlocal_3 );
                                methodBuilder.addOpcode( Opcode.setlocal, [4] );
                                methodBuilder.addOpcode( Opcode.getlocal_2 );
                                methodBuilder.addOpcode( Opcode.getlocal, [4] );
                                methodBuilder.addOpcode( Opcode.getlocal_3 );
                                methodBuilder.addOpcode( Opcode.callproperty, [pow,2] );
                                break;

                            case '*':
                                methodBuilder.addOpcode( Opcode.multiply );
                                break;
                            case '/':
                                methodBuilder.addOpcode( Opcode.divide )
                                break;
                            case '+':
                                methodBuilder.addOpcode( Opcode.add );
                                break;
                            case '-':
                                methodBuilder.addOpcode( Opcode.subtract );
                                break;
                            case '<':
                                methodBuilder.addOpcode( Opcode.lessthan );
                                break;
                            case '>':
                                methodBuilder.addOpcode( Opcode.greaterthan );
                                break;
                            case '<=':
                                methodBuilder.addOpcode( Opcode.lessequals );
                                break;
                            case '>=':
                                methodBuilder.addOpcode( Opcode.greaterequals );
                                break;
                            case '=':
                                methodBuilder.addOpcode( Opcode.equals );
                                break;
                            case '&':
                                methodBuilder.addOpcode( Opcode.bitand );
                                break;
                            case '|':
                                methodBuilder.addOpcode( Opcode.bitor );
                                break;
                        }
                        break;
                }

            }
            methodBuilder.addOpcode( Opcode.returnvalue );

            abcBuilder.addEventListener( Event.COMPLETE, loadedHandler );
            abcBuilder.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
            abcBuilder.addEventListener( IOErrorEvent.VERIFY_ERROR, errorHandler );

            abcBuilder.buildAndLoad();
        }

        private function errorHandler( event:IOErrorEvent ):void
        {
            trace( "ERROR: ", event.text );
        }

        private function loadedHandler( event:Event ):void
        {
            dispatchEvent( new CompilerEvent( CompilerEvent.COMPILE_COMPLETE, Class( getDefinitionByName( "com.classes.generated.FilterClass" + _classNumber++ ) ) ) );
        }
    }

}
