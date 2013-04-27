package ui;

import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.HXP;
import nme.geom.Point;

typedef UICallback = String->UIEntity->Void;

/**
 * ...
 * @author keili
 */
class UIEntity extends Entity {
	public var uiName:String;
	var handler:String->UIEntity->Void;
	var hasMouse:Bool = false;
	var key:Dynamic;

	public function new (uiName:String, x:Float=0, y:Float=0, ?handler:UICallback = null) {
		super(x, y);
		this.uiName = uiName;		
		this.handler = handler;		
	}		

	public override function update() {
		super.update();
		var relX = scene.mouseX - x;
		var relY = scene.mouseY - y;

		if (collidePoint(x, y, Input.mouseX, Input.mouseY)) {
			if (!hasMouse) {
				hasMouse = true;
				onGotMouse(relX, relY);
			}
			if (Input.mouseReleased) {
				onClick(relX, relY);
			}
		} else {
			if (hasMouse) {
				hasMouse = false;			
				onLostMouse(relX, relY);
			}
		}
		if (key != null && Input.pressed(key)) {
			onClick(0, 0);
		}
	}

	public function lockToCamera() {
		if (graphic != null) {
			graphic.scrollX = graphic.scrollY = 0;
		}
	}
	
	public  function onClick(relX:Float, relY:Float) {
		HXP.log("clicked " + uiName);	
		if (handler != null) {
			handler("onClick", this);
		}
	}

	public  function onGotMouse(relX:Float, relY:Float) {
		HXP.log("got mouse " + uiName);	

		if (handler != null) {
			handler("onGotMouse", this);
		}
	}

	public  function onLostMouse(relX:Float, relY:Float) {
		HXP.log("lost mouse " + uiName);	
		if (handler != null) {
			handler("onLostMouse", this);
		}		
	}

	public function bind(key:Dynamic) {
		this.key = key;
	}

}
