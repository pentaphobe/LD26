package scenes;

import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Tween;
import com.haxepunk.tweens.TweenEvent;

import server.Server;
import server.ServerEventHandler;
import server.ServerEvent;

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
	public function new() {
		super();
	}

	public override function begin() {
		server = new Server();

		server.addHandler(new TestHandler());

		// players aren't actors. stop confusing yourself :)
		server.createPlayer("percival");
		server.createPlayer("noggin");

		// no need to update at full speed, we just want to test
		// server interaction
		HXP.alarm(0.5, serverTick, TweenType.Looping);
	}

	public override function update() {
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = new MenuScene();
		}
	}

	public function serverTick(event:TweenEvent) {
		server.update();
	}

	public override function end() {

	}
}