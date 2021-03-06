package server;
import com.haxepunk.HXP;
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
		agents.clear();		
		HXP.log("about to load id:" + currentLevel + ", " + server.lobby.levelList[currentLevel]);
		level.load(server.lobby.levelList[currentLevel]);
	}

	public function nextLevel():Bool {
		if (currentLevel >= server.lobby.levelList.length-1) {
			return false;
		}
		currentLevel++;
		loadCurrentLevel();
		return true;
	}

	public function prevLevel():Bool {
		if (currentLevel == 0) {
			return false;
		}
		currentLevel--;
		loadCurrentLevel();
		return true;
	}

	public function addAgent(agent:Agent):Agent {
		agents.add(agent);
		level.setAgent(agent.pos.x, agent.pos.y, agent);
		return agent;
	}

	public function findNearestTo(x:Int, y:Int, ?team:String=null, ?maxRange:Float=-1):Agent {
		// HXP.log("seeking near " + x + ", " + y + " for team " + team + " in range " + maxRange);
		var best:Agent = null;
		var bestDist:Float = 100000;
		if (maxRange != -1) {
			maxRange = (maxRange*maxRange) + (maxRange*maxRange);
		}
		for (agent in agents) {
			var dx:Float = agent.pos.x - x;
			var dy:Float = agent.pos.y - y;
			var dst:Float = (dx*dx + dy*dy);
			if (dst < bestDist && (maxRange == -1 || dst < maxRange)) {
				// HXP.log("got one in range");
				if (team != null && agent.player.name != team) {
					// HXP.log("  but wrong team");
					continue;
				}
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