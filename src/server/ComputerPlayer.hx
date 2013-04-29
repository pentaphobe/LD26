package server;
import com.haxepunk.HXP;

import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public var TICKS_PER_THINK:Int = 12;
 	public static var SEEK_RANGE:Float = 9;
 	public static var FIRE_RANGE:Float = 6;
 	// below this threshold we try to breed
 	public static var LOW_POPULATION_THRESH:Int = 3;
 	// if population is enemy.population * HIGH_POP_LEAD_THRESH then we don't bother breeding;
 	public static var HIGH_POPULATION_LEAD:Float = 2.5;

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


		// // just pick a random agent and tell it to move
		// // kludgy loop since List doesn't have a get
		// var idx:Int = cast(Math.random() * agents.length);
		// var cnt:Int = 0;
		// var selected:Agent = null;
		// for (agent in agents) {
		// 	if (cnt == idx) {
		// 		selected = agent;
		// 	}
		// 	cnt++;
		// }
		// if (selected != null) {
		// 	var nearBy:Agent = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", SEEK_RANGE);
		// 	if (nearBy != null) {
		// 		server.sendOrder("attack", nearBy.pos.x, nearBy.pos.y, selected);
		// 		return;
		// 	}
		// 	var newX:Int = cast(HXP.clamp(Math.random()*server.world.level.mapWidth, 1, server.world.level.mapWidth-2));
		// 	var newY:Int = cast(HXP.clamp(Math.random()*server.world.level.mapHeight, 1, server.world.level.mapHeight-2));
			
		// 	server.sendOrder("move", newX, newY, selected);
		// }	

		var idx:Int = cast(Math.random() * agents.length);
		var cnt:Int = 0;
		var selected:Agent = null;
		for (agent in agents) {
			if (cnt == idx) {
				selected = agent;
			}
			cnt++;
		}

		if (selected == null) {
			// should never happen unless we're all dead which will get caught by the server
			return;
		}

		if (agents.length < LOW_POPULATION_THRESH) {
			server.sendOrder("breed", 0, 0, selected);
			return;
		}

		var nearBy:Agent = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", FIRE_RANGE);	
		if (nearBy != null) {
			server.sendOrder("attack", nearBy.pos.x, nearBy.pos.y, selected);
			return;
		}

		nearBy = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", SEEK_RANGE);	
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