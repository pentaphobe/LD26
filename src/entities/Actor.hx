
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
		setHitbox(cast image.width, cast image.height, cast image.x, cast image.y);		
		image.centerOO();
		gList.add(image);

		if (USE_LABEL) {
			label = new Text(teamName, -(PlayScene.TILE_SIZE/4), -PlayScene.TILE_SIZE, {color:teamColor, align:TextFormatAlign.CENTER});
			label.size = 10;
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

		// var dx:Float = toScreenX(targetPos.x) - x;
		// var dy:Float = toScreenY(targetPos.y) - y;
		// var tileSpeed = config.get("spd");
		// HXP.log("move speed:" + tileSpeed);
		// dx = HXP.clamp(dx, -tileSpeed, tileSpeed);
		// dy = HXP.clamp(dy, -tileSpeed, tileSpeed);
		// if ( Math.abs(dx) > Math.abs(dy) ) {
		// 	HXP.log("moving by " + dx + ", " + 0);
		// 	moveBy(dx, 0);
		// } else {
		// 	HXP.log("moving by " + 0 + ", " + dy);
		// 	moveBy(0, dy);
		// }
		setLabel(teamName + "\n" + agent.config.parent.typeName + "\n" + agent.state);					

		if (agent.state == AgentBreeding) {
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
		if (agent.state == AgentMoving) {
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
		if (agent.state == AgentAttacking) {
			Draw.linePlus(cast toScreenX(agent.pos.x) + PlayScene.HTILE_SIZE, 
								cast toScreenY(agent.pos.y) + PlayScene.HTILE_SIZE, 
								cast (toScreenX(agent.targetPos.x) + (Math.random()-0.5) * 2) + PlayScene.HTILE_SIZE,
								cast (toScreenY(agent.targetPos.y) + (Math.random()-0.5) * 2) + PlayScene.HTILE_SIZE, teamColor, 0.5, 1);
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