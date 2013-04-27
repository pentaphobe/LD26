
package utils;
import com.haxepunk.HXP;

class ActorTemplate {
	public var typeName:String;
	public var parent:ActorTemplate=null;
	public var stats:Hash<Float>;
	public function new() {
		stats = new Hash<Float>();
	}
	public function load(jsonData:Dynamic, ?parent:ActorTemplate=null) {
		this.typeName = jsonData.name;
		this.parent = parent;
		for ( i in Reflect.fields(jsonData.stats) ) {
			this.stats.set(i, Reflect.field(jsonData.stats, i));
			HXP.log(i + ", " + Reflect.field(jsonData.stats, i));
		}		
	}
	public function get(statName:String):Float {
		if (!stats.exists(statName)) {
			if (parent != null) {
				return parent.get(statName);
			}
			HXP.log("ActorTemplate.get() - no stat named " + statName);
			HXP.log("my parent is " + parent);
			return 0;
		}
		return stats.get(statName);
	}
	public function keys():Iterator<String> {
		var result = new Hash<Float>();
		if (parent != null) {
			HXP.log(typeName + " getting keys from parent " + parent.typeName);
			for (i in parent.keys()) {
				result.set(i, parent.get(i));
			}
		} else {
			HXP.log(typeName + " has no parent to inherit from");
		}
		for (i in stats.keys()) {
			result.set(i, stats.get(i));
		}

		return result.keys();
	}
	public function clone():ActorTemplate {
		var tpl:ActorTemplate = new ActorTemplate();
		tpl.typeName = typeName + "_";
		tpl.parent = this;
		for ( i in stats.keys() ) {
			tpl.stats.set(i, stats.get(i));
		}
		return tpl;
	}
}
