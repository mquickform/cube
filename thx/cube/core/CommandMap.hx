package thx.cube.core;

import thx.cube.events.CentralDispatcher;
import thx.injector.Injector;

import thx.cube.mvcs.Actor;
import thx.cube.mvcs.Command;
import thx.cube.abstract.ICommandMap;

class CommandMap<E> implements ICommandMap<E> {
	
	public var eventDispatcher : CentralDispatcher<E>;
	public var injector : Injector;
	
	private var eventTypeMap : Hash<Hash<E->Void>>;
	private var verifiedCommandClasses : Hash<Bool>;
	
	public function new( eventDispatcher : CentralDispatcher<E>, injector : Injector )
	{
		this.eventDispatcher = eventDispatcher;
		this.injector = injector;
		verifiedCommandClasses = new Hash();
		eventTypeMap = new Hash();
		
	}
	
	//---------------------------------------------------------------------
	//  API
	//---------------------------------------------------------------------
	
	public function mapEvent( eventType : String, commandClass : Class<Command>, eventClass : Class<E>, ?oneshot : Bool = false )
	{
		var me = this;
		var cb : E -> Void = function( event : E )
		{
			me.routeEventToCommand( event, eventType, commandClass, eventClass );
		};
		if ( oneshot )
			eventDispatcher.addEventHandlerOnce( eventType, cb );
		else
			eventDispatcher.addEventHandler( eventType, cb );
		if ( eventTypeMap.get( eventType ) == null )
			eventTypeMap.set( eventType, new Hash<E->Void>() );
		eventTypeMap.get( eventType ).set( Type.getClassName( commandClass ), cb );
	}
	
	public function unmapEvent( eventType : String, commandClass : Class<Command> )
	{
		if ( eventTypeMap.get( eventType ) != null )
		{
			var cb : E -> Void = eventTypeMap.get( eventType ).get( Type.getClassName( commandClass ) );
			eventTypeMap.get( eventType ).remove( Type.getClassName( commandClass ) );
			eventDispatcher.remove( eventType, cb );
		}
	}
	
	public function unmapEvents()
	{
		
	}
	
	public function hasEventCommand( eventType : String, commandClass : Class<Command> ) : Bool
	{
		return ( eventTypeMap.get( eventType ) != null && eventTypeMap.get( eventType ).get( Type.getClassName( commandClass ) ) != null );
	}
	
	public function execute( commandClass : Class<Command>, ?payload : Dynamic = null, ?payloadClass : Class<Dynamic> = null )
	{
		if ( payload != null || payloadClass != null )
		{
			if ( payloadClass == null )
				payloadClass = Type.getClass( payload );
			injector.mapInstance( payloadClass, payload );
		}
		
		var command = injector.instantiate( commandClass );
		
		if ( payload != null || payloadClass != null )
			injector.unmap( payloadClass );
		
		command.execute();
	}
	
	//---------------------------------------------------------------------
	//  Internal
	//---------------------------------------------------------------------
	
	private function routeEventToCommand( event : E, eventType : String, commandClass : Class<Command>, originalEventClass : Class<E> ) : Bool
	{
		if ( !Std.is( event, originalEventClass ) ) return false;
		
		execute( commandClass, event );
		
		return true;
	}
}
