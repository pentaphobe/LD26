package server;
import com.haxepunk.HXP;

import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public function new() {
		super("computer");
	}

	public override function update() {
		super.update();
		HXP.log("Computer moving " + agents.length + " agents");
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
			var newX:Int = cast(HXP.clamp(Math.random()*server.world.level.mapWidth, 1, server.world.level.mapWidth-2));
			var newY:Int = cast(HXP.clamp(Math.random()*server.world.level.mapHeight, 1, server.world.level.mapHeight-2));
	
			server.sendOrder("move", newX, newY, selected);
		}
	}

	public override function toString():String {
		return "[ComputerPlayer]";
	}
}