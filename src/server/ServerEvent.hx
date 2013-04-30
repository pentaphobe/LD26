package server;

import server.ServerEventDispatcher;

enum ServerEventType {
	NonEvent;	// for cancellation, etc.
	PathArrived;
	PathCancelled;
	PathBlocked;
	WasHit;
	WasKilled;
	SuccessfulKill;
	TargetFound;
}

class ServerEvent {
	public var type:ServerEventType;
	// them
	public var source:ServerEventHandler;
	// us
	public var target:ServerEventHandler;
	public var dispatcher(default, default):ServerEventDispatcher;

	public function new (type:ServerEventType, ?src:ServerEventHandler=null, ?target:ServerEventHandler=null) {
		this.type = type;
		this.source = src;
		this.target = target;
	}

	public function get_dispatcher():ServerEventDispatcher {
		return dispatcher;
	}

	public function set_dispatcher(disp:ServerEventDispatcher):ServerEventDispatcher {
		// [@note quietly allows resetting to null]
		dispatcher = disp;
		return dispatcher;
	}

	public function toString():String {
		return "[event " + source + " --" + type + "--> " + target + "]";
	}
}