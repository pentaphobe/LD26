
package states;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Draw;
import com.haxepunk.HXP;


class UIState extends PrototypeState {	
	public override function new(name:String) {
		super(name);
	}
	public override function update() {
		if (Input.released(Key.ESCAPE)) {
			isDone = true;
			return;
		}
		super.update();
	}
}