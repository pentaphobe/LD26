package server;
import com.haxepunk.HXP;

import server.Player;
import server.Agent;

class ComputerPlayer extends Player {
	public var TICKS_PER_THINK:Int = 12;
 	// below this threshold we try to breed
 	public static var LOW_POPULATION_THRESH:Int = 6;
 	// if population is population < enemy.population * DESIRED_POPULATION_LEAD then it's like low population
 	public static var DESIRED_POPULATION_LEAD:Float = 1.5;
 	public static var IMPATIENCE_TICKS:Int = 30;

	private var tickCounter = 0;

	// this is set to our current population each think() before updating agents
	// this way, breed orders will be considered in our population estimate
	private var expectedPopulation = 0;
	private var desiredPopulation = 0;

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

		expectedPopulation = agents.length;
		var enemyPopulation = server.getPlayer("human").agents.length;
		desiredPopulation = cast(enemyPopulation * DESIRED_POPULATION_LEAD);
		for ( selected in agents ) {
			orderAgent(selected);	
		}
	}

	public function orderAgent(selected:Agent) {
		if (selected.state != Idling && selected.stateTicks < IMPATIENCE_TICKS) {
			return;
		}

		if (expectedPopulation < LOW_POPULATION_THRESH || expectedPopulation < desiredPopulation) {
			++expectedPopulation;
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

		var newX:Int = cast(HXP.clamp(HXP.random*server.world.level.mapWidth, 1, server.world.level.mapWidth-2));
		var newY:Int = cast(HXP.clamp(HXP.random*server.world.level.mapHeight, 1, server.world.level.mapHeight-2));
		
		server.sendOrder("move", newX, newY, selected);	
	}

	public override function toString():String {
		return "[ComputerPlayer]";
	}
}