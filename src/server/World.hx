package server;
import entities.Level;


class World {
	public var currentLevel:Int;
	public var level:Level;
	var agents:List<Agent>;
	
	public var server:Server;

	public function new(server:Server) {
		this.server = server;
		agents = new List<Agent>();
		reset();
	}	

	public function loadCurrentLevel() {
		level.load(server.lobby.levelList[currentLevel]);
	}

	public function addAgent(agent:Agent):Agent {
		agents.add(agent);
		level.setAgent(agent.pos.x, agent.pos.y, agent);
		return agent;
	}

	public function reset() {
		level = new Level();
		currentLevel = 0;				
	}
}