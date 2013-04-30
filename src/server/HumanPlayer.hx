package server;
import com.haxepunk.HXP;

import scenes.PlayScene;
import server.Player;
class HumanPlayer extends Player {
	public function new(name:String) {
		super(name);		
	}

	/**** ServerEventHandler stuff 
	 * [@note this could be a lot cleaner if we derived from the dispatcher, and made dispatcher derive from handler]
	 */
	public override function onEvent(event:ServerEvent):Bool {
		// interception here
		if (event.target != this) {
			return event.target.onEvent(event);
		}
		// personal handling here
		return true;
	}

	/* These are event-forwarders, but can also be used to track actions on the player
	 * eg.
	 *	when all of a player's actors are killed, we get an onWasKilled directed to the Player (rather than actor)
	 *	
	 */

	public override function onPathArrived(event:ServerEvent):Bool {
		// Player-based handling
		PlayScene.tutorialController.sendEvent("unitArrived");		
		
		return super.onPathArrived(event);
	}
	public override function onPathCancelled(event:ServerEvent):Bool {
		if (event.target != this) {		
			return event.target.onPathCancelled(event);
		}
		return super.onPathCancelled(event);
	}
	public override function onPathBlocked(event:ServerEvent):Bool {
		if (event.target != this) {		
			return event.target.onPathBlocked(event);
		}
		return super.onPathBlocked(event);
	}
	public override function onWasHit(event:ServerEvent):Bool {
		PlayScene.tutorialController.sendEvent("unitWasHit");				
		if (event.target != this) {	
			return event.target.onWasHit(event);
		}
		return super.onWasHit(event);
	}
	public override function onWasKilled(event:ServerEvent):Bool {
		PlayScene.tutorialController.sendEvent("unitWasKilled");		

		if (event.target != this) {		
			return event.target.onWasKilled(event);
		}
		return super.onWasKilled(event);
	}
	public override function onSuccessfulHit(event:ServerEvent):Bool {
		PlayScene.tutorialController.sendEvent("unitSuccessfulHit");		

		if (event.target != this) {		
			return event.target.onSuccessfulKill(event);
		}
		return super.onSuccessfulHit(event);
	}

	public override function onSuccessfulKill(event:ServerEvent):Bool {
		PlayScene.tutorialController.sendEvent("unitSuccessfulKill");		

		if (event.target != this) {		
			return event.target.onSuccessfulKill(event);
		}
		return super.onSuccessfulKill(event);
	}

	public override function onTargetFound(event:ServerEvent):Bool {
		if (event.target != this) {		
			return event.target.onTargetFound(event);
		}
		return super.onTargetFound(event);
	}		
}