
package server;

interface ServerEventHandler {
	// Handlers return true if the event has been handled
	// (eg. if the Player returns true, this event doesn't
	// reach the Agent?)
	public function onPathArrived(event:ServerEvent):Bool;
	public function onPathCancelled(event:ServerEvent):Bool;	
	public function onPathBlocked(event:ServerEvent):Bool;
	public function onWasHit(event:ServerEvent):Bool;	
	public function onTargetFound(event:ServerEvent):Bool;

	// a catch-all, this is called before the others	
	// [@note mostly just for rapid prototyping]
	// also good for debugging, but has other uses
	// eg. could be used to modify events en-route
	public function onEvent(event:ServerEvent):Bool;

	// whether we want all the events
	public function isPromiscuous():Bool;
}

class BasicServerEventHandler implements ServerEventHandler {
	public function onPathArrived(event:ServerEvent):Bool {
		return false;
	}
	public function onPathCancelled(event:ServerEvent):Bool {
		return true;
	}
	public function onPathBlocked(event:ServerEvent):Bool {
		return true;
	}
	public function onWasHit(event:ServerEvent):Bool {
		return true;
	}
	public function onTargetFound(event:ServerEvent):Bool {
		return true;
	}
	public function onEvent(event:ServerEvent):Bool {
		return true;
	}	

	public function isPromiscuous():Bool {
		return false;
	}

}