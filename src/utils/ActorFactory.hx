
package utils;
import entities.Actor;
import com.haxepunk.HXP;
import scenes.PlayScene;
class ActorFactory {
	static var actorTemplates:Hash<ActorTemplate>;
	public static function load(jsonData:Dynamic) {
		actorTemplates = new Hash<ActorTemplate>();
		for (i in Reflect.fields(jsonData)) {
			var entry:Dynamic = Reflect.field(jsonData, i);
			var tpl:ActorTemplate = new ActorTemplate();
			actorTemplates.set(i, tpl );
			tpl.load( entry );
			HXP.log(i);
		}
		for (i in Reflect.fields(jsonData)) {
			var entry:Dynamic = Reflect.field(jsonData, i);
			var tpl:ActorTemplate = actorTemplates.get(i);
			var par:ActorTemplate = actorTemplates.get(entry.parent);
			if (par == null) {
				HXP.log(entry.name + " - no parent named " + entry.parent);				
			} else {
				HXP.log(entry.name + " - parent is " + entry.parent);
				tpl.parent = par;								
			}			
		}
	}
	public static function create(type:String, teamName:String, ?x:Float=0, ?y:Float=0):Actor {
		if (!actorTemplates.exists(type)) {
			HXP.log("couldn't find Actor Template named " + type + ", creating a blank");
			return new Actor(teamName, x, y);
		}
		x = PlayScene.instance.level.toScreenX( PlayScene.instance.level.toMapX( x ) );
		y = PlayScene.instance.level.toScreenY( PlayScene.instance.level.toMapY( y ) );
		var template:ActorTemplate = actorTemplates.get(type);
		var actor:Actor = new Actor(teamName, x, y);
		// actor.applyTemplate(template);
		actor.config = template.clone();
		actor.label.text = actor.teamName + "\n" + actor.config.parent.typeName;			
		actor.reset();
		return actor;
	}

}