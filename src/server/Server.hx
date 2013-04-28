package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Lobby;
import server.Player;


class Server extends ServerEventDispatcher, implements Orderable {
	var players:List<Player>;
	var agents:List<Agent>;
	var playerHash:Hash<Player>;

	public var localPlayer:Player;
	public var world:World;
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

		lobby = new Lobby(this);
		lobby.loadLevelSet();
		world = new World(this);
	}

	public override function update() {
		// update events
		super.update();

		// get orders
		// update agents
		// update world
	}

	public function sendLocalOrder(type:String, ?x:Int=0, ?y:Int=0, ?agent:Agent) {
		var order:PlayerOrder = new PlayerOrder(type, x, y, agent, localPlayer);
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

	public function sendByName(type:ServerEventType, ?src:String="", ?target:String=""):ServerEvent {
		var srcPlayer:Player = playerHash.get(src);
		var targetPlayer:Player = playerHash.get(target);
		return send(type, srcPlayer, targetPlayer);
	}

	public function createPlayer(name:String):Player {
		var p:Player = new Player(name);
		addPlayer(p);
		return p;
	}

	public function getPlayer(name:String):Player {
		if (!playerHash.exists(name)) return null;
		return playerHash.get(name);
	}

	private function addPlayer(p:Player):Player {
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