
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;

class PlayScene extends Scene {

	public function new() {
		super();
	}	

	public override function begin() {
		HXP.log("entering game");
	}
}