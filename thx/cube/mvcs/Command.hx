package thx.cube.mvcs;

import thx.cube.abstract.ICommandMap;
import thx.cube.abstract.IMediatorMap;
import thx.cube.abstract.IView;
import thx.cube.abstract.ICentralDispatcher;
import thx.injector.Injector;

class Command implements haxe.rtti.Infos {
	
	@Inject
	public var commandMap : ICommandMap<Dynamic>;
	
	@Inject
	public var eventDispatcher : ICentralDispatcher<Dynamic>;
	
	@Inject
	public var injector : Injector;
	
	@Inject
	public var mediatorMap : IMediatorMap<Dynamic>;
	
	public function Command()
	{
	}
	
	public function execute()
	{
		
	}
}
