package server;
import entities.Level;


class World {
	public var currentLevel:Int;
	public var level:Level;
	public var agents:List<Agent>;
	
	public var server:Server;

	public function new(server:Server) {
		this.server = server;
		agents = new List<Agent>();
		reset();
	}	

	public function loadCurrentLevel() {
		level.load(server.lobby.levelList[currentLevel]);
	}

	public function nextLevel():Bool {
		if (currentLevel >= server.lobby.levelList.length) {
			return false;
		}
		currentLevel++;
		loadCurrentLevel();
		return true;
	}

	public function addAgent(agent:Agent):Agent {
		agents.add(agent);
		level.setAgent(agent.pos.x, agent.pos.y, agent);
		return agent;
	}

	public function findNearestTo(x:Int, y:Int, ?maxRange:Float=-1):Agent {
		var best:Agent = null;
		var bestDist:Float = 100000;
		if (maxRange != -1) {
			maxRange *= maxRange;
		}
		for (agent in agents) {
			var dx:Float = agent.pos.x - x;
			var dy:Float = agent.pos.y - y;
			var dst:Float = (dx*dx + dy*dy);
			if (dst < bestDist && (maxRange == -1 || dst < maxRange)) {
				best = agent;
				bestDist = dst;
			}
		}
		return best;
	}

	public function reset() {
		level = new Level();
		currentLevel = 0;				
	}
}