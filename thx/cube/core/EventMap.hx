package thx.cube.core;

import thx.cube.abstract.ICentralDispatcher;
import thx.cube.abstract.IEventMap;

typedef Listener<E> = {
	dispatcher : ICentralDispatcher<E>,
	type : String,
	listener : Dynamic->Void,
	eventClass : Class<E>,
	cb : E->Void
}

class EventMap<E> implements IEventMap<E> {
	public var eventDispatcher : ICentralDispatcher<E>;
	public var dispatcherListeningEnabled : Bool;
	public var listeners : Array<Listener<E>>;
	
	//---------------------------------------------------------------------
	//  Constructor
	//---------------------------------------------------------------------
	
	public function new( eventDispatcher : ICentralDispatcher<E> )
	{
		listeners = new Array<Listener<E>>();
		this.eventDispatcher = eventDispatcher;
		dispatcherListeningEnabled = true;
	}
	
	//---------------------------------------------------------------------
	//  API
	//---------------------------------------------------------------------
	
	public function mapListener( dispatcher : ICentralDispatcher<E>, type : String, listener : E->Void, ?eventClass : Class<E> = null )
	{
		if ( dispatcherListeningEnabled == false && dispatcher == eventDispatcher )
			throw new CubeError( CubeError.E_EVENTMAP_NOSNOOPING );
		//eventClass = ( eventClass != null ) ? eventClass : Class<E>;
		
		var params : Listener<E>;
		var i : Int = listeners.length;
		while ( --i > -1 )
		{
			params = listeners[i];
			if ( params.dispatcher == dispatcher
				&& params.type == type
				&& params.listener == listener
				&& params.eventClass == eventClass )
			{
				return;
			}
		}
		var me = this;
		var cb : E->Void = function( event : E )
		{
			me.routeEventToListener( event, listener, eventClass );
		};
		params = {
				dispatcher: dispatcher,
				type: type,
				listener: listener,
				eventClass: eventClass,
				cb: cb
			};
		listeners.push( params );
		dispatcher.addEventHandler( type, cb );
	}
	
	public function unmapListener( dispatcher : ICentralDispatcher<E>, type : String, listener : E->Void, ?eventClass : Class<E> = null )
	{
		var params : Listener<E>;
		var i = listeners.length;
		while ( i >= 0 )
		{
			params = listeners[i];
			if ( params.dispatcher == dispatcher
				&& params.type == type
				&& params.listener == listener
				&& params.eventClass == eventClass )
			{
				dispatcher.remove( type, params.cb );
				listeners.splice( i, 1 );
				return;
			}
			i--;
		}
	}
	
	/**
	 * Removes all listeners registered through <code>mapListener</code>
	 */
	public function unmapListeners()
	{
		var params : Listener<E>;
		var dispatcher : ICentralDispatcher<E>;
		while ( { params = listeners.pop(); params != null; } )
		{
			dispatcher = params.dispatcher;
			dispatcher.remove( params.type, params.cb );
		}
	}
	
	//---------------------------------------------------------------------
	//  Internal
	//---------------------------------------------------------------------
	
	public function routeEventToListener( event : E, listener : E->Void, originalEventClass : Class<E> )
	{
		if ( Std.is( event, originalEventClass ) )
		{
			listener( event );
		}
	}
}
