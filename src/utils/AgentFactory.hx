
package utils;
import entities.Actor;
import com.haxepunk.HXP;
import scenes.PlayScene;
import entities.Level;

import server.Agent;

import scenes.PlayScene;

class AgentFactory {
	static var AgentTemplates:Hash<AgentTemplate>;
	public static function load(jsonData:Dynamic) {
		AgentTemplates = new Hash<AgentTemplate>();
		for (i in Reflect.fields(jsonData)) {
			var entry:Dynamic = Reflect.field(jsonData, i);
			var tpl:AgentTemplate = new AgentTemplate();
			AgentTemplates.set(i, tpl );
			tpl.load( entry );
			HXP.log(i);
		}
		for (i in Reflect.fields(jsonData)) {
			var entry:Dynamic = Reflect.field(jsonData, i);
			var tpl:AgentTemplate = AgentTemplates.get(i);
			var par:AgentTemplate = AgentTemplates.get(entry.parent);
			if (par == null) {
				HXP.log(entry.name + " - no parent named " + entry.parent);				
			} else {
				HXP.log(entry.name + " - parent is " + entry.parent);
				tpl.parent = par;								
			}			
		}
	}
	public static function create(type:String, teamName:String, ?x:Int=0, ?y:Int=0):Actor {
		if (!AgentTemplates.exists(type)) {
			HXP.log("couldn't find Actor Template named " + type + ", creating a blank");
			return new Actor(teamName, x, y);
		}
		var level:Level = PlayScene.instance.level;
		if (level == null) {
			HXP.log("level is null for some reason");
			return null;
		}
		// [@remove when actor is feature complete]
		// [@... not strictly necessary, actor queries agent]		
		var scrX:Float = level.toScreenX( x );
		var scrY:Float  = level.toScreenY( y );

		var template:AgentTemplate = AgentTemplates.get(type);
		var actor:Actor = new Actor(teamName, scrX, scrY);
		actor.layer = 10;
		// actor.applyTemplate(template);

		var agent:Agent = PlayScene.server.createAgent(teamName, x, y);
		// we duplicate the template since we want to potentially allow individual progression 
		agent.config = template.clone();
		actor.agent = agent;
		actor.label.text = actor.teamName + "\n" + agent.config.parent.typeName;			
		agent.reset();
		return actor;
	}

}