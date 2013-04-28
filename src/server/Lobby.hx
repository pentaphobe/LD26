package server;
import com.haxepunk.HXP;


class Lobby {
	public var jsonData:Dynamic;
	public var levelList:Array<String>;
	public var startLevelSetName:String;
	public var server:Server;
	
	public function new(server:Server) {
		this.server = server;
		loadLevelSet();
	}

	public function loadLevelSet() {
		jsonData = Utils.loadJson("levels");
		startLevelSetName = jsonData.start;
		var levelSet:Dynamic = Reflect.field(jsonData.levelSets, startLevelSetName);
		if (levelSet == null) {
			HXP.log("error loading level set " + startLevelSetName);
			return;
		}
		HXP.log(levelSet);
		var tmpList:Array<Dynamic> = cast levelSet;

		levelList = new Array<String>();
		for ( idx in 0...tmpList.length) {
			levelList[idx] = cast tmpList[idx];			
		}		
		HXP.log("First level set: " + startLevelSetName);
	}	
}