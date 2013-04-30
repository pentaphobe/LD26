package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Lobby;
import server.Player;
import server.World;


class Server extends ServerEventDispatcher, implements Orderable {
	var players:List<Player>;
	var playerHash:Hash<Player>;

	public var localPlayer:Player;
	public var world:World;
	public var lobby:Lobby;

	public function new(?startLevelSetName:String=null, ?existingLocalPlayer:Player = null) {
		super();

		// [@note some of this should probably be moved to a "begin"]
		// [@... or "reset" method]

		// lobby = new Lobby();
		// world = new World();
		lobby = new Lobby(this);
		lobby.loadLevelSet(startLevelSetName);
		world = new World(this);

		reset(existingLocalPlayer);


	}

	public override function update() {
		// update events
		super.update();

		// get orders
		// update players
		for (player in players) {
			player.update();
		}
		// update world

		// cull deaths
		var toRemove:List<Agent> = new List<Agent>();
		for (agent in world.agents) {
			if (!agent.isAlive) {
				toRemove.add(agent);
			}
		}
		for (dead in toRemove) {
			world.agents.remove(dead);
			dead.player.removeAgent(dead);
			world.level.setAgent(dead.pos.x, dead.pos.y, null);
		}
	}

	public function reset(?existingLocalPlayer:Player = null, ?levelChangeDirection:Int=0) {
		if (players == null) {
			players = new List<Player>();
			playerHash = new Hash<Player>();

		} else {			
			for (player in players) {
				removePlayer(player);
			}
		}

		// this is a bit specific - should be called from higher up the chain (like in PlayScene)
		if (existingLocalPlayer == null) {
			localPlayer = createHumanPlayer();
		} else {
			localPlayer = addPlayer(existingLocalPlayer);
		}		

		if (levelChangeDirection < 0) {
			world.prevLevel();
		} else if (levelChangeDirection > 0) {
			world.nextLevel();
		}
		world.loadCurrentLevel();
	}

	public function sendLocalOrder(type:String, ?x:Int=0, ?y:Int=0, ?agent:Agent) {
		var order:PlayerOrder = new PlayerOrder(type, x, y, agent, localPlayer);
		onOrder(order);
	}

	public function sendOrder(type:String, ?x:Int=0, ?y:Int=0, ?agent:Agent) {
		var order:PlayerOrder = new PlayerOrder(type, x, y, agent, agent.player);
		onOrder(order);		
	}		

	// [@todo orders are instantly sent presently - is this good?]
	// [@... should they instead just use the same event system?]
	public function onOrder(order:PlayerOrder):Bool {
		// validate the orders here
		// then forward to owned players
		if (order.player != null) {
			order.player.onOrder(order);
			return true;
		}

		HXP.log("I refuse to send malformed orders, you lazy dog");
		return false;
	}


	// disabled since this capability has been added to 
	// Server and ServerEventHandler
	// /** overrides default behaviour and only sends
	//  * events to their targets
	//  */
	// override function dispatchEvent(evt:ServerEvent) {
	// 	// [@note currently ignores return value, potentially should skip the switch sometimes]
	// 	var handler:ServerEventHandler = evt.target;		
	// 	handler.onEvent(evt);
	// 	switch (evt.type) {
	// 		case PathArrived:
	// 			handler.onPathArrived(evt);
	// 		case PathCancelled:
	// 			handler.onPathCancelled(evt);
	// 		case PathBlocked:
	// 			handler.onPathBlocked(evt);
	// 		case WasHit:
	// 			handler.onWasHit(evt);
	// 		case TargetFound:
	// 			handler.onTargetFound(evt);
	// 		default:
	// 	}
	// }

	public function hurtAgent(amount:Float, ?src:Agent, ?target:Agent) {
		target.hurt(amount);
		send(WasHit, src, target);
		send(SuccessfulHit, target, src);
		if (target.hitPoints < 0) {
			target.isAlive = false;
			send(WasKilled, src, target);
			send(SuccessfulKill, target, src);
		}
	}

	public function sendByName(type:ServerEventType, ?src:String="", ?target:String=""):ServerEvent {
		var srcPlayer:Player = playerHash.get(src);
		var targetPlayer:Player = playerHash.get(target);
		return send(type, srcPlayer, targetPlayer);
	}

	public override function send(type:ServerEventType, ?src:ServerEventHandler=null, ?target:ServerEventHandler=null):ServerEvent {
		if (Std.is(target, Agent)) {
			var agent:Agent = cast target;
			HXP.log("Sending player event " + type);
			super.send(type, src, agent.player);
		}
		return super.send(type, src, target);
	}

	public function createHumanPlayer():Player {
		var p:Player = new HumanPlayer("human");
		addPlayer(p);
		return p;
	}
	public function createPlayer(name:String):Player {
		var p:Player = new Player(name);
		addPlayer(p);
		return p;
	}

	public function createAgent(playerName:String, ?x:Int=0, ?y:Int=0):Agent {
		var agent:Agent = new Agent(x, y);
		agent.player = getPlayer(playerName);
		world.addAgent(agent);
		// HXP.log("player:" + agent.player);
		// HXP.log(" `- pos:" + agent.pos);
		agent.player.addAgent(agent);
		return agent;
	}

	public function removePlayer(player:Player) {
		if (playerHash.exists(player.name)) {
			playerHash.remove(player.name);
		}
		players.remove(player);
	}

	public function getPlayer(name:String):Player {
		if (!playerHash.exists(name)) {
			HXP.log("failed to find player named " + name);
			return null;
		}
		return playerHash.get(name);
	}

	public function addPlayer(p:Player):Player {
		if (p == null) {
			return null;
		}
		players.add(p);
		playerHash.set(p.name, p);
		p.server = this;
		super.addHandler(p);		
		return p;
	}
}