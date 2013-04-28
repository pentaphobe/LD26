package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;

import entities.Actor;

interface Orderable {
	public function onOrder(order:PlayerOrder):Bool;
}

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

/** Placeholder
 *
 * Agents will be the low-level aspect of entities in the
 * game logic
 * currently Actors are handling all of it, but that's causing
 * weirdness, so I'm moving over to this split and Actors
 * will just be visual representations of the Agent data
 * (with interpolation etc)
 */ 
 class Agent extends BasicServerEventHandler, implements Orderable {
 	public var player:Player; 	
 	public var actor:Actor;
 	public var pos:MapPoint;
	public function onOrder(order:PlayerOrder):Bool {
		HXP.log("agent order mutta flichers! " + order);
		return true;
	}
 }


class Player extends BasicServerEventHandler, implements Orderable {
	public var name:String;
	public var server:Server;

	var agents:List<Agent>;

	public function new(name:String) {
		this.name = name;
		agents = new List<Agent>();
	}

	/** Called by the main UI
	 * User -> Order -> Us!
	 */
	public function onOrder(order:PlayerOrder):Bool {
		// will forward to owned agents
		HXP.log(name + " got order " + order);
		// potential intervention here

		for ( agent in agents ) {
			if (order.agent == agent || order.agent == null) {
				agent.onOrder(order);
			}
		}
		return true;
	}

	public function addAgent(agent:Agent):Agent {
		if (agent == null) return null;
		if (server != null) {
			server.addHandler(agent);
		}
		agent.player = this;
		agents.add(agent);
		return agent;
	}

	public function toString():String {
		return "[Player " + name + "]";
	}
}