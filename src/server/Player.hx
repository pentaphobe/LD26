package server;
import com.haxepunk.HXP;

import server.ServerEventHandler;
import server.ServerEvent;
import server.Server;
import server.Lobby;


/** Placeholder
 */
class PlayerOrder {

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
 class Agent extends BasicServerEventHandler {
 	public var owner:Player;
 }


class Player extends BasicServerEventHandler {
	public var name:String;
	public var server:Server;

	var agents:List<Agent>;

	public function new(name:String) {
		this.name = name;
		agents = new List<Agent>();
	}

	public function onOrder(order:PlayerOrder) {

	}

	public function addAgent(agent:Agent):Agent {
		if (agent == null) return null;

		agent.owner = this;
		agents.add(agent);
		return agent;
	}

	public function toString():String {
		return "[Player " + name + "]";
	}
}