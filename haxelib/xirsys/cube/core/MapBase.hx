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

import xirsys.injector.Injector;

class MapBase<T> {

	private var _enabled : Bool;
	private var _active : Bool;
	private var _container : T;
	private var injector : Injector;
	private var useCapture : Bool;
	
	public var enabled ( getEnabled, setEnabled ) : Bool;
	public var container( getContainer, setContainer ) : T;
	
	public function new( container : T, injector : Injector )
	{
		_enabled = true;
		_active = true;
		this.injector = injector;
		this.useCapture = true;
		this.container = container;
	}
	
	//---------------------------------------------------------------------
	// API
	//---------------------------------------------------------------------
	
	public function getContainer() : T
	{
		return _container;
	}
	
	public function setContainer(value : T ) : T
	{
		if ( value != _container )
		{
			removeListeners();
			_container = value;
			addListeners();
		}
		return value;
	}
	
	public function getEnabled() : Bool
	{
		return _enabled;
	}
	
	public function setEnabled( value : Bool ) : Bool
	{
		if ( value != _enabled )
		{
			removeListeners();
			_enabled = value;
			addListeners();
		}
		return value;
	}
	
	//---------------------------------------------------------------------
	// Internal
	//---------------------------------------------------------------------
	
	public function activate()
	{
		if ( !_active )
		{
			_active = true;
			addListeners();
		}
	}

	public function addListeners()
	{
	}
	
	public function removeListeners()
	{
	}
	
#if Flash9

	public function onViewAdded( e : flash.events.Event )
	{
	}
	
#end
}
