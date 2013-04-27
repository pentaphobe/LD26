
package states;
import com.haxepunk.HXP;

class State {
	public var name:String;
	public var isDone(get_isDone, set_isDone):Bool = false;
	public function new(name:String) {
		this.name = name;
	}

	public function enter() {
		HXP.log("entering state: " + name);
	}
	public function update() {
		HXP.log("updating state: " + name);
	}

	public function render() {
		HXP.log("rendering state: " + name);
	}

	public function exit() {
		HXP.log("exiting state: " + name);		
	}
	
	public function get_isDone():Bool { return isDone; }
	function set_isDone(value:Bool):Bool { isDone = value; return value;}
}