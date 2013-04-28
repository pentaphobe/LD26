package utils;

class MapPoint {
	public var x:Int;
	public var y:Int;
	public function new(?x:Int=0, ?y:Int=0) {
		set(x, y);
	}
	public function set(?x:Int=0, ?y:Int=0) {
		this.x = x;
		this.y = y;
	}

	public function sub(x:Int, y:Int) {
		this.x -= x;
		this.y -= y;
	}

	public function equals(other:MapPoint):Bool {
		return other.x == x && other.y == y;
	}

	public function toString():String {
		return "{ " + this.x + ", " + this.y + " }";
	}
}