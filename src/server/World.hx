package server;
import entities.Level;


class World {
	public var currentLevel:Int;
	public var level:Level;
	
	public var server:Server;

	public function new(server:Server) {
		this.server = server;
		reset();
	}	

	public function loadCurrentLevel() {
		level.load(server.lobby.levelList[currentLevel]);
	}

	public function reset() {
		level = new Level();
		currentLevel = 0;				
	}
}