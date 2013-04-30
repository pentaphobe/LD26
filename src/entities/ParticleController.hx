package entities;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.utils.Ease;
import com.haxepunk.HXP;

import scenes.PlayScene;

class ParticleController extends Entity {
	public var emitter:Emitter;
	public function new() {
		super(0, 0);
	}
	public override function added() {
		emitter = new Emitter("gfx/particles.png", 32, 32);
		// if (emitter == null) {
		// 	HXP.log("NULL EMITTER");
		// 	return;
		// } else {
		// 	HXP.log("NON NULL!");
		// }
		// HXP.log("emitter is " + emitter);
		emitter.newType("green_explode", [0,1,2,3,4,5,6,7]);		
		emitter.setMotion("green_explode", 0, 100, 2, 360, -40, 1, Ease.quadOut);
		emitter.setAlpha("green_explode", 1, 0.1);

		emitter.newType("red_explode", [8,9,10,11,12,13]);		
		emitter.setMotion("red_explode", 0, 100, 0.5, 360, -40, 1, Ease.quadOut);
		emitter.setAlpha("red_explode", 1, 0.1);


		emitter.newType("green_hurt", [5,6,7]);		
		emitter.setMotion("green_hurt", 0, 25, 2, 360, -40, 1, Ease.quadOut);
		emitter.setAlpha("green_hurt", 1, 0.1);

		emitter.newType("red_hurt", [11,12,13]);		
		emitter.setMotion("red_hurt", 0, 25, 0.5, 360, -40, 1, Ease.quadOut);
		emitter.setAlpha("red_hurt", 1, 0.1);

		x = -PlayScene.HTILE_SIZE;
		y = -PlayScene.HTILE_SIZE;

		graphic = emitter;
		layer = 4;
	}

	public function greenExplode(x:Float, y:Float, count:Int=20) {
		if (emitter == null) return;
		// HXP.log("emitting");
		for (i in 0...count) {			
			emitter.emit("green_explode", x, y);
		}
	}

	public function redExplode(x:Float, y:Float, count:Int=20) {
		if (emitter == null) return;
		// HXP.log("emitting");
		for (i in 0...count) {			
			emitter.emit("red_explode", x, y);
		}
	}

	public function redHurt(x:Float, y:Float, count:Int=10) {
		if (emitter == null) return;
		// HXP.log("emitting");
		for (i in 0...count) {			
			emitter.emit("red_hurt", x, y);
		}
	}

	public function greenHurt(x:Float, y:Float, count:Int=10) {
		if (emitter == null) return;
		// HXP.log("emitting");
		for (i in 0...count) {			
			emitter.emit("green_hurt", x, y);
		}
	}
}