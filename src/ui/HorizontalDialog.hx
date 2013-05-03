
package ui;
import com.haxepunk.Entity;
import ui.UIDialog;

class HorizontalDialog extends UIDialog {

	var xPos:Float = 0;

	public override function add(ent:Entity):Entity {
		ent.x = xPos;
		ent.y = 0;
		xPos += ent.width + padding/2;		
		return super.add(ent);
	}	

}