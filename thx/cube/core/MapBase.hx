package thx.cube.core;

import thx.injector.Injector;

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
