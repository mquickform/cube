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

import xirsys.cube.events.IEvent;
import xirsys.cube.events.AgentEvent;

import xirsys.cube.events.CentralDispatcher;
import xirsys.injector.Injector;

import xirsys.cube.abstract.ICommandMap;
import xirsys.cube.abstract.IMediatorMap;
import xirsys.cube.abstract.IView;
import xirsys.cube.abstract.ICentralDispatcher;
import xirsys.cube.abstract.IViewMap;
import xirsys.cube.abstract.IProxy;

import xirsys.cube.core.CommandMap;
import xirsys.cube.core.MediatorMap;
import xirsys.cube.core.ViewMap;

class Agent<T,E> extends CentralDispatcher<IEvent>
{
	public var eventDispatcher : CentralDispatcher<E>;
	public var container( getContainer, null ) : T;
	public var injector( getInjector, setInjector ) : Injector;
	public var commandMap( getCommandMap, setCommandMap ) : ICommandMap<E>;
	public var mediatorMap( getMediatorMap, setMediatorMap ) : IMediatorMap<T>;
	public var viewMap( getViewMap, setViewMap ) : IViewMap;
	public var proxy( getProxy, null ) : Proxy<E>;
	
	private var _container : T;
	private var _autoStart : Bool;
	private var _injector : Injector;
	private var _commandMap : ICommandMap<E>;
	private var _mediatorMap : IMediatorMap<T>;
	private var _viewMap : IViewMap;
	private var _proxy : IProxy<E>;
	
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
	
	/**
	 * currently quite pointless, as there is no way to register
	 * for notification when a view object is created and added to
	 * the view stack, except in Flash.  This will be updated when
	 * a decent solution has been reasoned out.
	 */
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
	
	private function getProxy() : Proxy<E>
	{
		return ( _proxy != null ) ? proxy : { proxy = new Proxy( eventDispatcher, injector ); proxy; };
	}
	
	private function bindMappings()
	{
		injector.mapInstance( ICentralDispatcher, eventDispatcher );
		injector.mapSingleton( Injector );
		injector.mapInstance( ICommandMap, _commandMap );
		injector.mapInstance( IMediatorMap, _mediatorMap );
		injector.mapInstance( IViewMap, _viewMap );
		injector.mapInstance( IProxy, _proxy );
	}
}
