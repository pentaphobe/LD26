
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import ui.Menu;
import ui.UIEntity;

class PlayScene extends Scene {
	var menu:Menu;
	public static var instance(get_instance, set_instance):PlayScene;
	public var levelSet:Array<String>;
	public var startLevelName:String;

	public function new() {
		super();
		instance = this;
		menu = new Menu("ingame", menuEvent, uiEvent, cast(HXP.screen.width / 2), cast(HXP.screen.height / 2));

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
		super.begin();
		HXP.log("entering game");

		setLevel(startLevelName);
		// createMap();
	}

	public override function update() {
		super.update();
		if (Input.pressed(Key.ESCAPE)) {
			if (menu.isActive) {
				menu.exit();
			} else {
				menu.enter();
				Assets.sfxSuwip.play();
				menu.pushState("main");
				// menu.enter();
			}			
		}				
		if (menu.isActive) {
			menu.update();
		} 
	}

	public override function render() {
		super.render();
		menu.render();
	}

	public function setLevel(name:String) {
		HXP.log("starting " + name);
	}

	public function menuEvent(action:String) {
		HXP.log("menuEvent:" + action);
		if (action == "exit") {
			HXP.scene = new MenuScene();
		} else if (action == "return") {
			HXP.log("trying to exit menu");
			menu.exit();
		}
	}

	public function uiEvent(eventType:String, source:UIEntity) {
		if (eventType == "onGotMouse") {
			Assets.sfxHover.play();
		} else if (eventType == "onClick") {
			Assets.sfxClick.play();
		}
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

	private static function set_instance(inst:PlayScene):PlayScene {
		instance = inst;
		return instance;
	}
}