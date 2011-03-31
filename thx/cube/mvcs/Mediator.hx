package thx.cube.mvcs;

import thx.cube.abstract.IView;
import thx.cube.abstract.IEventMap;
import thx.cube.abstract.IMediator;
import thx.cube.abstract.IMediatorMap;
import thx.cube.abstract.ICentralDispatcher;

import thx.cube.core.EventMap;

class Mediator implements IMediator, implements haxe.rtti.Infos {
	
	@Inject
	public var mediatorMap : IMediatorMap<Dynamic>;
	
	@Inject
	public var eventDispatcher : ICentralDispatcher<Dynamic>;
	
	public var eventMap : IEventMap<Dynamic>;
	public var viewComponent : Dynamic;
	public var removed : Bool;
	
	public function new()
	{
		eventMap = new EventMap( eventDispatcher );
	}
	
	public function preRemove()
	{
		if ( eventMap != null )
			eventMap.unmapListeners();
		removed = true;
		onRemove();
	}
	
	//---------------------------------------------------------------------
	//  API
	//---------------------------------------------------------------------
	
	public function preRegister()
	{
		removed = false;
		onRegister();
	}
	
	public function onRegister()
	{
	}
	
	public function onRemove()
	{
	}
	
	public function getViewComponent()
	{
		return viewComponent;
	}
	
	public function setViewComponent( view : Dynamic )
	{
		viewComponent = view;
	}
}
