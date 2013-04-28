package server;
import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public function new() {
		super("computer");
	}

	public override function update() {
		super.update();
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
			var newX:Int = cast(Math.random()*server.world.level.mapWidth);
			var newY:Int = cast(Math.random()*server.world.level.mapHeight);
	
			server.sendOrder("move", newX, newY, selected);
		}
	}

	public function toString():String {
		return "[ComputerPlayer]";
	}
}