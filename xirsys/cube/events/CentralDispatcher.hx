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

package xirsys.cube.events;

import xirsys.cube.abstract.ICentralDispatcher;

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
