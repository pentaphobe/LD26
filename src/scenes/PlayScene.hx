
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
import com.haxepunk.graphics.Graphiclist;
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
import server.Player;
import server.ComputerPlayer;
import entities.ParticleController;
import utils.MapPoint;
import server.TutorialController;

class PlayScene extends Scene {
	public static var renderSelectionInfo:Bool = false;
	public static var allowEdgeScrolling:Bool = true;

	//***** TEMPORARY *******
	var uiOverlay:Entity;
	var agentInfoText:Text;
	// var pauseMessage:BigTextEntity;
	var testEntity:Actor;
	var startDragPoint:Point;
	var selectedEntities:Array<Entity>;
	var background:Entity;
	public var emitter:ParticleController;
	public static var tutorialController:TutorialController;

	var startedVictoryDance:Bool = false;

	//***** /TEMPORARY ******

	public var menu:Menu;
	var uiStates:StateMachine<UIState>;
	public static var instance(get_instance, set_instance):PlayScene;
	public static var TILE_SIZE:Int = 32;
	public static var HTILE_SIZE:Int = cast (TILE_SIZE/2);
	// how many seconds per AI processing step
	public static var AI_RATE:Float = 0.5;
	public static var AGENT_RATE:Float = 0.2;
	public static var SERVER_RATE:Float = 0.1;
	public static var BACKGROUND_AUTO_SCROLL:Bool = false;

	public static var SCREEN_SCROLL_EDGE:Float = 20;

	public var cameraSpeed:Float = 4;
	public var cameraTarget:Point;
	public var cameraAutoTracking:Bool = true;

	public var gameIsPaused:Bool = false;

	public static var server:Server;

	// [@note this apparently ain't working - come back to it]
	public var lobby(get_lobby, never):Lobby;
	public function get_lobby():Lobby { return server.lobby; }	
	public var world(get_world, never):World;
	public function get_world():World { return server.world; }
	public var level(get_level, never):Level;
	public function get_level():Level { return server.world.level; }

	public function new(?levelSetName:String=null) {
		super();
		instance = this;
		cameraTarget = new Point(camera.x, camera.y);
		menu = new Menu("ingame", menuEvent, uiEvent, cast(HXP.screen.width / 2), cast(HXP.screen.height / 2));

		setupKeyBindings();
		server = new Server(levelSetName);
		tutorialController = new TutorialController();

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
		var hadSelection:Bool = selectedEntities.length > 0;

		collideRectInto("human", x, y, w, h, selectedEntities);

		if (selectedEntities.length > 0) {
			cameraAutoTracking = true;
			if (!hadSelection) {
				tutorialController.sendEvent("unitSelected");
			}
		} else if (hadSelection) {
			tutorialController.sendEvent("unitDeselected");
		}
	}

	public override function begin() {
		super.begin();

		Assets.sfxGameMusic.loop(0.7);

		emitter = new ParticleController();
		add(emitter);			

		var bgScroller = new Backdrop("gfx/gridbg.png", true, true);
		bgScroller.scrollX = 0.2;
		bgScroller.scrollY = 0.2;
		background = new Entity(0, 0, bgScroller);
		background.layer = 1000;
		add(background);

		HXP.log("entering game");

		setupLevel();

		if (renderSelectionInfo) {
			agentInfoText = new Text("AgentType\nstr:24\ndex:24", 0, 0, {color:0x005500});
			agentInfoText.scrollX = agentInfoText.scrollY = 0;
			var agentInfoEntity:Entity = new Entity(440, 325, agentInfoText);
			agentInfoEntity.layer = 1;				
			add(agentInfoEntity);
		}

		// Keep this for last
		HXP.alarm(SERVER_RATE, serverTick, TweenType.Looping, this);
		// HXP.alarm(AI_RATE, doAiMove, TweenType.Looping, this);	
		// HXP.alarm(AGENT_RATE, doAgentMove, TweenType.Looping, this);	
	}

	public override function end() {
		Assets.sfxGameMusic.stop();
	}

	public function setupLevel(?levelChangeDirection:Int=0) {
		/* clear the previous level */
		HXP.randomSeed = 31337;

		var oldArray:Array<Entity> = new Array<Entity>();
		getType("human", oldArray);
		getType("computer", oldArray);
		getType("gameMap",oldArray);		
		removeList(oldArray);		
		server.reset(levelChangeDirection);
		server.addPlayer(new ComputerPlayer());


		uiStates.enter();
		selectedEntities = new Array<Entity>();


		for ( team in Reflect.fields(level.jsonData.teams) ) {
			var data:Dynamic = Reflect.field(level.jsonData.teams, team);
			var topLeft:MapPoint = new MapPoint(data.start.x, data.start.y);
			var botRight:MapPoint = new MapPoint(data.start.x2, data.start.y2);

			var fixNegatives:MapPoint->Void = function (mp:MapPoint) {
				if (mp.x < 0) mp.x += level.mapWidth;
				if (mp.y < 0) mp.y += level.mapHeight;
			};
			fixNegatives(topLeft);
			fixNegatives(botRight);

			if (topLeft.x > botRight.x) {
				var tmp:Int = topLeft.x;
				topLeft.x = botRight.x;
				botRight.x = tmp;
			}
			if (topLeft.y > botRight.y) {
				var tmp:Int = topLeft.y;
				topLeft.y = botRight.y;
				botRight.y = tmp;
			}


			var failed:Bool = false;
			for ( agent in cast(data.agents, Array<Dynamic>) ) {
				for ( i in 0...agent.count ) {
					var xPos:Int=0;
					var yPos:Int=0;
					var maxIter = 20;
					do {
						xPos = cast( HXP.random * (botRight.x-topLeft.x) + topLeft.x );
						yPos = cast( HXP.random * (botRight.y-topLeft.y) + topLeft.y );
						if (--maxIter < 0) {
							failed = true;
							break;
						}
					} while (level.getAgent(xPos, yPos) != null);
					if (failed) break;

					var actor:Actor = AgentFactory.create( agent.type, team, xPos, yPos );
					add(actor);
				}
				if (failed) break;
			}
		}

		tutorialController.reset();
		if ( Reflect.hasField(level.jsonData, "tutorial") ) {
			tutorialController.loadSections(level.jsonData.tutorial);
		}

		centerOnPlayer("human");
	}

	public function centerOnPlayer(teamName:String) {
		var player:Player = server.getPlayer(teamName);
		if (player.agents.length == 0) return;

		var centroidX:Float = 0;
		var centroidY:Float = 0;

		for ( agent in player.agents) {
			centroidX += level.toScreenX(agent.pos.x);
			centroidY += level.toScreenY(agent.pos.y);
		}

		centroidX /= player.agents.length;
		centroidY /= player.agents.length;

		var mapCenterX:Float = level.toScreenX( cast(level.mapWidth / 2) );
		var mapCenterY:Float = level.toScreenY( cast(level.mapHeight / 2) );
		// if the centroid of the human agents is close to the center of the map
		// then center on the map instead
		var distFromCenterX:Float = mapCenterX - centroidX;
		var distFromCenterY:Float = mapCenterY - centroidY;
		if ( Math.abs(distFromCenterX) < HXP.screen.width / 2 && Math.abs(distFromCenterY) < HXP.screen.height / 2) {
			setCamera(mapCenterX, mapCenterY);
		} else {
			setCamera(centroidX, centroidY);
		}
				
	}

	public function serverTick(event:Dynamic) {
		if (menu.isActive || gameIsPaused) {
			return;
		}

		server.update();

		doLevelEnd();
	}

	// checks for and updates level ending
	public function doLevelEnd() {
		if (server.levelComplete && server.winner.name == "human") {
			for (i in 0...3) {
				emitter.redFinish(HXP.random*HXP.screen.width, HXP.random*HXP.screen.height, 10);
			}			
			if (!startedVictoryDance) {
				startedVictoryDance = true;
				var winBoxImage:Image = new Image("gfx/end_level_bg.png");
				winBoxImage.scrollX = 0;//.01;
				winBoxImage.scrollY = 0;//.01;
				winBoxImage.layer = 1;
				var winBoxText:Image = new Image("gfx/win_text.png");
				winBoxText.centerOrigin();
				winBoxText.x = (winBoxImage.width / 2);
				winBoxText.y = (winBoxImage.y + winBoxText.height/2);
				winBoxText.scrollX = 0;//.05;
				winBoxText.scrollY = 0;//.05;
				var gList:Graphiclist = new Graphiclist([winBoxImage, winBoxText]);

				var winBox:Entity = new Entity((HXP.screen.width-winBoxImage.width)/2, (HXP.screen.height-winBoxImage.height)/2, gList);
				// add(winTextEntity);
				add(winBox);
				Assets.sfxGameMusic.stop();
				Assets.sfxLevelWinMusic.play();
				HXP.alarm(6, function (_) {
					remove(winBox);
					Assets.sfxGameMusic.resume();
					Assets.sfxLevelWinMusic.stop();
					startedVictoryDance = false;
					HXP.log("loading!");
					setupLevel(1);
				});
			}
		}		
	}

	public override function update() {
		// mouse scrolling scale breaks too much
		// HXP.screen.scale = HXP.clamp(HXP.screen.scale + Input.mouseWheelDelta * 0.02, 0.5, 2);

		super.update();

		// a little special case code for in-game menu since it acts differently
		updateMenu();

		if (menu.isActive) return;
				

		if (BACKGROUND_AUTO_SCROLL) {
			background.x += 0.1;
			background.y += 0.05;
		}
		if (Input.pressed("move")) {
			uiStates.pushState("orderMove");
		} 
		if (Input.pressed("breed")) {
			for ( entity in selectedEntities ) {
				server.sendLocalOrder("breed", 0, 0, cast(entity, Actor).agent);
			}			
			if (!menu.isActive) {
				tutorialController.sendEvent("orderBreed");
			}

		}
		if (Input.pressed("attack")) {
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
		if (Input.pressed("next_level")) {
			setupLevel(1);
		} else if (Input.pressed("prev_level")) {
			setupLevel(-1);
		}
		if (Input.pressed("center_on_player")) {
			centerOnPlayer("human");
			cameraAutoTracking = true;
		}
		if (Input.pressed("center_on_enemy")) {
			centerOnPlayer("computer");
			// [@todo if we've opted to center on the computer, then continue to follow the computer]
			cameraAutoTracking = false;
		}
		if (Input.pressed("pause")) {
			gameIsPaused = !gameIsPaused;
			if (!menu.isActive) {
				tutorialController.sendEvent("hitSpacebar");
			}
		}
		if (uiStates.getCurrent() == null) {
			uiStates.pushState("select");
		}

		uiStates.update();

		updateCamera();
	}

	public override function render() {
		super.render();
		uiStates.render();
	
		if ( renderSelectionInfo ) {
			if ( selectedEntities.length == 0) {
				agentInfoText.text = "";
			} else {
				var agent:Agent = cast(selectedEntities[0], Actor).agent;
				agentInfoText.text = agent.config.parent.typeName + "\nstr:" + agent.config.get("str") + "\ndex:" + agent.config.get("dex");
				var hp:Float = agent.hitPoints / cast(agent.config.get("vit"), Float);
				Draw.rect(cast(HXP.camera.x + 440), cast(HXP.camera.y+380), 40, 10, 0xff0000, 0.8);
				Draw.rect(cast(HXP.camera.x + 440), cast(HXP.camera.y+380), cast(40 * hp), 10, 0x00ff00, 0.9);
			}
		}

		var centroidX:Float = 0;
		var centroidY:Float = 0;
		for ( entity in selectedEntities) {
			// selectedEntities is an array returned by HaxePunk, rather than rebuild the array every time a selected
			// entity dies, we're just skipping it here
			if (!cast(entity, Actor).agent.isAlive) {
				continue;
			}
			// Draw.hitbox(entity, true, 0x00ff00, 0.5);
			Draw.circlePlus(cast entity.x, cast entity.y, TILE_SIZE+2, 0x00FF00, 0.2, false, 2);
			centroidX += entity.x;
			centroidY += entity.y;
		}
		if (selectedEntities.length > 0) {
			centroidX /= selectedEntities.length;
			centroidY /= selectedEntities.length;

			// HXP.log("centroid:" + centroidX + ", " + centroidY);
			var aX:Float = centroidX - camera.x;			
			var aY:Float = centroidY - camera.y;
			// HXP.log("  absolut:" + aX + ", " + aY);
			if (aX < SCREEN_SCROLL_EDGE || aY < SCREEN_SCROLL_EDGE 
					|| aX > HXP.screen.width-SCREEN_SCROLL_EDGE
					|| aY > HXP.screen.height-SCREEN_SCROLL_EDGE) {
				Draw.circlePlus(cast centroidX, cast centroidY, 4, 0xFF00FF, 0.1, false, 2);
				setCameraTarget(centroidX, centroidY);
			}
		}

		var actors:Array<Actor> = new Array<Actor>();
		getClass(Actor, actors);
		// HXP.log("rendering overlays for " + actors.length + " actors");
		for (actor in actors) {
			actor.renderOverlay();
		}


		var sX:Int = cast camera.x;
		var sY:Int = cast camera.y;
		var txt:String = (world.currentLevel + 1) + " - " + level.title;
		var txtHeight:Int = 12;
		var txtWidth:Int = txt.length * 6;
		var boxHeight:Int = cast(HXP.screen.height/12);
		Draw.rectPlus(sX, sY, HXP.screen.width, boxHeight, 0x111111, 0.8, true);
		Draw.text(txt, sX + HXP.screen.width/2 - (txtWidth/2), sY+ txtHeight, {color:0x888888});			
		if (gameIsPaused) {
			var txt:String = "-- PAUSED --";
			var txtWidth:Int = txt.length * 6;
			var boxHeight:Int = cast(HXP.screen.height/6);			
			var sX:Int = cast camera.x;
			var sY:Int = cast (camera.y + HXP.screen.height);
			Draw.rectPlus(sX, sY - cast(boxHeight), HXP.screen.width, boxHeight, 0x111111, 0.8, true);
			Draw.text(txt, sX + HXP.screen.width/2 - (txtWidth/2), sY - boxHeight/2 - txtHeight, {color:0xffffff});			
		}

		var tutorialText:String = tutorialController.getCurrentText();
		if (!menu.isActive && tutorialText != "") {
			// HXP.log(tutorialController.receivedEvents);
			if (!gameIsPaused) {
				gameIsPaused = true;
			}
			var w:Int = cast(HXP.screen.width * 2 / 3);
			var h:Int = cast(HXP.screen.height/3);
			var x:Int = cast(HXP.screen.width - w);
			if (mouseX-camera.x >= x) { x = 0; }
			var y:Int = cast(HXP.screen.height - h - 60);
			if (mouseY-camera.y >= y) { y = 60; }
			drawTextRect(tutorialText, x, y , w, h, 0xdddddd, 0x331111);			
		}

		menu.render();
	}

	public static function drawTextRect(txt:String, x:Int, y:Int, w:Int, h:Int, textColor:Int=0x888888, boxColor:Int=0x111111) {
		// var txtWidth:Int = txt.length * 6;
		var txtHeight:Int = 12;
		var sX:Int = cast (HXP.camera.x + x);
		var sY:Int = cast (HXP.camera.y + y);
		Draw.rectPlus(sX, sY, w, h, boxColor, 0.8, true);
		Draw.text(txt, sX + 10, sY+ txtHeight + 20, {color:textColor});					
	}

	public function loadAgentTemplates() {
		AgentFactory.load( Utils.loadJson("actors") );
	}


	public function setupKeyBindings() {
		Input.define("up", [Key.UP]);
		Input.define("down", [Key.DOWN]);		
		Input.define("left", [Key.LEFT]);
		Input.define("right", [Key.RIGHT]);
		Input.define("menu_toggle", [Key.ESCAPE, Key.TAB]);
		Input.define("breed", [Key.B]);
		Input.define("attack", [Key.A]);
		Input.define("move", [Key.M]);
		Input.define("center_on_player", [Key.C]);
		Input.define("center_on_enemy", [Key.E]);
		Input.define("next_level", [Key.RIGHT_SQUARE_BRACKET]);				
		Input.define("prev_level", [Key.LEFT_SQUARE_BRACKET]);
		Input.define("pause", [Key.SPACE]);
	}

	// set camera position instantly (in screen coords)
	public function setCamera(x:Float, y:Float) {
		camera.setTo(x - (HXP.screen.width/2), y - (HXP.screen.height/2) );
		setCameraTarget(x, y);
	}

	// set the camera target
	public function setCameraTarget(x:Float, y:Float) {
		cameraTarget.setTo(x, y);
	}

	public function updateCamera() {
		var moveX:Float = 0;
		var moveY:Float = 0;

		if (Input.check("up")) {
			moveY -= 1;
			cameraAutoTracking = false;
		} 
		if (Input.check("down")) {
			moveY += 1;
			cameraAutoTracking = false;			
		}
		if (Input.check("left")) {
			moveX -= 1;
			cameraAutoTracking = false;			
		}
		if (Input.check("right")) {
			moveX += 1;
			cameraAutoTracking = false;			
		}

		// [@todo mouse edges don't work great in flash web]
		if (allowEdgeScrolling /* && HXP.focused*/) {		
			if (mouseX-camera.x < SCREEN_SCROLL_EDGE) { moveX -= 1; cameraAutoTracking = false;}
			if (mouseY-camera.y < SCREEN_SCROLL_EDGE) { moveY -= 1; cameraAutoTracking = false;}
			if (mouseX-camera.x > HXP.screen.width - SCREEN_SCROLL_EDGE) { moveX += 1; cameraAutoTracking = false;}
			if (mouseY-camera.y > HXP.screen.height - SCREEN_SCROLL_EDGE) { moveY += 1; cameraAutoTracking = false;}
		}
		var speed:Float = cameraSpeed;
		if (Input.check(Key.SHIFT)) {
			speed *= 3;
		}
		camera.offset(moveX * speed, moveY * speed);

		if (cameraAutoTracking) {
			var dX:Float = HXP.clamp( ((cameraTarget.x-HXP.screen.width/2) - camera.x ) * 0.25, -cameraSpeed, cameraSpeed);
			var dY:Float = HXP.clamp( ((cameraTarget.y-HXP.screen.height/2) - camera.y) * 0.25, -cameraSpeed, cameraSpeed);
			// camera goes the other direction
			// camera.x = centroidX - HXP.screen.width / 2;
			// camera.y = centroidY - HXP.screen.height / 2;
			// camera.x += dX;
			// camera.y += dY;		
			camera.offset(dX, dY);
		}
	}
	public function updateMenu() {
		if (Input.pressed("menu_toggle")) {
			if (menu.isActive) {
				menu.exit();
			} else {
				// HXP.screen.addFilter([new BlurFilter(3, 3)]);
				// HXP.screen.addFilter([]);

				menu.enter();
				Assets.sfxSuwip.play();
				menu.pushState("main");
				// menu.addAction("push", "main");
				// menu.enter();
			}			
		}				
		if (menu.isActive) {
			menu.update();
		} 		
	}

	public function menuEvent(action:String) {
		// HXP.log("menuEvent:" + action);
		if (action == "exit") {
			HXP.scene = new MenuScene();
		} else if (action == "restart") {
			setupLevel();
			menu.exit();
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
					tutorialController.sendEvent("orderMove");
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
					tutorialController.sendEvent("orderAttack");
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

	// public override function focusLost() {
	// 	HXP.log("Lost Focus");
	// 	cameraTarget.setTo( camera.x + HXP.screen.width/2, camera.y + HXP.screen.height/2);
	// }
	// public override function focusGained() {
	// 	HXP.log("Gained Focus");
	// 	cameraTarget.setTo( camera.x + HXP.screen.width/2, camera.y + HXP.screen.height/2);
	// }

}