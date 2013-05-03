package scenes;

import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Tween;
import com.haxepunk.tweens.TweenEvent;
import com.haxepunk.utils.Draw;
import com.haxepunk.RenderMode;

import server.Server;
import server.ServerEventHandler;
import server.ServerEvent;
import ui.UIDialog;
import ui.UIEntity;
import ui.TextButton;

/** This class just intercepts events and dumps them out
 */
class TestHandler extends BasicServerEventHandler {
	public function new() {

	}
	public override function onEvent(event:ServerEvent):Bool {
		HXP.log("intercepted:" + event);

		// this isn't how you'd do this, just avoiding contamination
		HXP.log(" -- sending retaliation on their behalf..");
		event.dispatcher.send(event.type, event.target, event.source);

		return true;
	}
	public override function isPromiscuous():Bool {
		return true;
	}
}

class ServerTestScene extends Scene {
	var server:Server;
	var dialog:UIDialog;
	public function new() {
		super();
	}

	public override function begin() {
		// server = new Server();

		// server.addHandler(new TestHandler());

		// players aren't actors. stop confusing yourself :)
		// server.createPlayer("percival");
		// server.createPlayer("noggin");

		// no need to update at full speed, we just want to test
		// server interaction
		HXP.alarm(0.5, serverTick, TweenType.Looping);

		dialog = new UIDialog(50, 50, 400, 50);
		add(dialog);

		dialog.add(new TextButton("hello there", "hello_button", 10, 10, function (s:String, ent:UIEntity):Void {
			HXP.log(s);
			if (s == "onClick") {
				HXP.log("HELLO");
			}
		}));

		if (HXP.renderMode.has(RenderMode.HARDWARE)) {
			HXP.log("Hardware available");
		}
	}

	public override function update() {
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = new MenuScene();
		}
		if (Input.pressed(Key.SPACE)) {
			// server.sendLocalOrder("hedge-trimmer");
			// server.sendLocalOrder("well-formed", 23, 23);
		}
		if (Input.mouseDown) {
			var dx:Float = Input.mouseX - dialog.x;
			var dy:Float = Input.mouseY - dialog.y;
			dialog.setSize(dx, dy);
		}
	}

	public override function render() {
		// Draw.text("press space to fire an event", HXP.screen.width/2, HXP.screen.height/2);
		super.render();
	}

	public function serverTick(event:TweenEvent) {
		// server.update();
	}

	public override function end() {

	}
}