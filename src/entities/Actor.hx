
package entities;
import nme.geom.Point;
import nme.geom.Rectangle;

import com.haxepunk.Entity;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;


import com.haxepunk.Graphic;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.tweens.motion.LinearMotion;
import com.haxepunk.Tween;
import com.haxepunk.utils.Draw;

import nme.text.TextFormatAlign;
import utils.AgentTemplate;
import utils.MapPoint;

import scenes.PlayScene;
import server.Player;
import server.Agent;



class Actor extends Entity {
	public static var USE_LABEL:Bool = true;
	public static var HEALTHBAR_HEIGHT:Int = 5;

	public var teamName:String;
	public var teamColor:Int;
	public var label:Text;
	public var image:Image;
	public var agent:Agent;
	public var mapPos:MapPoint;
	public var tween:LinearMotion;
	public function new(teamName:String, x:Float, y:Float) {
		super(x, y);
		mapPos = new MapPoint( toMapX(x), toMapY(y) );

		var sprIdx:Int = 0;
		if (teamName == "human") {
			teamColor = 0x00ff00;
			sprIdx = 64;
		} else {
			teamColor = 0xff0000;
			sprIdx = 96;
		}
		this.teamName = teamName;

		var gList:Graphiclist = new Graphiclist();
		graphic = gList;

		var tmpPadding:Int = 0;
		var tmpPadding2:Int = tmpPadding * 2;
		// var img:Graphic = Image.createRect(PlayScene.TILE_SIZE - tmpPadding2, PlayScene.TILE_SIZE - tmpPadding2, teamColor);

		image = new Image("gfx/tiles.png", new Rectangle(sprIdx, 0, 32, 32));
		setHitbox(cast image.width, cast image.height, cast (image.width/2), cast (image.height/2));		
		image.centerOO();
		gList.add(image);

		if (USE_LABEL) {
			label = new Text(teamName, PlayScene.HTILE_SIZE + 8, -(PlayScene.TILE_SIZE), {color:teamColor});
			label.centerOO();			
			label.size = 8;
			gList.add(label);

		}

		// centerOrigin();
		graphic.x += PlayScene.HTILE_SIZE;
		graphic.y += PlayScene.HTILE_SIZE;


		graphic.x += tmpPadding;
		graphic.y += tmpPadding;

		type = teamName;	

	}

	public override function update() {
		if (PlayScene.instance.gameIsPaused || PlayScene.instance.menu.isActive) {
			return;
		}
		super.update();
		if (!agent.isAlive) {
			var ps:PlayScene = cast HXP.scene;
			if (teamName == "human") {
				ps.emitter.greenExplode(x, y);
			} else {
				ps.emitter.redExplode(x, y);
			}
			Assets.sfxExplosion.play(0.05);
			HXP.scene.remove(this);
		}

		if (agent.wasHit) {
			var ps:PlayScene = cast HXP.scene;
			if (teamName == "human") {
				ps.emitter.greenHurt(x, y);
			} else {
				ps.emitter.redHurt(x, y);
			}
			Assets.sfxClick.play(0.05);		
			agent.wasHit = false;	
		}

		// [@todo here is where we check with Agent path]		
		// // no target to move towards (or we've arrived)
		// if (!getNextPathNode()) {
		// 	return;
		// }

		var dx:Float = (toScreenX(agent.pos.x) - x + PlayScene.HTILE_SIZE);
		var dy:Float = (toScreenY(agent.pos.y) - y + PlayScene.HTILE_SIZE);
		var spd:Float = agent.config.get("spd") * 4;
		dx = HXP.clamp(dx, -spd, spd);
		dy = HXP.clamp(dy, -spd, spd);
		x += dx;
		y += dy;


		setLabel(agent.config.parent.typeName + "\n" + agent.state);					

		if (agent.state == Breeding) {
			// one full rotation per breeding cycle
			var angleChange:Float = 360 / (Agent.TICKS_TO_BREED / PlayScene.SERVER_RATE);
			image.angle+=angleChange;
		} else {
			image.angle = 0;
		}		
	}

	// [@remove debug rendering]
	public override function render() {
		super.render();
	}

	public function renderOverlay() {
		if (agent.state == Moving) {
			var pos:MapPoint = null;
			for ( pos2 in agent.path ) {
				if (pos == null) {
					pos = new MapPoint(pos2.x, pos2.y);
					continue;
				}

				Draw.linePlus(cast toScreenX(pos.x) + PlayScene.HTILE_SIZE, 
								cast toScreenY(pos.y) + PlayScene.HTILE_SIZE, 
								cast toScreenX(pos2.x) + PlayScene.HTILE_SIZE, 
								cast toScreenY(pos2.y) + PlayScene.HTILE_SIZE, teamColor, 0.5, 2);
				
				pos.set(pos2.x, pos2.y);
			}
		} 
		if (agent.state == Attacking) {
			Draw.linePlus(cast toScreenX(agent.pos.x) + PlayScene.HTILE_SIZE, 
								cast toScreenY(agent.pos.y) + PlayScene.HTILE_SIZE, 
								cast (toScreenX(agent.targetPos.x) + (HXP.random-0.5) * 8) + PlayScene.HTILE_SIZE,
								cast (toScreenY(agent.targetPos.y) + (HXP.random-0.5) * 8) + PlayScene.HTILE_SIZE, teamColor, 0.5, 2);
		}

		// health bar
		var hp:Float = agent.hitPoints / cast(agent.config.get("vit"), Float);
		if (hp < 1) {
			Draw.rect(cast(x - PlayScene.HTILE_SIZE), cast(y - PlayScene.HTILE_SIZE), PlayScene.TILE_SIZE, HEALTHBAR_HEIGHT, 0xff0000, 0.5);
			Draw.rect(cast(x - PlayScene.HTILE_SIZE), cast(y - PlayScene.HTILE_SIZE), cast(PlayScene.TILE_SIZE * hp), HEALTHBAR_HEIGHT, 0x00ff00, 0.9);
		}		
	}

	public function setLabel(str:String) {
		if (USE_LABEL) {
			label.text = str;
		}
	}

	// public function onArrived() {
	// 	moveTo(toScreenX(targetPos.x), toScreenY(targetPos.y));
	// 	targetPos = null;
	// 	HXP.log("Arrived!");
	// }

	public function toScreenX(mapX:Int):Float {
		return PlayScene.instance.level.toScreenX(mapX);
	}
	public function toScreenY(mapY:Int):Float {
		return PlayScene.instance.level.toScreenY(mapY);
	} 

	public function toMapX(scrX:Float):Int {
		return PlayScene.instance.level.toMapX(scrX);
	}
	public function toMapY(scrY:Float):Int {
		return PlayScene.instance.level.toMapY(scrY);	
	} 	
	// public function applyTemplate(tpl:AgentTemplate) {
		
	// }
}