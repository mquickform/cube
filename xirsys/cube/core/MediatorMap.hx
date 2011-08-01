/**
 * Copyright (c) 2011, Influxis.
 * 
 * support@influxis.com
 * 
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY INFLUXIS "AS IS" AND ANY EXPRESS OR IMPLIED 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL INFLUXIS OR THEIR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 * 
 * @author Lee Sylvester
 **/

package xirsys.cube.core;

import xirsys.cube.events.CentralDispatcher;
import xirsys.injector.Injector;

import xirsys.cube.abstract.IMediatorMap;
import xirsys.cube.abstract.IMediator;

typedef MappingConfig<T> = {
	mediatorClass : Class<IMediator>,
	typedViewClasses : Array<Class<T>>,
	autoCreate : Bool,
	autoRemove : Bool
}

typedef MediatorViewPair<T> = {
	mediator : IMediator,
	view : T
}

class MediatorMap<T,E> extends MapBase<T>, implements IMediatorMap<T> {
	
	private var mappingConfigByViewClassName : Hash<MappingConfig<T>>;
	private var mediatorByView : Array<MediatorViewPair<T>>;
	private var mediatorsMarkedForRemoval : Array<T>;
	
	public var eventDispatcher : CentralDispatcher<E>;
	
	public function new( container : T, eventDispatcher : CentralDispatcher<E>, injector : Injector )
	{
		super( container, injector );
		this.eventDispatcher = eventDispatcher;
		this.mappingConfigByViewClassName = new Hash();
		this.mediatorByView = new Array();
	}
	
	public function mapView( viewClass : Class<T>, mediatorClass : Class<IMediator>, ?autoCreate : Bool = true, ?autoRemove : Bool = true )
	{
		var viewClassName : String = Type.getClassName( viewClass );
		var config : MappingConfig<T> = { 
			mediatorClass : mediatorClass, 
			autoCreate : autoCreate,
			autoRemove : autoRemove,
			typedViewClasses : [ viewClass ]
		}
		mappingConfigByViewClassName.set( viewClassName, config );
		if ( autoCreate && container != null && ( viewClassName == Type.getClassName( Type.getClass( container ) ) ) )
		{
			createMediator( container );
		}
		activate();
	}
	
	public function unmapView( viewClass : Class<T> )
	{
		var viewClassName : String = Type.getClassName( viewClass ); 
		mappingConfigByViewClassName.remove( viewClassName );
	}
	
	public function createMediator( viewComponent : T ) : IMediator
	{
		var mediator : IMediator = getMediatorByView( viewComponent );
		if ( mediator == null )
		{
			var viewClassName : String = Type.getClassName( Type.getClass( viewComponent ) );
			var config : MappingConfig<T> = mappingConfigByViewClassName.get( viewClassName );
			if ( config != null )
			{
				for ( cls in config.typedViewClasses )
				try
				{
					injector.mapInstance( cls, viewComponent );
					mediator = injector.instantiate( config.mediatorClass );
				}
				catch( e : xirsys.injector.exceptions.InjectorException )
				{
					trace( e.msg );
				}
				for ( cls in config.typedViewClasses )
					injector.unmap( cls );
				registerMediator( viewComponent, mediator );
			}
		}
		// TODO: hack, due to injector anomalie.  MUST FIX!
		if ( mediator != null )
			mediator.mediatorMap = this;
		return mediator;
	}
	
	public function registerMediator( viewComponent : T, mediator : IMediator )
	{
		injector.mapInstance( Type.getClass( mediator ), mediator );
		setMediatorByView( viewComponent, mediator );
		mediator.setViewComponent( viewComponent );
		mediator.preRegister();
	}
	
	public function removeMediator( mediator : IMediator ) : IMediator
	{
		if ( mediator != null )
		{
			var viewComponent : T = mediator.getViewComponent();
			deleteMediatorByView( viewComponent );
			mappingConfigByViewClassName.remove( Type.getClassName( Type.getClass( viewComponent ) ) );
			mediator.preRemove();
			mediator.setViewComponent( null );
			injector.unmap( Type.getClass( mediator ) );
		}
		return mediator;
	}
	
	public function removeMediatorByView( viewComponent : T ) : IMediator
	{
		return removeMediator( retrieveMediator( viewComponent ) );
	}
	
	public function retrieveMediator( viewComponent : T ) : IMediator
	{
		return getMediatorByView( viewComponent );
	}
	
	public function hasMediatorForView( viewComponent : T ) : Bool
	{
		return getMediatorByView( viewComponent ) != null;
	}
	
	public function hasMediator( mediator : IMediator ) : Bool
	{
		for ( i in mediatorByView )
			if ( i.mediator == mediator )
				return true;
		return false;
	}
	
#if Flash9
	
	public function addListeners()
	{
		if ( container != null && Std.is( container, flash.display.DisplayObject ) && enabled && _active )
		{
			var cdo : DisplayObject = cast( container );
			cdo.addEventListener( flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true );
			cdo.addEventListener( flash.events.Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture, 0, true );
		}
	}
	
	public function removeListeners()
	{
		if ( container != null && Std.is( container, flash.display.DisplayObject ) && enabled && _active )
		{
			var cdo : DisplayObject = cast( container );
			cdo.removeEventListener( flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture );
			cdo.removeEventListener( flash.events.Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture );
		}
	}
	
	private function onViewAdded( e : flash.events.Event )
	{
		if ( mediatorsMarkedForRemoval.indexOf( e.target ) > -1 )
		{
			mediatorsMarkedForRemoval[ e.target ] = null;
			return;
		}
		var config : MappingConfig = mappingConfigByViewClassName.get( Type.getClassName( Type.getClass( e.target ) );
		if ( config != null && config.autoCreate )
			createMediator( e.target );
	}
	
	private function onViewRemoved( e : flash.events.Event )
	{
		var config : MappingConfig = mappingConfigByViewClassName( Type.getClassName( Type.getClass( e.target ) ) );
		if ( config != null && config.autoRemove )
		{
			mediatorsMarkedForRemoval.push( e.target );
			for ( view in mediatorsMarkedForRemoval )
			{
				if ( !view.stage )
					removeMediatorByView( view );
				mediatorsMarkedForRemoval[ view ] = null;
			}
			mediatorsMarkedForRemoval = new Array();
		}
	}
	
#end
	
	private function getMediatorByView( view : T ) : IMediator
	{
		for ( i in mediatorByView )
			if ( i.view == view )
				return i.mediator;
		return null;
	}
	
	private function setMediatorByView( view : T, mediator : IMediator )
	{
		for ( i in mediatorByView )
			if ( i.view == view )
				return;
		mediatorByView.push( { mediator : mediator, view : view } );
	}
	
	private function deleteMediatorByView( view : T )
	{
		for ( i in 0 ... mediatorByView.length )
			if ( mediatorByView[i].view == view )
				mediatorByView[i] = null;
	}
}
