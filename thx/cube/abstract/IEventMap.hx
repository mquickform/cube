package thx.cube.abstract;

interface IEventMap<E> {
	function unmapListeners() : Void;
	function routeEventToListener( event : E, listener : E->Void, originalEventClass : Class<E> ) : Void;
}
