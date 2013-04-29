package server;
import com.haxepunk.HXP;

import utils.AgentTemplate;
import utils.AgentFactory;
import utils.MapPoint;

import entities.Actor;
import entities.Level;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;
import server.Orderable;
import server.Player;

enum AgentState {
	AgentMoving;
	AgentIdling;
	AgentBreeding;
	AgentAttacking;
	AgentSeeking;
}
/** 
 *
 * Agents will be the low-level aspect of entities in the
 * game logic
 * currently Actors are handling all of it, but that's causing
 * weirdness, so I'm moving over to this split and Actors
 * will just be visual representations of the Agent data
 * (with interpolation etc)
 */ 
 class Agent extends BasicServerEventHandler, implements Orderable {
 	public static var TICKS_TO_BREED:Int = 20;
 	public static var TICKS_TO_ATTACK:Int = 4;
 	public static var SEEK_TIMEOUT:Int = 100;
 	public static var SEEK_RANGE:Float = 60;

	/** TEMPORARY **/
	public var path:List<MapPoint>;
	/** /TEMPORARY **/

 	public var player:Player; 	
 	// [@note does this need to be here?  NO!]
 	// public var actor:Actor;
	public var hitPoints:Float;
	public var movementPoints:Float;
	public var actionPoints:Float;
	public var targetPos:MapPoint;
 	public var pos:MapPoint;
 	public var config:AgentTemplate;
 	public var state(default, default):AgentState;
 	public var stateTicks:Int;
 	public var isAlive:Bool = true;

 	// resetting states, these monitor what's happened since the last update
 	public var wasHit:Bool = false;

 	public function new(?x:Int=0, ?y:Int=0) {
 		pos = new MapPoint(x, y);
		targetPos = new MapPoint();
		path = new List<MapPoint>();	
		state = AgentIdling;	 		
 	}
	public function onOrder(order:PlayerOrder):Bool {
		// HXP.log("agent order mutta flichers! " + order);
		if (order.orderType == "move") {
			setTarget(order.orderTarget.x, order.orderTarget.y);
		} else if (order.orderType == "breed") {
			state = AgentBreeding;
		} else if (order.orderType == "attack") {
			setTarget(order.orderTarget.x, order.orderTarget.y);
			state = AgentAttacking;
		}
		return true;
	}

	public function set_state(newState:AgentState):AgentState {
		// [@todo transitions - or just use a state machine]
		state = newState;
		stateTicks = 0;
		return state;
	}

	public function update() {
		stateTicks++;

		switch (state) {
			case AgentMoving:
				updateMovement();
			case AgentBreeding:
				if ( (stateTicks % TICKS_TO_BREED) == TICKS_TO_BREED-1 ) {
					breed();
				}
			case AgentAttacking:
				if ( (stateTicks % TICKS_TO_ATTACK) == TICKS_TO_ATTACK-1 ) {				
					updateAttack();
				}
			case AgentSeeking:
				if (stateTicks >= SEEK_TIMEOUT) {
					state = AgentIdling;
				} else {
					var agent:Agent = player.server.world.findNearestTo(targetPos.x, targetPos.y, "computer", SEEK_RANGE);
					if (agent != null) {
						state = AgentAttacking;
						targetPos.set(agent.pos.x, agent.pos.y);
					}
				}
			default:
				heal(0.1);
		}

		wasHit = false;
	}

	public function breed() {
		var level:Level = player.server.world.level;
		for (y in -1...2) {
			for (x in -1...2) {
				if (x == 0 && y == 0) continue;

				var tmpX = pos.x + x;
				var tmpY = pos.y + y;
				if (!level.getWall(tmpX, tmpY) && level.getAgent(tmpX, tmpY) == null) {
					var ent:Actor = AgentFactory.create(config.parent.typeName, player.name, tmpX, tmpY);
					HXP.scene.add(ent);	
					state = AgentIdling;	
					return;
				}
			}
		}
		HXP.log("no empty space in which to breed");
	}

	public function updateAttack() {
		var agent:Agent = player.server.world.level.getAgent(targetPos.x, targetPos.y);
		if (agent == null) {
			state = AgentSeeking;
			return;
		}
		Assets.sfxShoot.play(0.1);
		player.server.hurtAgent(config.get("str"), this, agent);
	}

	public function updateMovement() {
		if (path == null || path.length == 0) {
			onArrived();
			return;
		}

		var node:MapPoint = path.pop();

		if (node.equals(pos)) {
			if (!getNextPathNode()) {
				onArrived();
				return;
			}			
		}

		// HXP.log("walking!");
		var occupant:Agent = player.server.world.level.getAgent(node.x, node.y);
		if (occupant != null) {
			HXP.log("square was occupied by " + occupant);
			if (occupant.player != player) {
				HXP.log("Here is where we fight");
				return;			
			}
			swapWith(occupant);
		}
		// [@todo here is where we request a move from the server]
		player.server.world.level.setAgent(node.x, node.y, this);		
		player.server.world.level.setAgent(pos.x, pos.y, null);		

		pos.set(node.x, node.y);		
	}

	public function swapWith(other:Agent) {
		var tmp:MapPoint = new MapPoint(pos.x, pos.y);
		pos.set(other.pos.x, other.pos.y);
		other.pos.set(tmp.x, tmp.y);
		player.server.world.level.setAgent(pos.x, pos.y, this);		
		player.server.world.level.setAgent(tmp.x, tmp.y, other);		

	}

	public function setTarget(x:Int, y:Int) {
		targetPos = new MapPoint(x, y);
		state = AgentMoving;
		// temporarily force tile-based movement
		buildPath();		
	}

	public function buildPath() {
		path.clear();
		var tmp:MapPoint = new MapPoint(pos.x, pos.y);
		// HXP.log("building path from " + pos + " to " + targetPos);

		var maxIter:Int = 10;
		do {
			var dx:Int = targetPos.x - tmp.x;
			var dy:Int = targetPos.y - tmp.y;

			if ( Math.abs(dx) > Math.abs(dy) ) {
				tmp.x += cast HXP.clamp(dx, -1, 1);
			} else {
				tmp.y += cast HXP.clamp(dy, -1, 1);
			}
			var node:MapPoint = new MapPoint(tmp.x, tmp.y);
			// HXP.log(" -- " + node);
			path.add( node );
		} while (--maxIter > 0 && !tmp.equals(targetPos));
		// HXP.log("path has " + path.length + " entries");
	}	

	public function getNextPathNode():Bool {
		if (path == null) return false;
		if (path.length == 0) {
			return false;
		}
		var next:MapPoint = path.first();
		if (next.equals(pos)) {
			path.pop();
			if (path.length == 0) {
				onArrived();
				return false;
			}
			next = path.first();
		}
		targetPos.set(next.x, next.y);
		return true;
	}	

	public function onArrived() {
		// HXP.log("local onArrived");
		player.server.send(PathArrived, this, this);
	}

	public override function onPathArrived(evt:ServerEvent):Bool {
		// HXP.log("event PathArrived");
		state = AgentIdling;
		return true;
	}

	public override function onWasHit(evt:ServerEvent):Bool {
		HXP.log("OUCH!  I got hit by " + evt.source);
		wasHit = true;		
		var aggr = cast config.getData("behaviour.aggressiveness");

		if (aggr == null || cast(aggr, Float) > 0) {
			var srcAgent:Agent = cast evt.source;
			setTarget(srcAgent.pos.x, srcAgent.pos.y);
			state = AgentAttacking;
		}
		return true;
	}

	// [@note that there is no notification here as that comes via the event]
	// [@... this is just a convenience function for Server]
	public function hurt(amount:Float=0) {
		hitPoints -= amount;
	}

	public function heal(?amount:Float=0, ?allowOverHeal:Bool=false) {
		if (amount == 0) {
			// heal all the way
			hitPoints = config.get("vit");
		} else {
			hitPoints += amount;
			if (hitPoints > config.get("vit") && !allowOverHeal) {
				hitPoints = config.get("vit");
			}
		}
	}

	public function reset() {
		heal();
		movementPoints = config.get("spd");
		actionPoints = config.get("dex");
	}	

	public function toScreenX(mapX:Int):Float {
		return player.server.world.level.toScreenX(mapX);
	}
	public function toScreenY(mapY:Int):Float {
		return player.server.world.level.toScreenY(mapY);
	} 

	public function toMapX(scrX:Float):Int {
		return player.server.world.level.toMapX(scrX);
	}
	public function toMapY(scrY:Float):Int {
		return player.server.world.level.toMapY(scrY);	
	} 		
 }