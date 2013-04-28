
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
import utils.ActorTemplate;
import scenes.PlayScene;

class MapPoint {
	public var x:Int;
	public var y:Int;
	public function new(?x:Int=0, ?y:Int=0) {
		set(x, y);
	}
	public function set(?x:Int=0, ?y:Int=0) {
		this.x = x;
		this.y = y;
	}

	public function equals(other:MapPoint):Bool {
		return other.x == x && other.y == y;
	}

	public function toString():String {
		return "{ " + this.x + ", " + this.y + " }";
	}
}

class Actor extends Entity {
	/** TEMPORARY **/
	public var path:List<MapPoint>;
	/** /TEMPORARY **/

	public var teamName:String;
	public var label:Text;
	public var config:ActorTemplate;
	public var hitPoints:Float;
	public var movementPoints:Float;
	public var actionPoints:Float;
	public var targetPos:MapPoint;
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

		var img:Graphic = Image.createRect(PlayScene.TILE_SIZE - 2, PlayScene.TILE_SIZE - 2, col);
		setHitboxTo(img);		
		gList.add(img);

		label = new Text(teamName, -(PlayScene.TILE_SIZE/4), -PlayScene.TILE_SIZE, {color:col, align:TextFormatAlign.CENTER});
		label.size = 10;
		gList.add(label);

		// centerOrigin();
		// graphic.x = -PlayScene.HTILE_SIZE+1;
		// graphic.y = -PlayScene.HTILE_SIZE+1;
		type = teamName;	

		targetPos = new MapPoint();
		mapPos = new MapPoint();
		path = new List<MapPoint>();
	}

	public function setTarget(x:Int, y:Int) {
		targetPos = new MapPoint(x, y);
		// if (tween == null) {
		// 	tween = new LinearMotion(null, TweenType.Persist);
		// 	addTween(tween);
		// 	HXP.log("created new tweener");
		// }
		// tween.setMotionSpeed(this.x, this.y, toScreenX(x), toScreenY(y), config.get("spd") * PlayScene.TILE_SIZE);
		// tween.start();

		// temporarily force tile-based movement
		buildPath();		
	}

	public function buildPath() {
		path.clear();
		var tmp:MapPoint = new MapPoint(mapPos.x, mapPos.y);
		HXP.log("building path from " + mapPos + " to " + targetPos);

		var maxIter:Int = 10;
		do {
			var dx:Int = targetPos.x - tmp.x;
			var dy:Int = targetPos.y - tmp.y;

			if ( Math.abs(dx) > Math.abs(dy) ) {
				tmp.x += cast HXP.clamp(dx, -1, 1);
			} else {
				tmp.y += cast HXP.clamp(dy, -1, 1);
			}
			var node:MapPoint = new MapPoint(tmp.x, tmp.y);
			HXP.log(" -- " + node);
			path.add( node );
		} while (--maxIter > 0 && !tmp.equals(targetPos));
		HXP.log("path has " + path.length + " entries");
	}

	public function getNextPathNode():Bool {
		var oldPos = new MapPoint(mapPos.x, mapPos.y);
		mapPos.set( toMapX(x), toMapY(y) );		
		if (!oldPos.equals(mapPos)) {
			HXP.log("abandoning " + oldPos);
			PlayScene.instance.level.setActor(oldPos.x, oldPos.y, null);	
			if (PlayScene.instance.level.getActor(mapPos.x, mapPos.y) != null) {
				HXP.log("occupado");
				path.clear();
				return false;
			}	
			HXP.log("moving into " + mapPos);
			PlayScene.instance.level.setActor(mapPos.x, mapPos.y, this);		
		}
		if (path == null) return false;
		if (path.length == 0) {
			return false;
		}
		var next:MapPoint = path.first();
		if (next.equals(mapPos)) {
			path.pop();
			if (path.length == 0) {
				onArrived();
				return false;
			}
			next = path.first();
		}
		targetPos.set(next.x, next.y);
		return true;
	}

	public override function update() {
		super.update();
		
		// no target to move towards (or we've arrived)
		if (!getNextPathNode()) {
			return;
		}

		var dx:Float = toScreenX(targetPos.x) - x;
		var dy:Float = toScreenY(targetPos.y) - y;
		var tileSpeed = config.get("spd");
		HXP.log("move speed:" + tileSpeed);
		dx = HXP.clamp(dx, -tileSpeed, tileSpeed);
		dy = HXP.clamp(dy, -tileSpeed, tileSpeed);
		if ( Math.abs(dx) > Math.abs(dy) ) {
			HXP.log("moving by " + dx + ", " + 0);
			moveBy(dx, 0);
		} else {
			HXP.log("moving by " + 0 + ", " + dy);
			moveBy(0, dy);
		}
		// if (tween != null && tween.active) {
		// 	if (collideTypes(["computer", "human"], tween.x, tween.y) == null) {
		// 		x = tween.x;
		// 		y = tween.y;
		// 	} else {
		// 		// var dx = tween.x - x;
		// 		// var dy = tween.y - y;
		// 		// x += dy * 0.1;
		// 		// y += dx * 0.1;
		// 		tween.active = false;
		// 		HXP.alarm(0.1, function (event:Dynamic) {
		// 			setTarget(targetPos.x, targetPos.y);
		// 		}, TweenType.OneShot);
		// 		// tween.active = false;
		// 	}
		// }
	}

	public override function render() {
		super.render();
		var pos:MapPoint = null;
		for ( pos2 in path ) {
			if (pos == null) {
				pos = new MapPoint(pos2.x, pos2.y);
				continue;
			}

			Draw.linePlus(pos.x, pos.y, pos2.x, pos2.y, 0xff0000, 0.5, 2);
			
			pos.set(pos2.x, pos2.y);
		}
	}

	public function onArrived() {
		moveTo(toScreenX(targetPos.x), toScreenY(targetPos.y));
		targetPos = null;
		HXP.log("Arrived!");
	}

	public function heal(?amount:Float=0, ?allowOverHeal:Bool=false) {
		if (amount == 0) {
			// heal all the way
			hitPoints = config.get("vit");
		} else {
			hitPoints += amount;
			if (hitPoints > config.get("vit") && !allowOverHeal) {
				hitPoints = config.get("vit");
			}
		}
	}

	public function reset() {
		heal();
		movementPoints = config.get("spd");
		actionPoints = config.get("dex");
	}

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
	// public function applyTemplate(tpl:ActorTemplate) {
		
	// }
}