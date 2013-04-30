package server;
import com.haxepunk.HXP;

import server.ServerEvent;
import server.ServerEventHandler;

class ServerEventDispatcher extends BasicServerEventHandler {
	var eventList:List<ServerEvent>;
	var eventsToAdd:List<ServerEvent>;

	// no need for a Hash, we broadcast to everyone
	// in this case just to the server, which re-broadcasts
	var handlers:List<ServerEventHandler>;

	public function new() {
		eventList = new List<ServerEvent>();
		eventsToAdd = new List<ServerEvent>();
		handlers = new List<ServerEventHandler>();

		/* this is leftover from the first few lines of code
		 in the server class, but I liked the comment so it's
		 staying here in memoriam
		 */
		// // just in case this isn't our first rodeo
		// eventList.clear();		
	}	

	public function update() {
		dispatchEvents();
		updateLists();
	}

	private function dispatchEvents() {	
		// technically pointless, but avoid the trace and 
		// creation of an empty iterator
		if (eventList.length == 0) return;

		// HXP.log("about to process " + eventList.length + " events");	
		// HXP.log("and there are " + handlers.length + " handlers");
		for (evt in eventList) {
			dispatchEvent(evt);
		}
	}

	/** this is a protected method so that it may be
	 * overridden by child classes to force things like
	 * only sending events to their destination
	 */
	function dispatchEvent(evt:ServerEvent) {
		for (handler in handlers) {

			// [@note this line breaks with the above comments]
			// [@... still not sure if this should live this high up]				
			if (evt.target != handler && !handler.isPromiscuous()) {
				continue;
			}

			// [@note currently ignores return value, potentially should skip the switch sometimes]
			handler.onEvent(evt);
			switch (evt.type) {
				case PathArrived:
					handler.onPathArrived(evt);
				case PathCancelled:
					handler.onPathCancelled(evt);
				case PathBlocked:
					handler.onPathBlocked(evt);
				case WasHit:
					handler.onWasHit(evt);
				case TargetFound:
					handler.onTargetFound(evt);
				case WasKilled:
					handler.onWasKilled(evt);
				case SuccessfulHit:
					handler.onSuccessfulHit(evt);
				case SuccessfulKill:
					handler.onSuccessfulKill(evt);

				case NonEvent:

			}
		}
	}

	private function updateLists() {
		eventList.clear();
		for (evt in eventsToAdd) {
			eventList.add(evt);
		}	
		eventsToAdd.clear();	
	}

	public function add(event:ServerEvent):ServerEvent {
		event.dispatcher = this;
		eventsToAdd.add(event);		
		return event;
	}

	public function send(type:ServerEventType, ?src:ServerEventHandler=null, ?target:ServerEventHandler=null):ServerEvent {
		var evt:ServerEvent = new ServerEvent(type, src, target);
		// HXP.log("sending " + evt);
		return add(evt);
	}

	public function addHandler(handler:ServerEventHandler):ServerEventHandler {
		handlers.add(handler);		
		return handler;
	}
}