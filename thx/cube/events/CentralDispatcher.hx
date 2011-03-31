/**
 * ...
 * @author Lee McColl Sylvester
 */

package thx.cube.events;

import thx.cube.abstract.ICentralDispatcher;

import hxevents.Dispatcher;
import hxevents.EventException;

class CentralDispatcher<T> implements ICentralDispatcher<T>
{
	private var _handlers : Hash<Dispatcher<Dynamic>>;

	public function new() {
		_handlers = new Hash();
	}

	public function addEventHandler( type : String, h : T -> Void ) : T -> Void
	{
		if ( !_handlers.exists( type ) )
		{
			var dispatcher = new Dispatcher();
			_handlers.set( type, dispatcher );
		}
		_handlers.get( type ).add( h );
		return h;
	}
	
	public function addEventHandlerOnce( type : String, h : T -> Void ) : T -> Void
	{
		var me = this;
		var _h = null;
		_h = function( v : T )
		{
			me.remove( type, _h );
			h( v );
		};
		addEventHandler( type, _h );
		return _h;
	}

	public function remove( type : String, h : T -> Void ) : T -> Void
	{
		if ( _handlers.exists( type ) )
			return _handlers.get( type ).remove( h );
		return null;
	}

	public function clear()
	{
		_handlers = new Hash();
	}

	public function dispatch( type : String, ?e : T = null ) : Bool
	{
		try {
			// prevents problems with self removing events
			if ( _handlers.exists( type ) )
			{
				var dispatcher = _handlers.get( type );
				return dispatcher.dispatch( e );
			}
		} catch( exc : EventException ) {
			return false;
		}
		return false;
	}

	public function has( type : String, ?h : T -> Void ) : Bool
	{
		if ( _handlers.exists( type ) )
		{
			if ( h == null )
				return true;
			return _handlers.get( type ).has( h );
		}
		else
			return false;
	}
}