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

import xirsys.cube.abstract.IViewMap;
import xirsys.cube.core.MapBase;

class ViewMap<T,E> extends MapBase<T>, implements IViewMap {
	
	private var mappedPackages : Array<String>;
	private var mappedTypes : Array<Class<T>>;
	private var injectedViews : Array<T>;
	
	public var eventDispatcher : CentralDispatcher<E>;
	
	public function new( container : T, eventDispatcher : CentralDispatcher<E>, injector : Injector )
	{
		super( container, injector );
		this.eventDispatcher = eventDispatcher;
		mappedPackages = new Array();
		mappedTypes = new Array();
		injectedViews = new Array();
	}
	
	//---------------------------------------------------------------------
	// API
	//---------------------------------------------------------------------
	
	public function mapPackage( packageName : String )
	{
		if ( !Lambda.has( mappedPackages, packageName ) )
		{
			mappedPackages.push( packageName );
			activate();
		}
	}
	
	public function unmapPackage( packageName : String )
	{
		var index = indexOf( mappedPackages, packageName );
		if ( index > -1 )
			mappedPackages.splice( index, 1 );
	}
	
	public function mapType( type : Class<T> )
	{
		if ( Lambda.has( mappedTypes, type ) )
			return;
		
		mappedTypes.push( type );
		
		if ( container != null )
			injectInto( container );
		
		activate();
	}
	
	public function unmapType( type : Class<T> )
	{
		if ( Lambda.has( mappedTypes, type ) )
			mappedTypes[ indexOf( mappedTypes, type ) ] == null;
	}
	
	public function hasType( type : Class<T> ) : Bool
	{
		return Lambda.has( mappedTypes, type );
	}
	
	public function hasPackage( packageName : String ) : Bool
	{
		return Lambda.has( mappedPackages, packageName );
	}
	
	//---------------------------------------------------------------------
	// Internal
	//---------------------------------------------------------------------
	
#if flash9
	public override function addListeners()
	{
		if ( container != null && enabled && _active )
			cast( container, flash.display.DisplayObject ).addEventListener( flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true );
	}
	
	public override function removeListeners()
	{
		if ( container != null && enabled && _active )
			cast( container, flash.display.DisplayObject ).removeEventListener( flash.events.Event.ADDED_TO_STAGE, onViewAdded, useCapture );
	}
	
	private function onViewAdded( e : flash.events.Event )
	{
		var target : T = cast e.target;
		if ( Lambda.has( injectedViews, target ) )
			return;
		
		for ( type in mappedTypes )
		{
			if ( Std.is( target, type ) )
			{
				injectInto( target );
				return;
			}
		}
		
		var len = mappedPackages.length;
		if ( len > 0 )
		{
			var className : String = Type.getClassName( Type.getClass( target ) );
			for ( i in 0 ... len )
			{
				var packageName : String = mappedPackages[i];
				if ( className.indexOf( packageName ) == 0 )
				{
					injectInto( target );
					return;
				}
			}
		}
	}
#end
	
	private function injectInto( target : T )
	{
		injector.inject( target );
		injectedViews.push( target );
	}
	
	private function indexOf( arr : Array<Dynamic>, itm : Dynamic ) : Int
	{
		var ret = -1;
		for ( i in 0 ... arr.length )
			if ( arr[i] == itm )
				ret = i;
		return ret;
	}
}
