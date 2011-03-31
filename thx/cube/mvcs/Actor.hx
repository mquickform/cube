package thx.cube.mvcs;

import thx.cube.events.CentralDispatcher;

class Actor implements haxe.rtti.Infos {
	public var eventDispatcher ( default, default ) : CentralDispatcher<Dynamic>;
}
