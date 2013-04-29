
package scenes;
import nme.geom.Point;
import nme.display.BitmapData;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.tweens.motion.LinearMotion;
import com.haxepunk.utils.Draw;
import nme.filters.GlowFilter;
import nme.filters.BlurFilter;

import states.StateMachine;
import states.PrototypeState;
import states.UIState;
import ui.Menu;
import ui.UIEntity;
import entities.Actor;
import utils.AgentFactory;
import entities.Level;
import com.haxepunk.Tween;

import server.Lobby;
import server.Server;
import server.World;
import server.Agent;
import server.ComputerPlayer;
import entities.ParticleController;

class PlayScene extends Scene {
	//***** TEMPORARY *******
	var uiOverlay:Entity;
	var agentInfoText:Text;
	var testEntity:Actor;
	var startDragPoint:Point;
	var selectedEntities:Array<Entity>;
	var background:Entity;
	public var emitter:ParticleController;
	//***** /TEMPORARY ******

	var menu:Menu;
	var uiStates:StateMachine<UIState>;
	public static var instance(get_instance, set_instance):PlayScene;
	public static var TILE_SIZE:Int = 32;
	public static var HTILE_SIZE:Int = cast (TILE_SIZE/2);
	// how many seconds per AI processing step
	public static var AI_RATE:Float = 0.5;
	public static var AGENT_RATE:Float = 0.2;
	public static var SERVER_RATE:Float = 0.1;
	public static var BACKGROUND_AUTO_SCROLL:Bool = false;

	public var cameraSpeed:Float = 4;

	public static var server:Server;

	// [@note this apparently ain't working - come back to it]
	// private var lobby(default, never):Lobby;
	// public function get_lobby():Lobby { return server.lobby; }	
	// public var lobby(default, never):Lobby;
	public var lobby:Lobby;
	public var world:World;
	public var level:Level;

	public function new() {
		super();
		instance = this;
		menu = new Menu("ingame", menuEvent, uiEvent, cast(HXP.screen.width / 2), cast(HXP.screen.height / 2));

		setupKeyBindings();
		server = new Server();
		server.addPlayer(new ComputerPlayer());

		// [@note this should be made redundant by property getter, but it or I am being weird]
		lobby = server.lobby;
		level = server.world.level;
		world = server.world;


		loadAgentTemplates();

		selectedEntities = new Array<Entity>();

		createUIStates();
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
		// if (w < MIN_RECT_SIZE && h < MIN_RECT_SIZE) {
		// 	// this rectangle is considered a click, so we'll just choose an entity and bring it to the "back"
		// 	var ent:Entity = collideRect("computer", x, y, w, h);
		// 	if (ent == null) return;

		// 	sendToBack(ent);
		// 	bringForward(ent);
		// 	selectedEntities.push(ent);
		// } else {
			collideRectInto("human", x, y, w, h, selectedEntities);
		// }
	}

	public override function begin() {
		super.begin();

		Assets.sfxGameMusic.loop(0.7);

		emitter = new ParticleController();
		add(emitter);			

		uiStates.enter();
		HXP.log("entering game");

		var bgScroller = new Backdrop("gfx/gridbg.png", true, true);
		bgScroller.scrollX = 0.2;
		bgScroller.scrollY = 0.2;
		background = new Entity(0, 0, bgScroller);
		background.layer = 1000;
		add(background);

		world.loadCurrentLevel();

		var totalPerSide:Int = cast(Math.sqrt(level.mapWidth * level.mapHeight) / 2);
		for (j in 0...2) {
			var teamName:String = "human";
			if (j == 1) {
				teamName = "computer";
			}
			for (i in 0...totalPerSide) {
				var select:Int = cast(Math.random()*3);
				var newX:Int = cast(HXP.clamp(Math.random()*level.mapWidth, 1, level.mapWidth-2));
				var newY:Int = cast(HXP.clamp(Math.random()*level.mapHeight, 1, level.mapHeight-2));
				switch (select) {
					case 0:
						testEntity = AgentFactory.create("basic", teamName, newX, newY) ;			
					case 1:
						testEntity = AgentFactory.create("scout", teamName, newX, newY);
					case 2:
						testEntity = AgentFactory.create("heavy", teamName, newX, newY);
				}
				add(testEntity);			
			}
		}

		// var uiGfx:Stamp = new Stamp("gfx/ui_mockup.png");
		// uiGfx.scrollX = uiGfx.scrollY = 0;
		// uiOverlay = new Entity(0, HXP.screen.height - uiGfx.height, uiGfx);
		// uiOverlay.layer = 2;
		// add(uiOverlay);

		agentInfoText = new Text("AgentType\nstr:24\ndex:24", 0, 0, {color:0x005500});
		agentInfoText.scrollX = agentInfoText.scrollY = 0;
		var agentInfoEntity:Entity = new Entity(440, 325, agentInfoText);
		agentInfoEntity.layer = 1;				
		add(agentInfoEntity);

		// createMap();

		// Keep this for last
		HXP.alarm(SERVER_RATE, serverTick, TweenType.Looping, this);
		// HXP.alarm(AI_RATE, doAiMove, TweenType.Looping, this);	
		// HXP.alarm(AGENT_RATE, doAgentMove, TweenType.Looping, this);	
	}

	public override function end() {
		Assets.sfxGameMusic.stop();
	}

	public function serverTick(event:Dynamic) {
		if (menu.isActive) {
			return;
		}

		server.update();
	}

	public function doAiMove(event:Dynamic) {
		if (menu.isActive) {
			return;
		}
		// HXP.log("Ai update");
		// if (testEntity.tween != null && !testEntity.tween.active) {
		// 	var newX:Int = level.toMapX(testEntity.x) + cast((Math.random()-0.5) * 2);
		// 	var newY:Int = level.toMapY(testEntity.y) + cast((Math.random()-0.5) * 2);
		// 	testEntity.setTarget(newX, newY);
		// }
	}

	public function doAgentMove(event:Dynamic) {

	}

	public function tweenComplete(event:Dynamic) {
		HXP.log("Tween complete");
	}

	public override function update() {
		// mouse scrolling scale breaks too much
		// HXP.screen.scale = HXP.clamp(HXP.screen.scale + Input.mouseWheelDelta * 0.02, 0.5, 2);
			
		super.update();
		if (!menu.isActive && BACKGROUND_AUTO_SCROLL) {
			background.x += 0.1;
			background.y += 0.05;
		}
		if (Input.pressed(Key.M)) {
			uiStates.pushState("orderMove");
		} 
		if (Input.pressed(Key.B)) {
			for ( entity in selectedEntities ) {
				server.sendLocalOrder("breed", 0, 0, cast(entity, Actor).agent);
			}			
		}
		if (Input.pressed(Key.A)) {
			uiStates.pushState("orderAttack");
		}
		if (Input.pressed(Key.H) && selectedEntities.length > 0) {
			// [@remove hurt selected]
			var actor:Actor = cast(selectedEntities[0], Actor);
			var agent:Agent = actor.agent;
			// agent.hitPoints -= 1;
			emitter.greenHurt(actor.x, actor.y);
			server.hurtAgent(1, null, agent);
		}
		if (Input.pressed(Key.N)) {
			server.world.nextLevel();
		}
		if (uiStates.getCurrent() == null) {
			uiStates.pushState("select");
		}
		uiStates.update();
		// a little special case code for in-game menu since it acts differently
		updateMenu();

		if (!menu.isActive) {
			updateCamera();
		}
	}

	public override function render() {
		super.render();
		uiStates.render();
	
		if ( selectedEntities.length == 0) {
			agentInfoText.text = "";
		} else {
			var agent:Agent = cast(selectedEntities[0], Actor).agent;
			agentInfoText.text = agent.config.parent.typeName + "\nstr:" + agent.config.get("str") + "\ndex:" + agent.config.get("dex");
			var hp:Float = agent.hitPoints / cast(agent.config.get("vit"), Float);
			Draw.rect(cast(HXP.camera.x + 440), cast(HXP.camera.y+380), 40, 10, 0xff0000, 0.8);
			Draw.rect(cast(HXP.camera.x + 440), cast(HXP.camera.y+380), cast(40 * hp), 10, 0x00ff00, 0.9);
		}

		for ( entity in selectedEntities) {
			// Draw.hitbox(entity, true, 0x00ff00, 0.5);
			Draw.circlePlus(cast entity.x+HTILE_SIZE, cast entity.y+HTILE_SIZE, TILE_SIZE+2, 0x00FF00, 0.5, false, 2);
		}
		menu.render();
	}

	public function loadAgentTemplates() {
		AgentFactory.load( Utils.loadJson("actors") );
	}


	public function setupKeyBindings() {
		Input.define("up", [Key.UP]);
		Input.define("down", [Key.DOWN]);		
		Input.define("left", [Key.LEFT]);
		Input.define("right", [Key.RIGHT]);				
	}

	public function updateCamera() {
		var moveX:Float = 0;
		var moveY:Float = 0;

		if (Input.check("up")) {
			moveY -= 1;
		} 
		if (Input.check("down")) {
			moveY += 1;
		}
		if (Input.check("left")) {
			moveX -= 1;
		}
		if (Input.check("right")) {
			moveX += 1;
		}
		var speed:Float = cameraSpeed;
		if (Input.check(Key.SHIFT)) {
			speed *= 3;
		}
		camera.offset(moveX * speed, moveY * speed);
	}
	public function updateMenu() {
		if (Input.pressed(Key.ESCAPE)) {
			if (menu.isActive) {
				menu.exit();
			} else {
				// HXP.screen.addFilter([new BlurFilter(3, 3)]);
				// HXP.screen.addFilter([]);

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

	public function createUIStates() {
		uiStates = new StateMachine<UIState>("ui");

		var testState:UIState = new UIState("select");
		testState.setOverride(CustomUpdate, function (owner:PrototypeState) {
			// HXP.log("updating select");
			if (Input.mousePressed) {
				startDragPoint = new Point(mouseX, mouseY);
				if (!Input.check(Key.SHIFT)) {
					selectedEntities = new Array<Entity>();
				}
			} else if (Input.mouseReleased) {
				if (startDragPoint == null) return;

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
					var actor:Actor = cast entity;
					// HXP.log("ordered movement of " + entity + " to " + mouseX + ", " + mouseY);
					server.sendLocalOrder("move", actor.toMapX(mouseX), actor.toMapY(mouseY), actor.agent);
					// cast(entity, Actor).setTarget( level.toMapX(mouseX), level.toMapY(mouseY));

				}
			}
		});
		uiStates.addState(testState);	


		testState = new UIState("orderAttack");
		testState.setOverride(CustomUpdate, function (owner:PrototypeState) {
			if (Input.mouseReleased) {
				
				owner.isDone = true;
				// HXP.log("Attempting to order " + selectedEntities.length + " entities");
				for (entity in selectedEntities) {
					var actor:Actor = cast entity;
					// HXP.log("ordered movement of " + entity + " to " + mouseX + ", " + mouseY);
					server.sendLocalOrder("attack", actor.toMapX(mouseX), actor.toMapY(mouseY), actor.agent);
					// cast(entity, Actor).setTarget( level.toMapX(mouseX), level.toMapY(mouseY));

				}
			}
		});
		uiStates.addState(testState);
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