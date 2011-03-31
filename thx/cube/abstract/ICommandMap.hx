package thx.cube.abstract;

import thx.cube.mvcs.Actor;
import thx.cube.mvcs.Command;
import thx.cube.events.CentralDispatcher;
import thx.injector.Injector;

interface ICommandMap<E> {
	public var eventDispatcher : CentralDispatcher<E>;
	public var injector : Injector;
	private var eventTypeMap : Hash<Hash<E->Void>>;
	private var verifiedCommandClasses : Hash<Bool>;
	public function mapEvent( eventType : String, commandClass : Class<Command>, eventClass : Class<E>, ?oneshot : Bool = false ) : Void;
	public function unmapEvent( eventType : String, commandClass : Class<Command> ) : Void;
	public function unmapEvents() : Void;
	public function hasEventCommand( eventType : String, commandClass : Class<Command> ) : Bool;
	public function execute( commandClass : Class<Command>, ?payload : Dynamic = null, ?payloadClass : Class<Dynamic> = null ) : Void;
}
