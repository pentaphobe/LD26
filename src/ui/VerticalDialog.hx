
package ui;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import ui.UIDialog;

class VerticalDialog extends UIDialog {

	var yPos:Float = 0;

	public override function add(ent:Entity) {

		var hei:Int = ent.height;
		if (hei == 0) {
			if (Reflect.hasField(ent.graphic, "height")) {
				hei = Reflect.field(ent.graphic, "height");
				ent.height = hei;
			}
		}
		var wid:Int = ent.height;
		if (wid == 0) {
			if (Reflect.hasField(ent.graphic, "width")) {
				wid = Reflect.field(ent.graphic, "width");
				ent.width = wid;
			}
		}

		var shiftAmount = hei + padding / 2 + ent.y;
		ent.y += yPos;
		yPos += shiftAmount;		
		return super.add(ent);
	}	

}