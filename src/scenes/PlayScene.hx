
package scenes;
import nme.geom.Point;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.tweens.motion.LinearMotion;
import com.haxepunk.utils.Draw;

import states.StateMachine;
import states.PrototypeState;
import states.UIState;
import ui.Menu;
import ui.UIEntity;
import entities.Actor;
import utils.ActorFactory;
import com.haxepunk.Tween;


class PlayScene extends Scene {
	//***** TEMPORARY *******
	var testEntity:Actor;
	var startDragPoint:Point;
	var selectedEntities:Array<Entity>;
	var background:Entity;
	//***** /TEMPORARY ******

	var menu:Menu;
	var uiStates:StateMachine<UIState>;
	public static var instance(get_instance, set_instance):PlayScene;
	public static var TILE_SIZE:Int = 32;
	public static var HTILE_SIZE:Int = cast (TILE_SIZE/2);
	// how many seconds per AI processing step
	public static var AI_RATE:Float = 0.5;
	public static var AGENT_RATE:Float = 0.2;

	public var levelSet:Array<String>;
	public var startLevelName:String;

	public function new() {
		super();
		instance = this;
		menu = new Menu("ingame", menuEvent, uiEvent, cast(HXP.screen.width / 2), cast(HXP.screen.height / 2));

		loadLevelSet();
		loadActorTemplates();

		selectedEntities = new Array<Entity>();

		uiStates = new StateMachine<UIState>("ui");
		var testState:UIState = new UIState("select");
		testState.setOverride(CustomUpdate, function (owner:PrototypeState) {
			HXP.log("updating select");
			if (Input.mousePressed) {
				startDragPoint = new Point(mouseX, mouseY);
				if (!Input.check(Key.SHIFT)) {
					selectedEntities = new Array<Entity>();
				}
			} else if (Input.mouseReleased) {
				selectEntities(startDragPoint.x, startDragPoint.y, mouseX - startDragPoint.x, mouseY - startDragPoint.y);
				startDragPoint = null;
			}
		});
		testState.setOverride(CustomRender, function (owner:PrototypeState) {
			if (startDragPoint != null && Input.mouseDown) {
				var w:Int = cast(mouseX - startDragPoint.x);
				var h:Int = cast(mouseY - startDragPoint.y);
				Draw.rectPlus(cast startDragPoint.x, cast startDragPoint.y, w, h, 0x00ff00, 0.5, 3);
			}
		});
		uiStates.addStateAndEnter(testState);

		testState = new UIState("orderMove");
		testState.setOverride(CustomUpdate, function (owner:PrototypeState) {
			if (Input.mouseReleased) {
				
				owner.isDone = true;
				// HXP.log("Attempting to order " + selectedEntities.length + " entities");
				for (entity in selectedEntities) {
					HXP.log("ordered movement of " + entity + " to " + mouseX + ", " + mouseY);
					cast(entity, Actor).setTarget(mouseX, mouseY);
				}
			}
		});
		uiStates.addState(testState);
	}	

	public function selectEntities(x:Float, y:Float, w:Float, h:Float) {
		if (w < 0) {
			x += w;
			w = -w;
		}		
		if (h < 0) {
			y += h;
			h = -h;
		}
		var MIN_RECT_SIZE:Int = 4;
		if (w < MIN_RECT_SIZE && h < MIN_RECT_SIZE) {
			// this rectangle is considered a click, so we'll just choose an entity and bring it to the "back"
			var ent:Entity = collideRect("computer", x, y, w, h);
			if (ent == null) return;

			sendToBack(ent);
			bringForward(ent);
			selectedEntities.push(ent);
		} else {
			collideRectInto("computer", x, y, w, h, selectedEntities);
		}
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

		uiStates.enter();
		HXP.log("entering game");

		setLevel(startLevelName);


		var bgScroller = new Backdrop("gfx/gridbg.png", true, true);
		background = new Entity(0, 0, bgScroller);
		add(background);


		testEntity = ActorFactory.create("basic", "computer", HXP.screen.width / 2, HXP.screen.height / 2);
		add(testEntity);
		testEntity = ActorFactory.create("scout", "computer", HXP.screen.width / 3, HXP.screen.height / 2);
		add(testEntity);
		testEntity = ActorFactory.create("heavy", "computer", HXP.screen.width * 2 / 3, HXP.screen.height / 2);
		add(testEntity);

		// createMap();

		// Keep this for last
		HXP.alarm(AI_RATE, doAiMove, TweenType.Looping, this);	
		HXP.alarm(AGENT_RATE, doAgentMove, TweenType.Looping, this);	
	}

	public function doAiMove(event:Dynamic) {
		if (menu.isActive) {
			return;
		}
		// HXP.log("Ai update");
		if (testEntity.tween != null && !testEntity.tween.active) {
			var newX:Float = testEntity.x + (Math.random()-0.5)*50;
			var newY:Float = testEntity.y + (Math.random()-0.5)*50;
			testEntity.setTarget(newX, newY);
		}
	}

	public function doAgentMove(event:Dynamic) {

	}

	public function tweenComplete(event:Dynamic) {
		HXP.log("Tween complete");
	}

	public override function update() {
		super.update();
		if (!menu.isActive) {
			background.x += 0.1;
			background.y += 0.05;
		}
		if (Input.pressed(Key.M)) {
			uiStates.pushState("orderMove");
		} 
		if (uiStates.getCurrent() == null) {
			uiStates.pushState("select");
		}
		uiStates.update();
		// a little special case code for in-game menu since it acts differently
		updateMenu();
	}

	public override function render() {
		super.render();
		uiStates.render();
		for ( entity in selectedEntities) {
			// Draw.hitbox(entity, true, 0x00ff00, 0.5);
			Draw.circlePlus(cast entity.x, cast entity.y, TILE_SIZE+2, 0x00FF00, 0.5, false, 2);
		}
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