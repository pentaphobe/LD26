package server;
import com.haxepunk.HXP;

import utils.AgentTemplate;
import utils.AgentFactory;
import utils.MapPoint;

// naughty naughty.
// import scenes.PlayScene;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;
import server.Orderable;
import server.Player;


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

 	public function new(?x:Int=0, ?y:Int=0) {
 		pos = new MapPoint(x, y);
		targetPos = new MapPoint();
		path = new List<MapPoint>();		 		
 	}
	public function onOrder(order:PlayerOrder):Bool {
		HXP.log("agent order mutta flichers! " + order);
		if (order.orderType == "move") {
			setTarget(order.orderTarget.x, order.orderTarget.y);
		}
		return true;
	}

	public function update() {
		if (path == null || path.length == 0) return;

		var node:MapPoint = path.pop();

		if (node.equals(pos)) {
			if (!getNextPathNode()) {
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
		// if (tween == null) {
		// 	tween = new LinearMotion(null, TweenType.Persist);
		// 	addTween(tween);
		// 	HXP.log("created new tweener");
		// }
		// tween.setMotionSpeed(this.x, this.y, toScreenX(x), toScreenY(y), config.get("spd") * PlayScene.TILE_SIZE);
		// tween.start();

		// temporarily force tile-based movement
		buildPath();		
	}

	public function buildPath() {
		path.clear();
		var tmp:MapPoint = new MapPoint(pos.x, pos.y);
		HXP.log("building path from " + pos + " to " + targetPos);

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
			HXP.log(" -- " + node);
			path.add( node );
		} while (--maxIter > 0 && !tmp.equals(targetPos));
		HXP.log("path has " + path.length + " entries");
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
		player.server.send(PathArrived, this, this);
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