/*
 * Copyright (c) 2009-2010 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
    import flash.system.ApplicationDomain;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    import org.swiftsuspenders.injectionresults.InjectClassResult;
    import org.swiftsuspenders.injectionresults.InjectOtherRuleResult;
    import org.swiftsuspenders.injectionresults.InjectSingletonResult;
    import org.swiftsuspenders.injectionresults.InjectValueResult;

    public class Injector
    {

        private static var injectors:Dictionary;

        /*******************************************************************************************
         *                                private properties                                           *
         *******************************************************************************************/
        private var m_parentInjector:Injector;
        private var m_applicationDomain:ApplicationDomain;
        private var m_mappings:Dictionary;
        private var m_attendedToInjectees:Dictionary;

        /*******************************************************************************************
         *                                public methods                                               *
         *******************************************************************************************/
        public function Injector( xmlConfig:XML = null )
        {
            m_mappings = new Dictionary();
            injectors = new Dictionary();
        }

        public function mapValue( whenAskedFor:Class, useValue:Object, named:String = "" ):*
        {
            var config:InjectionConfig = getMapping( whenAskedFor, named );
            config.setResult( new InjectValueResult( useValue ) );
            return config;
        }

        public function mapClass( whenAskedFor:Class, instantiateClass:Class, named:String = "" ):*
        {
            var config:InjectionConfig = getMapping( whenAskedFor, named );
            config.setResult( new InjectClassResult( instantiateClass ) );
            return config;
        }

        public function mapSingleton( whenAskedFor:Class, named:String = "" ):*
        {
            return mapSingletonOf( whenAskedFor, whenAskedFor, named );
        }

        public function mapSingletonOf( whenAskedFor:Class, useSingletonOf:Class, named:String = "" ):*
        {
            var config:InjectionConfig = getMapping( whenAskedFor, named );
            config.setResult( new InjectSingletonResult( useSingletonOf ) );
            return config;
        }

        public function mapRule( whenAskedFor:Class, useRule:*, named:String = "" ):*
        {
            var config:InjectionConfig = getMapping( whenAskedFor, named );
            config.setResult( new InjectOtherRuleResult( useRule ) );
            return useRule;
        }

        public function getMapping( whenAskedFor:Class, named:String = "" ):InjectionConfig
        {
            var requestName:String = getQualifiedClassName( whenAskedFor );
            var config:InjectionConfig = m_mappings[requestName + '#' + named];
            if ( !config )
            {
                config = m_mappings[requestName + '#' + named] =
                        new InjectionConfig( whenAskedFor, named );
            }
            return config;
        }

        public function instantiate( clazz:Class ):*
        {
            return new clazz();
        }

        public function unmap( clazz:Class, named:String = "" ):void
        {
            var mapping:InjectionConfig = getConfigurationForRequest( clazz, named );
            if ( !mapping )
            {
                throw new InjectorError( 'Error while removing an injector mapping: ' +
                        'No mapping defined for class ' + getQualifiedClassName( clazz ) +
                        ', named "' + named + '"' );
            }
            mapping.setResult( null );
        }

        public function hasMapping( clazz:Class, named:String = '' ):Boolean
        {
            var mapping:InjectionConfig = getConfigurationForRequest( clazz, named );
            if ( !mapping )
            {
                return false;
            }
            return mapping.hasResponse( this );
        }

        public function getInstance( clazz:Class, named:String = '' ):*
        {
            var mapping:InjectionConfig = getConfigurationForRequest( clazz, named );
            if ( !mapping || !mapping.hasResponse( this ) )
            {
                throw new InjectorError( 'Error while getting mapping response: ' +
                        'No mapping defined for class ' + getQualifiedClassName( clazz ) +
                        ', named "' + named + '"' );
            }
            return mapping.getResponse( this );
        }

        public function createChildInjector( applicationDomain:ApplicationDomain = null ):Injector
        {
            var injector:Injector = new Injector();
            injector.setApplicationDomain( applicationDomain );
            injector.setParentInjector( this );
            return injector;
        }

        public function setApplicationDomain( applicationDomain:ApplicationDomain ):void
        {
            m_applicationDomain = applicationDomain;
        }

        public function getApplicationDomain():ApplicationDomain
        {
            return m_applicationDomain ? m_applicationDomain : ApplicationDomain.currentDomain;
        }

        public function setParentInjector( parentInjector:Injector ):void
        {
            //restore own map of worked injectees if parent injector is removed
            if ( m_parentInjector && !parentInjector )
            {
                m_attendedToInjectees = new Dictionary( true );
            }
            m_parentInjector = parentInjector;
            //use parent's map of worked injectees
            if ( parentInjector )
            {
                m_attendedToInjectees = parentInjector.attendedToInjectees;
            }
        }

        public function getParentInjector():Injector
        {
            return m_parentInjector;
        }

        internal function getAncestorMapping( whenAskedFor:Class, named:String = null ):InjectionConfig
        {
            var parent:Injector = m_parentInjector;
            while ( parent )
            {
                var parentConfig:InjectionConfig =
                        parent.getConfigurationForRequest( whenAskedFor, named, false );
                if ( parentConfig && parentConfig.hasOwnResponse() )
                {
                    return parentConfig;
                }
                parent = parent.getParentInjector();
            }
            return null;
        }

        internal function get attendedToInjectees():Dictionary
        {
            return m_attendedToInjectees;
        }

        private function getConfigurationForRequest( clazz:Class, named:String, traverseAncestors:Boolean = true ):InjectionConfig
        {
            var requestName:String = getQualifiedClassName( clazz );
            var config:InjectionConfig = m_mappings[requestName + '#' + named];
            if ( !config && traverseAncestors &&
                    m_parentInjector && m_parentInjector.hasMapping( clazz, named ) )
            {
                config = getAncestorMapping( clazz, named );
            }
            return config;
        }

        public static function createInjectorFor( root:Object ):Injector
        {
            var injector:Injector = new Injector();
            injectors[root] = injector;
            return injector;
        }

        public static function findMyInjector( injectee:Object ):Injector
        {
            for ( var root:Object in injectors )
            {
//                if ( root.hasOwnProperty( injectee ) )
//                {
//                    return injectors[ root ];
//                }
                for each ( var member:Object in root )
                {
                    if ( member == injectee )
                    {
                        return injectors[ root ];
                    }
                }
            }
            return null;
        }

    }
}
