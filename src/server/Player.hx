package server;
import com.haxepunk.HXP;

import utils.AgentTemplate;
import utils.AgentFactory;
import utils.MapPoint;


import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;




/** Placeholder
 */
class PlayerOrder {
	// can strictly be accessed via the agent, but allowing for some orders to be non-agent-specific
	public var player:Player;
	// if any (some orders are general player stuff)
	public var agent:Agent;
	// using string for now [@note fix this to enums once API is clear]
	public var orderType:String;
	// destination (MOVE), 
	// location of agent to attack(ATTACK[MELEE/RANGED])
	// or location of a place to fire towards (RANGED indirect)
	// the distinction being that only some attacks will care about who's there
	public var orderTarget:MapPoint;
	public function new(type:String, ?x:Int=-1, ?y:Int=-1, agent:Agent=null, player:Player=null) {
		this.orderType = type;
		this.orderTarget = new MapPoint(x, y);

		this.agent = agent;
		if (player == null && agent != null) {
			this.player = this.agent.player;	// may still be null
		} else {
			this.player = player;
		}
	}

	public function toString():String {
		return "[Order " + orderType + ":" + orderTarget + " owner:" + player + "]";
	}
}


class Player implements Orderable, implements ServerEventHandler {
	public var name:String;
	public var server:Server;

	public var agents:List<Agent>;

	public function new(name:String) {
		this.name = name;
		agents = new List<Agent>();
	}

	public function update() {
		for (agent in agents) {
			agent.update();
		}
	}

	/** Called by the main UI
	 * User -> Order -> Us!
	 */
	public function onOrder(order:PlayerOrder):Bool {
		// will forward to owned agents
		// HXP.log(name + " got order " + order);
		// HXP.log(" `-- attempting dispatch to " + agents.length + " agents");
		// potential intervention here

		for ( agent in agents ) {
			if (order.agent == agent || order.agent == null) {
				agent.onOrder(order);
			}
		}
		return true;
	}

	public function addAgent(agent:Agent):Agent {
		// HXP.log("addAgent:" + agent);
		if (agent == null) return null;
		// if (server != null) {
		// 	server.addHandler(agent);
		// }
		// HXP.log(" " + name + " taking responsibility");
		agent.player = this;
		agents.add(agent);
		return agent;
	}

	public function removeAgent(agent:Agent) {
		agents.remove(agent);
	}

	/**** ServerEventHandler stuff 
	 * [@note this could be a lot cleaner if we derived from the dispatcher, and made dispatcher derive from handler]
	 */
	public function onEvent(event:ServerEvent):Bool {
		return event.target.onEvent(event);
	}

	public function onPathArrived(event:ServerEvent):Bool {
		return event.target.onPathArrived(event);
	}
	public function onPathCancelled(event:ServerEvent):Bool {
		return event.target.onPathCancelled(event);
	}
	public function onPathBlocked(event:ServerEvent):Bool {
		return event.target.onPathBlocked(event);
	}
	public function onWasHit(event:ServerEvent):Bool {
		return event.target.onWasHit(event);
	}
	public function onWasKilled(event:ServerEvent):Bool {
		return event.target.onWasKilled(event);
	}
	public function onSuccessfulKill(event:ServerEvent):Bool {
		return event.target.onSuccessfulKill(event);
	}

	public function onTargetFound(event:ServerEvent):Bool {
		return event.target.onTargetFound(event);
	}	

	public function isPromiscuous():Bool {
		return true;
	}

	public function toString():String {
		return "[Player " + name + "]";
	}
}