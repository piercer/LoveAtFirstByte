package com.bydi.patcher
{
    import flash.utils.ByteArray;

    import org.as3commons.bytecode.abc.AbcFile;
    import org.as3commons.bytecode.abc.InstanceInfo;
    import org.as3commons.bytecode.abc.LNamespace;
    import org.as3commons.bytecode.abc.MethodBody;
    import org.as3commons.bytecode.abc.MethodInfo;
    import org.as3commons.bytecode.abc.MethodTrait;
    import org.as3commons.bytecode.abc.Multiname;
    import org.as3commons.bytecode.abc.NamespaceSet;
    import org.as3commons.bytecode.abc.Op;
    import org.as3commons.bytecode.abc.QualifiedName;
    import org.as3commons.bytecode.abc.SlotOrConstantTrait;
    import org.as3commons.bytecode.abc.TraitInfo;
    import org.as3commons.bytecode.abc.enum.MultinameKind;
    import org.as3commons.bytecode.abc.enum.NamespaceKind;
    import org.as3commons.bytecode.abc.enum.Opcode;
    import org.as3commons.bytecode.abc.enum.TraitKind;
    import org.as3commons.bytecode.io.AbcDeserializer;
    import org.as3commons.bytecode.io.AbcSerializer;
    import org.as3commons.bytecode.tags.DoABCTag;
    import org.as3commons.bytecode.typeinfo.Argument;
    import org.as3commons.bytecode.typeinfo.Metadata;
    import org.as3commons.bytecode.util.MultinameUtil;
    import org.mixingloom.SwfContext;
    import org.mixingloom.SwfTag;
    import org.mixingloom.invocation.InvocationType;
    import org.mixingloom.patcher.AbstractPatcher;

    public class DIPatcher extends AbstractPatcher
    {

        public function DIPatcher()
        {
        }

        override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void
        {

            var metadata:Metadata;
            //var methodInfo:MethodInfo;

            for each ( var swfTag:SwfTag in swfContext.swfTags )
            {
                if ( swfTag.type == DoABCTag.TAG_ID )
                {

                    swfTag.tagBody.position = 4;

                    var abcStartLocation:uint = 4;
                    while ( swfTag.tagBody.readByte() != 0 )
                    {
                        abcStartLocation++;
                    }
                    abcStartLocation++;

                    swfTag.tagBody.position = 0;

                    var abcDeserializer:AbcDeserializer = new AbcDeserializer( swfTag.tagBody );

                    var abcFile:AbcFile = abcDeserializer.deserialize( abcStartLocation );


                    for each ( var instanceInfo:InstanceInfo in abcFile.instanceInfo )
                    {
                        //
                        // Find if there are any injected properties or methods
                        //
                        var injectedTraits:Vector.<TraitInfo> = new Vector.<TraitInfo>();
                        for each ( var traitInfo:SlotOrConstantTrait in instanceInfo.slotOrConstantTraits )
                        {
                            for each ( metadata in traitInfo.metadata )
                            {
                                if ( metadata.name == "Inject" )
                                {
                                    injectedTraits.push( traitInfo );
                                }
                            }
                        }
                        for each ( var setterInfo:MethodTrait in instanceInfo.setterTraits )
                        {
                            for each ( metadata in setterInfo.metadata )
                            {
                                if ( metadata.name == "Inject" )
                                {
                                    injectedTraits.push( setterInfo );
                                }
                            }
                        }
                        //
                        // If there are then inject the DI code into the class
                        //
                        if ( injectedTraits.length > 0 )
                        {
                            InsertCallToInjectionMethodInConstructor( instanceInfo, swfTag );
                            insertInjectionMethodInBodyOfClass( instanceInfo, injectedTraits, swfTag, abcFile, abcStartLocation );
                        }

                    }

                }

            }

            invokeCallBack();
        }

        private function InsertCallToInjectionMethodInConstructor( instanceInfo:InstanceInfo, swfTag:SwfTag ):MethodInfo
        {

            var injectNamespace:LNamespace = MultinameUtil.toLNamespace( swfTag.name, NamespaceKind.PRIVATE_NAMESPACE );
            var inject:QualifiedName = new QualifiedName( "inject", injectNamespace );
            var methodInfo:MethodInfo = instanceInfo.constructor;
            var startIndex:uint = 0;

            for each ( var op:Op in methodInfo.methodBody.opcodes )
            {
                startIndex++;
                if ( op.opcode === Opcode.pushscope )
                {
                    break;
                }
            }
            var thisOp:Op = new Op( Opcode.getlocal_0 );
            var callOp:Op = new Op( Opcode.callproperty, [ inject, 0 ] );
            methodInfo.methodBody.opcodes.splice( startIndex, 0, thisOp, callOp, new Op( Opcode.pop ) );
            return methodInfo;
        }

        private function insertInjectionMethodInBodyOfClass( instanceInfo:InstanceInfo, injectedTraits:Vector.<TraitInfo>, swfTag:SwfTag, abcFile:AbcFile, abcStartLocation:int ):void
        {
            var injectionOpcodes:Array = [];

            var facadePackage:LNamespace = MultinameUtil.toLNamespace( "com.bydi.facade.Facade", NamespaceKind.PACKAGE_NAMESPACE );
            var facade:QualifiedName = new QualifiedName( "Facade", facadePackage );

            var injectorPackage:LNamespace = MultinameUtil.toLNamespace( "org.swiftsuspenders.Injector", NamespaceKind.PACKAGE_NAMESPACE );
            var findMyInjector:QualifiedName = new QualifiedName( "findMyInjector", LNamespace.PUBLIC );
            var getInstance:QualifiedName = new QualifiedName( "getInstance", LNamespace.PUBLIC );

            var injector:QualifiedName = new QualifiedName( "injector", LNamespace.PUBLIC );

            var injectNamespace:LNamespace = MultinameUtil.toLNamespace( swfTag.name, NamespaceKind.PRIVATE_NAMESPACE );
            var inject:QualifiedName = new QualifiedName( "inject", injectNamespace );


            //
            // Using Static Facade
            //

            injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
            injectionOpcodes.push( new Op( Opcode.pushscope ) );

            injectionOpcodes.push( new Op( Opcode.getlex, [ facade ] ) );
            injectionOpcodes.push( new Op( Opcode.getproperty, [ injector ] ) );
            injectionOpcodes.push( new Op( Opcode.setlocal_1 ) );

            for each ( var traitInfo:TraitInfo in injectedTraits )
            {
                if ( traitInfo is SlotOrConstantTrait )
                {
                    var propertyTrait:SlotOrConstantTrait = SlotOrConstantTrait( traitInfo );
                    injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
                    injectionOpcodes.push( new Op( Opcode.getlocal_1 ) );
                    injectionOpcodes.push( new Op( Opcode.getlex, [ propertyTrait.typeMultiname ] ) );
                    injectionOpcodes.push( new Op( Opcode.callproplex, [ getInstance, 1 ] ) );
                    injectionOpcodes.push( new Op( Opcode.initproperty, [ propertyTrait.traitMultiname ] ) );
                }
                else if ( traitInfo is MethodTrait )
                {
                    var methodTrait:MethodTrait = MethodTrait( traitInfo );
                    if ( methodTrait.isSetter )
                    {
                        var argument:Argument = methodTrait.traitMethod.formalParameters[0];
                        injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
                        injectionOpcodes.push( new Op( Opcode.getlocal_1 ) );
                        injectionOpcodes.push( new Op( Opcode.getlex, [ argument.type ] ) );
                        injectionOpcodes.push( new Op( Opcode.callproplex, [ getInstance, 1 ] ) );
                        injectionOpcodes.push( new Op( Opcode.initproperty, [ methodTrait.traitMultiname ] ) );
                    }
                }
            }
            injectionOpcodes.push( new Op( Opcode.returnvoid ) );


            var method:MethodTrait = new MethodTrait();
            var methodBody:MethodBody = new MethodBody();
            var methodInfo:MethodInfo = new MethodInfo();

            methodBody.opcodes = injectionOpcodes;
            methodBody.maxStack = 4;
            methodBody.localCount = 2;
            methodBody.initScopeDepth = 4;
            methodBody.maxScopeDepth = 6;

            methodInfo.methodName = swfTag.name + "/inject";
            methodInfo.returnType = new QualifiedName( "void", LNamespace.PUBLIC );
            methodInfo.methodBody = methodBody;
            methodBody.methodSignature = methodInfo;

            methodInfo.as3commonsBytecodeName = inject;

            method.traitMethod = methodInfo;
            method.traitMultiname = methodInfo.as3commonsBytecodeName;
            method.traitKind = TraitKind.METHOD;

            instanceInfo.addTrait( method );
            abcFile.addMethodBody( methodBody );
            abcFile.addMethodInfo( methodInfo );

            trace(abcFile);
            //
            // Write back the modified bytecode
            //
            var abcSerializer:AbcSerializer = new AbcSerializer();
            var modifiedBytes:ByteArray = new ByteArray();
            modifiedBytes.writeBytes( swfTag.tagBody, 0, abcStartLocation );
            modifiedBytes.writeBytes( abcSerializer.serializeAbcFile( abcFile ) );

            swfTag.tagBody = modifiedBytes;

        }

        private static const _trace:QualifiedName = new QualifiedName( "trace", LNamespace.PUBLIC );
        private function traceTopOfStack( opCodes:Array ):void
        {
            opCodes.push( new Op( Opcode.dup ) );
            opCodes.push( new Op( Opcode.findpropstrict, [ _trace ] ) );
            opCodes.push( new Op( Opcode.swap ) );
            opCodes.push( new Op( Opcode.callproperty, [ _trace, 1 ] ) );
            opCodes.push( new Op( Opcode.pop ) );
        }


    }
}


//
//
//
//package com.bydi.patcher
//{
//    import com.demonsters.debugger.MonsterDebugger;
//
//    import flash.utils.ByteArray;
//    import flash.utils.Endian;
//
//    import org.as3commons.bytecode.abc.AbcFile;
//    import org.as3commons.bytecode.abc.InstanceInfo;
//    import org.as3commons.bytecode.abc.JumpTargetData;
//    import org.as3commons.bytecode.abc.LNamespace;
//    import org.as3commons.bytecode.abc.MethodBody;
//    import org.as3commons.bytecode.abc.MethodInfo;
//    import org.as3commons.bytecode.abc.MethodTrait;
//    import org.as3commons.bytecode.abc.Op;
//    import org.as3commons.bytecode.abc.QualifiedName;
//    import org.as3commons.bytecode.abc.SlotOrConstantTrait;
//    import org.as3commons.bytecode.abc.TraitInfo;
//    import org.as3commons.bytecode.abc.enum.NamespaceKind;
//    import org.as3commons.bytecode.abc.enum.Opcode;
//    import org.as3commons.bytecode.abc.enum.TraitKind;
//    import org.as3commons.bytecode.emit.impl.NamespaceBuilder;
//    import org.as3commons.bytecode.io.AbcDeserializer;
//    import org.as3commons.bytecode.io.AbcSerializer;
//    import org.as3commons.bytecode.tags.DoABCTag;
//    import org.as3commons.bytecode.typeinfo.Argument;
//    import org.as3commons.bytecode.typeinfo.Metadata;
//    import org.as3commons.bytecode.util.AbcSpec;
//    import org.as3commons.bytecode.util.MultinameUtil;
//    import org.mixingloom.SwfContext;
//    import org.mixingloom.SwfTag;
//    import org.mixingloom.invocation.InvocationType;
//    import org.mixingloom.patcher.AbstractPatcher;
//
//    import namespaces.robotlegs;
//    robotlegs;
//
//    public class DIPatcher extends AbstractPatcher
//    {
//
//        public function DIPatcher()
//        {
//            MonsterDebugger.initialize( this );
//            MonsterDebugger.trace( this, "DI Patcher Created" );
//        }
//
//        override public function apply( invocationType:InvocationType, swfContext:SwfContext ):void
//        {
//
//            var metadata:Metadata;
//            //var methodInfo:MethodInfo;
//
//            MonsterDebugger.trace( this, "InvocationType: "+invocationType.type );
//            MonsterDebugger.trace( this, "SwfContext: "+swfContext );
//
//            for each ( var swfTag:SwfTag in swfContext.swfTags )
//            {
//                if ( swfTag.type == DoABCTag.TAG_ID )
//                {
//
//                    swfTag.tagBody.position = 4;
//
//                    var abcStartLocation:uint = 4;
//                    while ( swfTag.tagBody.readByte() != 0 )
//                    {
//                        abcStartLocation++;
//                    }
//                    abcStartLocation++;
//
//                    swfTag.tagBody.position = 0;
//                    //swfTag.tagBody.endian = Endian.LITTLE_ENDIAN;
//
//                    var abcDeserializer:AbcDeserializer = new AbcDeserializer( swfTag.tagBody );
//
//                    var abcFile:AbcFile = abcDeserializer.deserialize( abcStartLocation );
//
//                    for each ( var instanceInfo:InstanceInfo in abcFile.instanceInfo )
//                    {
//                        //
//                        // Find if there are any injected properties or methods
//                        //
//                        var traitsToInject:Vector.<TraitInfo> = new Vector.<TraitInfo>();
//                        for each ( var traitInfo:SlotOrConstantTrait in instanceInfo.slotOrConstantTraits )
//                        {
//                            for each ( metadata in traitInfo.metadata )
//                            {
//                                if ( metadata.name == "Inject" )
//                                {
//                                    traitsToInject.push( traitInfo );
//                                }
//                            }
//                        }
//                        for each ( var setterInfo:MethodTrait in instanceInfo.setterTraits )
//                        {
//                            for each ( metadata in setterInfo.metadata )
//                            {
//                                if ( metadata.name == "Inject" )
//                                {
//                                    traitsToInject.push( setterInfo );
//                                }
//                            }
//                        }
//
//                        //
//                        // If there are then inject the DI code into the class
//                        //
//                        if ( traitsToInject.length > 0 )
//                        {
//                            insertCallToInjectionMethodInConstructor( instanceInfo, swfTag );
//                            insertInjectionMethodInBodyOfClass( instanceInfo, traitsToInject, swfTag, abcFile );
//
//                            //
//                            // Write back the modified bytecode
//                            //
//                            var abcSerializer:AbcSerializer = new AbcSerializer();
//                            var modifiedBytes:ByteArray = AbcSpec.newByteArray();
//                            modifiedBytes.writeBytes( swfTag.tagBody, 0, abcStartLocation );
//                            modifiedBytes.writeBytes( abcSerializer.serializeAbcFile( abcFile ) );
//
//                            swfTag.tagBody = modifiedBytes;
//
//                            //
//                            //_______________________DEBUG_______________________
//                            //
////                            for each ( var methodBody:MethodBody in abcFile.methodBodies )
////                            {
////                                if ( methodBody.methodSignature.methodName == "partAdded" )
////                                {
////                                    MonsterDebugger.trace( this, "MessageBody length 1: "+methodBody.opcodes.length );
////                                    for each (var b:JumpTargetData in methodBody.backPatches)
////                                    {
////                                        MonsterDebugger.trace( this, "j:"+b.jumpOpcode+" >>> "+b.targetOpcode );
////                                    }
//////                                    MonsterDebugger.trace( this, methodBody.toString() );
////                                }
////                            }
////
////                            var abcDeserializer2:AbcDeserializer = new AbcDeserializer( modifiedBytes );
////
////                            var abcFile2:AbcFile = abcDeserializer2.deserialize( abcStartLocation );
////
////                            for each ( var methodBody:MethodBody in abcFile2.methodBodies )
////                            {
////                                if ( methodBody.methodSignature.methodName == "partAdded" )
////                                {
////                                    MonsterDebugger.trace( this, "MessageBody length 2: "+methodBody.opcodes.length );
////                                    for each (var b:JumpTargetData in methodBody.backPatches)
////                                    {
////                                        MonsterDebugger.trace( this, "j:"+b.jumpOpcode+" >>> "+b.targetOpcode );
////                                    }
//////                                    MonsterDebugger.trace( this, methodBody.toString() );
////                                }
////                            }
//
//                            //_________________________________________
//                            //
//                        }
//
//
//                    }
//
//
//                }
//
//            }
//
//            invokeCallBack();
//        }
//
//        private function insertCallToInjectionMethodInConstructor( instanceInfo:InstanceInfo, swfTag:SwfTag ):MethodInfo
//        {
//            //
//            // Insert a call to private::inject() before the super constructor
//            //
//            var injectNamespace:LNamespace = MultinameUtil.toLNamespace( swfTag.name, NamespaceKind.PRIVATE_NAMESPACE );
//            var inject:QualifiedName = new QualifiedName( "inject", injectNamespace );
//            var methodInfo:MethodInfo = instanceInfo.constructor;
//            var startIndex:uint = 0;
//
//            for each ( var op:Op in methodInfo.methodBody.opcodes )
//            {
//                startIndex++;
//                if ( op.opcode === Opcode.pushscope )
//                {
//                    break;
//                }
//            }
//            var thisOp:Op = new Op( Opcode.getlocal_0 );
//            var callOp:Op = new Op( Opcode.callpropvoid, [ inject, 0 ] );
//            methodInfo.methodBody.opcodes.splice( startIndex, 0, thisOp, callOp );
//            return methodInfo;
//        }
//
//        private function insertInjectionMethodInBodyOfClass( instanceInfo:InstanceInfo, traitsToInject:Vector.<TraitInfo>, swfTag:SwfTag, abcFile:AbcFile ):void
//        {
//            var injectionOpcodes:Array = [];
//
//            var facadePackage:LNamespace = MultinameUtil.toLNamespace( "com.bydi.facade.Facade", NamespaceKind.PACKAGE_NAMESPACE );
//            var facade:QualifiedName = new QualifiedName( "Facade", facadePackage );
//
//            var robotlegsPackage:LNamespace = MultinameUtil.toLNamespace( "namespaces", NamespaceKind.PACKAGE_NAMESPACE );
//            var robotlegs:QualifiedName = new QualifiedName( "robotlegs", robotlegsPackage );
//            var robotlegsNamespace:LNamespace = new LNamespace(NamespaceKind.NAMESPACE, "robotlegs");
//
//            var injector:QualifiedName = new QualifiedName( "injector", LNamespace.PUBLIC );
//            var getInstance:QualifiedName = new QualifiedName( "getInstance", LNamespace.PUBLIC );
//
//            var injectNamespace:LNamespace = MultinameUtil.toLNamespace( swfTag.name, NamespaceKind.PRIVATE_NAMESPACE );
//            var inject:QualifiedName = new QualifiedName( "inject", injectNamespace );
//
//
//            //injectionOpcodes.push( new Op( Opcode.getlex, [ facade ] ) );
//            //injectionOpcodes.push( new Op( Opcode.getproperty, [ injector ] ) );
//            //injectionOpcodes.push( new Op( Opcode.setlocal_1 ) );
//
//            //injectionOpcodes.push( new Op( Opcode.pushnamespace, [ robotlegsNamespace ] ) );
//            //injectionOpcodes.push( new Op( Opcode.getlex, [ robotlegs ] ) );
//            //injectionOpcodes.push( new Op( Opcode.getproperty, [ robotlegs ] ) );
//            //injectionOpcodes.push( new Op( Opcode.findpropstrict, [ injector ] ) );
//            //injectionOpcodes.push( new Op( Opcode.getproperty, [ injector ] ) );
//            //injectionOpcodes.push( new Op( Opcode.setlocal_1 ) );
//
//
//            //
//            // Using getouterscope
//            //
//            injectionOpcodes.push( new Op( Opcode.getouterscope ) );
//            injectionOpcodes.push( new Op( Opcode.pushscope ) );
//            //injectionOpcodes.push( new Op( Opcode.getlex, [ injector ] ) );
//            //injectionOpcodes.push( new Op( Opcode.setlocal_1 ) );
//            injectionOpcodes.push( new Op( Opcode.popscope ) );
//
//            injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
//            injectionOpcodes.push( new Op( Opcode.pushscope ) );
//
//            for each ( var traitInfo:TraitInfo in traitsToInject )
//            {
//                if ( traitInfo is SlotOrConstantTrait )
//                {
//                    var propertyTrait:SlotOrConstantTrait = SlotOrConstantTrait( traitInfo );
//                    injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
//                    injectionOpcodes.push( new Op( Opcode.getlocal_1 ) );
//                    injectionOpcodes.push( new Op( Opcode.getlex, [propertyTrait.typeMultiname] ) );
//                    injectionOpcodes.push( new Op( Opcode.callproplex, [ getInstance, 1 ] ) );
//                    injectionOpcodes.push( new Op( Opcode.initproperty, [ propertyTrait.traitMultiname ] ) );
//                }
//                else if ( traitInfo is MethodTrait )
//                {
//                    var methodTrait:MethodTrait = MethodTrait( traitInfo );
//                    if ( methodTrait.isSetter )
//                    {
//                        var argument:Argument = methodTrait.traitMethod.formalParameters[0];
//                        injectionOpcodes.push( new Op( Opcode.getlocal_0 ) );
//                        injectionOpcodes.push( new Op( Opcode.getlocal_1 ) );
//                        injectionOpcodes.push( new Op( Opcode.getlex, [ argument.type ] ) );
//                        injectionOpcodes.push( new Op( Opcode.callproplex, [ getInstance, 1 ] ) );
//                        injectionOpcodes.push( new Op( Opcode.initproperty, [ methodTrait.traitMultiname ] ) );
//                    }
//                }
//            }
//            injectionOpcodes.push( new Op( Opcode.returnvoid ) );
//
//
//            var method:MethodTrait = new MethodTrait();
//            var methodBody:MethodBody = new MethodBody();
//            var methodInfo:MethodInfo = new MethodInfo();
//
//            methodBody.opcodes = injectionOpcodes;
//            methodBody.maxStack = 3;
//            methodBody.localCount = 2;
//            methodBody.initScopeDepth = 4;
//            methodBody.maxScopeDepth = 5;
//
//            methodInfo.methodName = "inject";
//            methodInfo.returnType = new QualifiedName( "void", LNamespace.PUBLIC );
//            methodInfo.methodBody = methodBody;
//            methodBody.methodSignature = methodInfo;
//
//            methodInfo.as3commonsBytecodeName = inject;
//            //methodInfo.as3commonsByteCodeAssignedMethodTrait = method;
//
//            method.traitMethod = methodInfo;
//            method.traitMultiname = methodInfo.as3commonsBytecodeName;
//            method.traitKind = TraitKind.METHOD;
//
//            instanceInfo.addTrait( method );
//            //instanceInfo.traits.splice( 0,0,method);
//            //abcFile.methodBodies.splice(abcFile.methodBodies.length-1,0,methodBody);
//            abcFile.addMethodBody( methodBody );
//            abcFile.addMethodInfo( methodInfo );
//            //abcFile.methodInfo.splice(abcFile.methodInfo.length-1,0,methodInfo);
//
//        }
//
//
//        public function encode( ba:ByteArray ):String
//        {
//            //var ba:ByteArray = new ByteArray();
//            //ba.writeUTFBytes(value);
//            var len:uint = ba.length;
//            var s:String = "";
//            for ( var i:uint = 0; i < len; i++ )
//            {
//                s += ba[i].toString( 16 );
//            }
//            return s;
//        }
//
//
//    }
//}
//
