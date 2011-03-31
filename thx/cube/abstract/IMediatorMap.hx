package thx.cube.abstract;

interface IMediatorMap<T> {
	public function mapView( viewClass : Class<T>, mediatorClass : Class<IMediator>, ?autoCreate : Bool = true, ?autoRemove : Bool = true ) : Void;
	public function unmapView( viewClass : Class<T> ) : Void;
	public function createMediator( viewComponent : T ) : IMediator;
	public function registerMediator( viewComponent : T, mediator : IMediator ) : Void;
	public function removeMediator( mediator : IMediator ) : IMediator;
	public function removeMediatorByView( viewComponent : T ) : IMediator;
	public function retrieveMediator( viewComponent : T ) : IMediator;
	public function hasMediatorForView( viewComponent : T ) : Bool;
	public function hasMediator( mediator : IMediator ) : Bool;
	
#if Flash9
	public function addListeners();
	public function removeListeners();
#end
}
