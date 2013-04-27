
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.tweens.motion.LinearMotion;

import ui.Menu;
import ui.UIEntity;
import utils.ActorFactory;
import com.haxepunk.Tween;


class PlayScene extends Scene {
	//***** TEMPORARY *******
	var testEntity:Entity;
	//***** /TEMPORARY ******

	var menu:Menu;
	public static var instance(get_instance, set_instance):PlayScene;
	public static var TILE_SIZE:Int = 32;
	public static var HTILE_SIZE:Int = cast (TILE_SIZE/2);
	// how many seconds per AI processing step
	public static var AI_RATE:Float = 0.5;

	public var levelSet:Array<String>;
	public var startLevelName:String;

	public function new() {
		super();
		instance = this;
		menu = new Menu("ingame", menuEvent, uiEvent, cast(HXP.screen.width / 2), cast(HXP.screen.height / 2));

		loadLevelSet();
		loadActorTemplates();
	}	

	public function loadLevelSet() {
		var levelsFile:Dynamic = Utils.loadJson("levels");
		var levelsList:Array<Dynamic> = cast levelsFile.levels;
		startLevelName = levelsFile.start;
		levelSet = new Array<String>();
		for ( idx in 0...levelsList.length) {
			levelSet[idx] = cast levelsList[idx];
		}		
		HXP.log("First level: " + startLevelName);
	}

	public override function begin() {
		super.begin();
		HXP.log("entering game");

		setLevel(startLevelName);

		var debug = Image.createRect(TILE_SIZE, TILE_SIZE, 0xff00ff);
		testEntity = new Entity(HXP.screen.width / 2, HXP.screen.height / 2, debug);
		add(testEntity);
		// createMap();

		// Keep this for last
		HXP.alarm(AI_RATE, doAiMove, TweenType.Looping, this);		
	}

	public function doAiMove(event:Dynamic) {
		HXP.log("Ai update");
		var newX:Float = testEntity.x + (Math.random()-0.5)*20;
		var newY:Float = testEntity.y + (Math.random()-0.5)*20;
		var tween:LinearMotion = new LinearMotion(tweenComplete, TweenType.OneShot);
		tween.setMotion(testEntity.x, testEntity.y, newX, newY, AI_RATE);
		testEntity.addTween(tween, true);
	}

	public function tweenComplete(event:Dynamic) {
		HXP.log("Tween complete");
	}

	public override function update() {
		super.update();
		// a little special case code for in-game menu since it acts differently
		updateMenu();
	}

	public override function render() {
		super.render();
		menu.render();
	}

	public function loadActorTemplates() {
		ActorFactory.load( Utils.loadJson("actors") );
	}


	public function setLevel(name:String) {
		HXP.log("starting " + name);
	}

	public function updateMenu() {
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