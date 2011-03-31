package thx.cube.abstract;

interface ICentralDispatcher<T> {
	public function addEventHandler( type : String, h : T -> Void ) : T -> Void;
	public function addEventHandlerOnce( type : String, h : T -> Void ) : T -> Void;
	public function remove( type : String, h : T -> Void ) : T -> Void;
	public function clear() : Void;
	public function dispatch( type : String, ?e : T = null ) : Bool;
	public function has( type : String, ?h : T -> Void ) : Bool;
}
