
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
import nme.text.TextFormatAlign;
import utils.ActorTemplate;
import scenes.PlayScene;

class MapPoint {
	public var x:Int;
	public var y:Int;
	public function new(?x:Int=0, ?y:Int=0) {
		this.x = x;
		this.y = y;
	}
}

class Actor extends Entity {
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
		mapPos = new MapPoint( PlayScene.instance.level.toMapX(x), PlayScene.instance.level.toMapY(y) );
		if (teamName == "human") {
			col = 0x00ff00;
		} else {
			col = 0xff0000;
		}
		this.teamName = teamName;

		var gList:Graphiclist = new Graphiclist();
		graphic = gList;

		var img:Graphic = Image.createRect(PlayScene.TILE_SIZE, PlayScene.TILE_SIZE, col);
		setHitboxTo(img);		
		gList.add(img);

		label = new Text(teamName, -(PlayScene.TILE_SIZE/4), -PlayScene.TILE_SIZE, {color:col, align:TextFormatAlign.CENTER});
		label.size = 10;
		gList.add(label);

		centerOrigin();
		graphic.x = -PlayScene.HTILE_SIZE;
		graphic.y = -PlayScene.HTILE_SIZE;
		type = teamName;	

		
	}

	public function setTarget(x:Int, y:Int) {
		targetPos = new MapPoint(x, y);
		if (tween == null) {
			tween = new LinearMotion(null, TweenType.Persist);
			addTween(tween);
			HXP.log("created new tweener");
		}
		tween.setMotionSpeed(this.x, this.y, PlayScene.instance.level.toScreenX(x), PlayScene.instance.level.toScreenY(y), config.get("spd") * PlayScene.TILE_SIZE);
		tween.start();

	}

	public override function update() {
		super.update();
		if (tween != null && tween.active) {
			if (collideTypes(["computer", "human"], tween.x, tween.y) == null) {
				x = tween.x;
				y = tween.y;
			} else {
				// var dx = tween.x - x;
				// var dy = tween.y - y;
				// x += dy * 0.1;
				// y += dx * 0.1;
				tween.active = false;
				HXP.alarm(0.1, function (event:Dynamic) {
					setTarget(targetPos.x, targetPos.y);
				}, TweenType.OneShot);
				// tween.active = false;
			}
		}
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
	// public function applyTemplate(tpl:ActorTemplate) {
		
	// }
}