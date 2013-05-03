
package ui;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Stamp;
import ui.UIEntity;
import ui.TextButton;
import ui.UIDialog;
import ui.HorizontalDialog;
import ui.VerticalDialog;

class LevelEndDialog extends VerticalDialog {
	var uiCallback:UICallback;
	public function new(?x:Float=0, ?y:Float=0, ?uiCallback:UICallback) {
		super(x, y, 280, 150);
		this.uiCallback = uiCallback;
		layer = 4;
	}

	public override function added() {
		add(new Entity(0, 0, new Stamp("gfx/win_text.png") ));
		add(new TextButton("You beat the level!", "hello", 40, 48, null, true, false)).active = false;
		add(new TextButton("score:" + 240249, "hello", 0, 0, null, true, false)).active = false;
		var horz:HorizontalDialog = new HorizontalDialog(0, 0, 280, 41);
		add(horz);

		horz.padding += 2;
		horz.add(new TextButton("continue", "continue", 0, 0, dialogCallback));
		horz.add(new TextButton("retry", "retry", 0, 0, dialogCallback));
		horz.add(new TextButton("exit", "exit", 0, 0, dialogCallback));		
		
		super.added();
	}

	public override function add(e:Entity):Entity {
		if (Std.is(e, UIEntity)) {
			cast(e, UIEntity).handler = this.uiCallback;
		}
		return super.add(e);
	}

	public function dialogCallback(type:String, widget:UIEntity):Void {
		if (uiCallback != null) {
			uiCallback(type, widget);
		}		
	}
}