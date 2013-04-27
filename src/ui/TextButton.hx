
package ui;

import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Text;
import nme.text.TextFormatAlign;


class TextButton extends UIEntity {
	var text:Text;
	public var normalColor:Int = 0x808080;
	public var hoverColor:Int = 0xffffff;
	public function new(label:String, uiName:String, x:Float=0, y:Float=0, ?handler:String->UIEntity->Void = null) {
		super(uiName, x, y, handler);
		this.text = new Text(label, 0, 0, {color:normalColor,align:TextFormatAlign.LEFT});

		addGraphic(this.text);
		setHitboxTo(this.text);
		// [@note not sure why this is necessary - I'm setting the color above]
		onLostMouse(0, 0);
	}

	public override function render() {
		super.render();
	}

	public override function onGotMouse(relX:Float, relY:Float) {
		text.color = hoverColor;
		super.onGotMouse(relX, relY);
	}

	public override function onLostMouse(relX:Float, relY:Float) {
		text.color = normalColor;
		super.onLostMouse(relX, relY);
	}

}