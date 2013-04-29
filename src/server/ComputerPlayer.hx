package server;
import com.haxepunk.HXP;

import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public var TICKS_PER_THINK:Int = 12;
 	public static var SEEK_RANGE:Float = 30;

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


		// just pick a random agent and tell it to move
		// kludgy loop since List doesn't have a get
		var idx:Int = cast(Math.random() * agents.length);
		var cnt:Int = 0;
		var selected:Agent = null;
		for (agent in agents) {
			if (cnt == idx) {
				selected = agent;
			}
			cnt++;
		}
		if (selected != null) {
			var nearBy:Agent = server.world.findNearestTo(selected.pos.x, selected.pos.y, "human", SEEK_RANGE);
			if (nearBy != null) {
				server.sendOrder("attack", nearBy.pos.x, nearBy.pos.y, selected);
				return;
			}
			var newX:Int = cast(HXP.clamp(Math.random()*server.world.level.mapWidth, 1, server.world.level.mapWidth-2));
			var newY:Int = cast(HXP.clamp(Math.random()*server.world.level.mapHeight, 1, server.world.level.mapHeight-2));
			
			server.sendOrder("move", newX, newY, selected);
		}		
	}

	public override function toString():String {
		return "[ComputerPlayer]";
	}
}