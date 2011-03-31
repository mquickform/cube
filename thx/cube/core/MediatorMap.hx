package thx.cube.core;

import thx.cube.events.CentralDispatcher;
import thx.injector.Injector;

import thx.cube.abstract.IMediatorMap;
import thx.cube.abstract.IMediator;

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
					injector.mapInstance( cls, viewComponent );
				try
				{
					mediator = injector.instantiate( config.mediatorClass );
				}
				catch( e : thx.exceptions.InjectorException )
				{
					trace( e.msg );
				}
				for ( cls in config.typedViewClasses )
					injector.unmap( cls );
				registerMediator( viewComponent, mediator );
			}
		}
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
