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

package xirsys.cube.fsm;

import xirsys.cube.events.CentralDispatcher;
import xirsys.cube.events.IEvent;
import xirsys.injector.Injector;

typedef State<R> = {
	var ref : R;
	var enterEvent : String;
	var exitEvent : String;
	var changedEvent : String;
	var transitions : Hash<Transition<R>>;
};

typedef Transition<R> = {
	var action : String;
	var target : R;
}

class FSM<R,E>
{
	public static var STATE_CHANGED : String = "/fsm/events/stateChanged";
	public static var CANCEL_TRANSITION : String = "/fsm/events/cancelTransition";
	
	public var currentState(default, null) : State<R>;
	public var nextState(default, null) : State<R>;
	public var canceled(null, setCanceled) : Bool;
	
	private var _initial : State<R>;
	private var _states : Hash<State<R>>;
	private var _canceled : Bool;
	
	private var eventDispatcher : CentralDispatcher<E>;
	private var injector : Injector;
	
	public function new( eventDispatcher : CentralDispatcher<E>, injector : Injector )
	{
		_states = new Hash();
		this.eventDispatcher = eventDispatcher;
		this.injector = injector;
		var me = this;
		eventDispatcher.addEventHandler( CANCEL_TRANSITION, function( evt : E ) {
			me.canceled = true;
		});
	}
	
	public function initiate()
	{
		if ( _initial != null ) transitionTo( _initial );
	}

	public function registerState( state : State<R>, initial : Bool = false )
	{
		if ( state == null || _states.get( Std.string( state.ref ) ) != null ) return;
		_states.set( Std.string( state.ref ), state );
		if ( initial ) _initial = state;
		var me = this;
		for ( t in state.transitions )
			eventDispatcher.addEventHandler( t.action, function( e : E ) {
				if ( me.currentState == null || me.currentState.transitions == null || !me.currentState.transitions.exists( t.action ) ) return;
				var trans : Transition<R> = me.currentState.transitions.get( t.action );
				var newState : State<R> = me.getState( trans.target );
				if ( newState != null ) me.transitionTo( newState );
			} );
	}

	public function removeState( stateRef : R )
	{
		var state : State<R> = _states.get( Std.string( stateRef ) );
		if ( state == null ) return;
			_states.set( Std.string( stateRef ), null );
	}
	
	public function getState( stateRef : R )
	{
		return _states.get( Std.string( stateRef ) );
	}
	
	private function transitionTo( next : State<R> )
	{
		// Going nowhere?
		if ( next == null ) return;
		
		nextState = next;

		// Clear the cancel flag
		_canceled = false;
		
		// Exit the current State
		if ( currentState != null && currentState.exitEvent != null ) eventDispatcher.dispatch( currentState.exitEvent );

		// Check to see whether the exiting guard has canceled the transition
		if ( _canceled ) {
			_canceled = false;
			return;
		}

		// Enter the next State
		if ( nextState.enterEvent != null ) eventDispatcher.dispatch( nextState.enterEvent );
                       
		// Check to see whether the entering guard has canceled the transition
		if ( _canceled ) {
			_canceled = false;
			return;
		}

		// change the current state only when both guards have been passed
		currentState = nextState;

		// Send the notification configured to be sent when this specific state becomes current
		if ( currentState.changedEvent != null ) eventDispatcher.dispatch( currentState.changedEvent );

		// Notify the app generally that the state changed and what the new state is
		eventDispatcher.dispatch( STATE_CHANGED );
	}
	
	public function makeState( r : R, t : Array<Transition<R>>, ?changed : String = "", ?enter : String = "", ?exit : String = "" ) : State<R>
	{
		var tHash = new Hash<Transition<R>>();
		for ( i in t )
			tHash.set( i.action, i );
		return { ref : r, enterEvent : enter, exitEvent : exit, changedEvent : changed, transitions : tHash };
	}
	
	public function t( i : Transition<R> ) : Array<Transition<R>>
	{
		var a : Array<Transition<R>> = new Array();
		a.push( i );
		return a;
	}
	
	public function setCanceled( c : Bool ) : Bool {
		return _canceled = c;
	}
}
