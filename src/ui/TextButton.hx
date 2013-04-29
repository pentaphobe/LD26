
package ui;

import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.Graphic;
import nme.text.TextFormatAlign;


class TextButton extends UIEntity {
	var text:Text;
	var shadowText:Text;
	public var normalColor:Int = 0xc0c0c0;
	public var hoverColor:Int = 0xffffff;
	public var bgNormalColor:Int = 0x000000;
	public var bgHoverColor:Int = 0x200000;
	public var boxPadding:Int = 2;
	public var background:Graphic;
	public var fullWidthBackground:Bool;
	public function new(label:String, uiName:String, x:Float=0, y:Float=0, ?handler:String->UIEntity->Void = null, ?hasShadow:Bool=true, ?hasBackground:Bool = true, ?fullWidthBackground:Bool = false) {
		super(uiName, x, y, handler);
		this.fullWidthBackground = fullWidthBackground;
		background = null;
		if (hasShadow) {
			shadowText = new Text(label, -2, 2, {color:bgNormalColor,align:TextFormatAlign.LEFT});	
			// shadowText.scrollX = shadowText.scrollY = 0;
		}
		this.text = new Text(label, 0, 0, {color:normalColor,align:TextFormatAlign.LEFT});
		this.text.scrollX = this.text.scrollY = 0;

		if (hasBackground) {
			createBackground(bgNormalColor);
			// background.scrollX = background.scrollY = 0;
		}

		var gList:Graphiclist = new Graphiclist();
		graphic = gList;
		gList.scrollX = gList.scrollY = 0;
		if (hasBackground) {
			gList.add(background);
		}
		if (hasShadow) {
			gList.add(this.shadowText);		
		}
		gList.add(this.text);
		// if (hasBackground) {
		// 	setHitbox(cast background.width, cast background.heigh, cast background.x, cast background.y);
		// }
		setHitbox(text.width, text.height, cast text.originX, cast text.originY);

		// [@note not sure why this is necessary - I'm setting the color above, but somewhere the items are initialising to hover state]
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

	public function createBackground(col:Int) {
		if (fullWidthBackground) {
			var fullWidth:Int = HXP.screen.width - boxPadding*2;
			background = Image.createRect(fullWidth, text.height + boxPadding*2, col);
			background.x = -(fullWidth/2);
		} else {
			background = Image.createRect(text.width + boxPadding*2, text.height + boxPadding*2, col);
			background.x -= boxPadding;
			background.y -= boxPadding;
		}	

	}
}