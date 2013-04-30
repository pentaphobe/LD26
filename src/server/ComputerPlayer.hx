package server;
import com.haxepunk.HXP;

import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public var TICKS_PER_THINK:Int = 12;
 	// below this threshold we try to breed
 	public static var LOW_POPULATION_THRESH:Int = 3;
 	// if population is enemy.population * HIGH_POP_LEAD_THRESH then we don't bother breeding;
 	public static var HIGH_POPULATION_LEAD:Float = 2.5;
 	public static var IMPATIENCE_TICKS:Int = 30;

	private var tickCounter = 0;

	public function new() {
		super("computer");
	}

	public override function update() {
		super.update();
		if ( (++tickCounter) % TICKS_PER_THINK == 0) {
			think();
		}
	}

	public function think() {
		// HXP.log("Computer moving " + agents.length + " agents");
		if (agents.length == 0) return;	

		// var idx:Int = cast(Math.random() * agents.length);
		// var cnt:Int = 0;
		// var selected:Agent = null;
		// for (agent in agents) {
		// 	if (cnt == idx) {
		// 		selected = agent;
		// 	}
		// 	cnt++;
		// }

		// if (selected == null) {
		// 	// should never happen unless we're all dead which will get caught by the server
		// 	return;
		// }
		for ( selected in agents ) {
			orderAgent(selected);	
		}
	}

	public function orderAgent(selected:Agent) {
		if (selected.state != AgentIdling && selected.stateTicks < IMPATIENCE_TICKS) {
			return;
		}

		if (agents.length < LOW_POPULATION_THRESH) {
			server.sendOrder("breed", 0, 0, selected);
			return;
		}

		var nearBy:Agent = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", Agent.FIRE_RANGE);	
		if (nearBy != null) {
			server.sendOrder("attack", nearBy.pos.x, nearBy.pos.y, selected);
			return;
		}

		nearBy = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", Agent.SEEK_RANGE);	
		if (nearBy != null) {
			server.sendOrder("move", nearBy.pos.x, nearBy.pos.y, selected);
			return;
		}

		var newX:Int = cast(HXP.clamp(Math.random()*server.world.level.mapWidth, 1, server.world.level.mapWidth-2));
		var newY:Int = cast(HXP.clamp(Math.random()*server.world.level.mapHeight, 1, server.world.level.mapHeight-2));
		
		server.sendOrder("move", newX, newY, selected);	
	}

	public override function toString():String {
		return "[ComputerPlayer]";
	}
}