package thx.cube.core;

import thx.cube.events.IEvent;
import thx.cube.events.AgentEvent;

import thx.cube.events.CentralDispatcher;
import thx.injector.Injector;

import thx.cube.abstract.ICommandMap;
import thx.cube.abstract.IMediatorMap;
import thx.cube.abstract.IView;
import thx.cube.abstract.ICentralDispatcher;
import thx.cube.abstract.IViewMap;

import thx.cube.core.CommandMap;
import thx.cube.core.MediatorMap;
import thx.cube.core.ViewMap;

class Agent<T,E> extends CentralDispatcher<IEvent>
{
	public var eventDispatcher : CentralDispatcher<E>;
	public var container( getContainer, null ) : T;
	public var injector( getInjector, setInjector ) : Injector;
	public var commandMap( getCommandMap, setCommandMap ) : ICommandMap<E>;
	public var mediatorMap( getMediatorMap, setMediatorMap ) : IMediatorMap<T>;
	public var viewMap( getViewMap, setViewMap ) : IViewMap;
	
	private var _container : T;
	private var _autoStart : Bool;
	private var _injector : Injector;
	private var _commandMap : ICommandMap<E>;
	private var _mediatorMap : IMediatorMap<T>;
	private var _viewMap : IViewMap;
	
	public function new( container : T, autoStart : Bool )
	{
		super();
		_container = container;
		_autoStart = autoStart;
		eventDispatcher = new CentralDispatcher<E>();
		bindMappings();
		if ( _autoStart )
			initiate();
	}
	
	public function initiate()
	{
		dispatch( AgentEvent.STARTUP_COMPLETE, null );
	}
	
	private function getContainer() : T
	{
		return _container;
	}
	
	private function getInjector() : Injector
	{
		return ( _injector != null ) ? _injector : _injector = new Injector();
	}
	
	private function setInjector( value : Injector ) : Injector
	{
		return _injector = value;
	}
	
	private function getCommandMap() : ICommandMap<E>
	{
		return ( _commandMap != null ) ? _commandMap : _commandMap = new CommandMap( eventDispatcher, injector );
	}
	
	private function setCommandMap( value : ICommandMap<E> ) : ICommandMap<E>
	{
		return _commandMap = value;
	}
	
	private function getMediatorMap() : IMediatorMap<T>
	{
		return ( _mediatorMap != null ) ? _mediatorMap : _mediatorMap = new MediatorMap<T,E>( _container, eventDispatcher, injector );
	}
	
	private function setMediatorMap( value : IMediatorMap<T> ) : IMediatorMap<T>
	{
		return _mediatorMap = value;
	}
	
	private function getViewMap() : IViewMap
	{
		return ( _viewMap != null ) ? _viewMap : { _viewMap = new ViewMap( _container, eventDispatcher, injector ); _viewMap; };
	}
	
	private function setViewMap<T>( value : IViewMap ) : IViewMap
	{
		return _viewMap = value;
	}
	
	private function bindMappings()
	{
		injector.mapInstance( ICentralDispatcher, eventDispatcher );
		injector.mapSingleton( Injector );
		injector.mapInstance( ICommandMap, _commandMap );
		injector.mapInstance( IMediatorMap, _mediatorMap );
		injector.mapInstance( IViewMap, _viewMap );
	}
}