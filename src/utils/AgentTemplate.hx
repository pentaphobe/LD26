
package utils;
import com.haxepunk.HXP;

class AgentTemplate {
	public var typeName:String;
	public var parent:AgentTemplate=null;
	public var data:Dynamic;
	public var stats:Hash<Float>;
	public function new() {
		stats = new Hash<Float>();
	}
	public function load(jsonData:Dynamic, ?parent:AgentTemplate=null) {
		this.data = jsonData;
		this.typeName = jsonData.name;
		this.parent = parent;
		for ( i in Reflect.fields(jsonData.stats) ) {
			this.stats.set(i, Reflect.field(jsonData.stats, i));
			// HXP.log(i + ", " + Reflect.field(jsonData.stats, i));
		}		
	}
	public function get(statName:String):Float {
		if (!stats.exists(statName)) {
			if (parent != null) {
				return parent.get(statName);
			}
			HXP.log("AgentTemplate.get() - no stat named " + statName);
			HXP.log("my parent is " + parent);
			return 0;
		}
		return stats.get(statName);
	}
	/** recursively drills down into the data objet using reflection
	 * fails gracefully and returns null
	 */
	public function getData(dataPath:String):Dynamic {
		var members:Array<String> = dataPath.split(".");
		var cursor:Dynamic = data;
		for ( member in members ) {
			if (!Reflect.hasField(cursor, member)) {
				return null;
			}
			cursor = Reflect.field(cursor, member);
		}
		return cursor;
	}
	public function keys():Iterator<String> {
		var result = new Hash<Float>();
		if (parent != null) {
			// HXP.log(typeName + " getting keys from parent " + parent.typeName);
			for (i in parent.keys()) {
				result.set(i, parent.get(i));
			}
		} else {
			// HXP.log(typeName + " has no parent to inherit from");
		}
		for (i in stats.keys()) {
			result.set(i, stats.get(i));
		}

		return result.keys();
	}
	public function clone():AgentTemplate {
		var tpl:AgentTemplate = new AgentTemplate();
		tpl.typeName = typeName + "_";
		tpl.parent = this;
		for ( i in stats.keys() ) {
			tpl.stats.set(i, stats.get(i));
		}
		return tpl;
	}
}
