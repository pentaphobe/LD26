
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;

class PlayScene extends Scene {
	public static var instance(get_instance, never):PlayScene;
	public var levelSet:Array<String>;
	public var startLevelName:String;

	public function new() {
		super();

		var levelsFile:Dynamic = Utils.loadJson("levels");
		var levelsList:Array<Dynamic> = cast levelsFile.levels;
		startLevelName = levelsFile.start;
		levelSet = new Array<String>();
		for ( idx in 0...levelsList.length) {
			levelSet[idx] = cast levelsList[idx];
			HXP.log(levelSet[idx]);
		}
	}	

	public override function begin() {
		HXP.log("entering game");

		setLevel(startLevelName);

		// createMap();
	}

	public function setLevel(name:String) {
		HXP.log("starting " + name);
	}

	public static function get_instance():PlayScene {
		if (instance == null) {
			// normally you'd spawn this for singletons, but this is unnecessary
			// and should never happen if I'm doing things right, so error messages only
			HXP.log("You done goofed.  Why are you trying to get PlayScene's instance?");
			// also worth noting that any situation when I'd be creating an instance here
			// would be a mistake worth finding, so null should help us find it :)
			return null;
		}
		return instance;
	}
}