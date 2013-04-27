
package entities;

import com.haxepunk.Entity;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Graphiclist;
import nme.text.TextFormatAlign;
import utils.ActorTemplate;
import scenes.PlayScene;

class Actor extends Entity {
	public var teamName:String;
	public var label:Text;
	public var config:ActorTemplate;
	public var hitPoints:Float;
	public var movementPoints:Float;
	public var actionPoints:Float;
	public function new(teamName:String, x:Float, y:Float) {
		super(x, y);
		var col:Int;
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