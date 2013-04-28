package scenes;

import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Tween;
import com.haxepunk.tweens.TweenEvent;

import server.Server;
import server.ServerEvent;


class ServerTestScene extends Scene {
	var server:Server;
	public function new() {
		super();
	}

	public override function begin() {
		server = new Server();

		server.createPlayer("percival");
		server.createPlayer("noggin");

		server.sendByName(WasHit, "percival", "noggin");

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