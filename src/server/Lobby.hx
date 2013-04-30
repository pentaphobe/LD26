package server;
import com.haxepunk.HXP;


class Lobby {
	public var jsonData:Dynamic;
	public var levelList:Array<String>;
	public var startLevelSetName:String;
	public var server:Server;
	
	public function new(server:Server, ?startLevelSet:String = null) {
		this.server = server;
		loadLevelSet(startLevelSet);
	}

	public function loadLevelSet(?startLevelSet:String = null) {
		jsonData = Utils.loadJson("levels");
		if (startLevelSet != null) {
			startLevelSetName = startLevelSet;
		} else {
			startLevelSetName = jsonData.start;
		}
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