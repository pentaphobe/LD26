
package entities;
import nme.geom.Point;

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
	public static var USE_LABEL:Bool = false;

	public var teamName:String;
	public var label:Text;
	public var agent:Agent;
	public var mapPos:MapPoint;
	public var tween:LinearMotion;
	public function new(teamName:String, x:Float, y:Float) {
		super(x, y);
		var col:Int;
		mapPos = new MapPoint( toMapX(x), toMapY(y) );
		if (teamName == "human") {
			col = 0x00ff00;
		} else {
			col = 0xff0000;
		}
		this.teamName = teamName;

		var gList:Graphiclist = new Graphiclist();
		graphic = gList;

		var tmpPadding:Int = 4;
		var tmpPadding2:Int = tmpPadding * 2;
		var img:Graphic = Image.createRect(PlayScene.TILE_SIZE - tmpPadding2, PlayScene.TILE_SIZE - tmpPadding2, col);
		setHitboxTo(img);		
		gList.add(img);

		if (USE_LABEL) {
			label = new Text(teamName, -(PlayScene.TILE_SIZE/4), -PlayScene.TILE_SIZE, {color:col, align:TextFormatAlign.CENTER});
			label.size = 10;
			gList.add(label);
		}

		// centerOrigin();
		// graphic.x = -PlayScene.HTILE_SIZE+1;
		// graphic.y = -PlayScene.HTILE_SIZE+1;
		graphic.x += tmpPadding;
		graphic.y += tmpPadding;
		type = teamName;	

	}





	public override function update() {
		super.update();
		if (!agent.isAlive) {
			HXP.scene.remove(this);
		}

		// [@todo here is where we check with Agent path]		
		// // no target to move towards (or we've arrived)
		// if (!getNextPathNode()) {
		// 	return;
		// }
		x += (toScreenX(agent.pos.x) - x) * 0.25;
		y += (toScreenY(agent.pos.y) - y) * 0.25;

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
								cast toScreenY(pos2.y) + PlayScene.HTILE_SIZE, 0xff0000, 0.5, 2);
				
				pos.set(pos2.x, pos2.y);
			}
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