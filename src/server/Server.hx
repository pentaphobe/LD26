package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Lobby;

class Player extends BasicServerEventHandler {
	public var name:String;
	public function new(name:String) {
		this.name = name;
	}
	public function toString():String {
		return "[Player " + name + "]";
	}
}

class Server extends ServerEventDispatcher {
	var players:List<Player>;
	var playerHash:Hash<Player>;

	public var localPlayer:Player;
	// var world:World;
	public var lobby:Lobby;

	public function new(?existingLocalPlayer:Player = null) {
		super();

		// [@note some of this should probably be moved to a "begin"]
		// [@... or "reset" method]

		// lobby = new Lobby();
		// world = new World();
		players = new List<Player>();
		playerHash = new Hash<Player>();

		if (existingLocalPlayer == null) {
			localPlayer = createPlayer("human");
		} else {
			localPlayer = addPlayer(existingLocalPlayer);
		}

		lobby = new Lobby();
	}

	public override function update() {
		// update events
		super.update();

		// get orders
		// update agents
		// update world
	}

	/** overrides default behaviour and only sends
	 * events to their targets
	 */
	override function dispatchEvent(evt:ServerEvent) {
		// [@note currently ignores return value, potentially should skip the switch sometimes]
		var handler:ServerEventHandler = evt.target;
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
			default:
		}
	}

	public function sendByName(type:ServerEventType, ?target:String="", ?src:String=""):ServerEvent {
		var srcPlayer:Player = playerHash.get(src);
		var targetPlayer:Player = playerHash.get(target);
		return send(type, targetPlayer, srcPlayer);
	}

	public function createPlayer(name:String):Player {
		var p:Player = new Player(name);
		addPlayer(p);
		return p;
	}
	private function addPlayer(p:Player):Player {
		if (p == null) {
			return null;
		}
		players.add(p);
		playerHash.set(p.name, p);
		super.addHandler(p);
		return p;
	}
}