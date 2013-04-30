
package ui;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import nme.text.TextFormatAlign;
import nme.filters.BlurFilter;

import com.haxepunk.utils.Draw;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.graphics.Image;

import scenes.MenuScene;
import scenes.ServerTestScene;

import states.State;
import states.UIState;
import states.StateMachine;
import ui.UIEntity;

typedef MenuCallback = String->Void;

class MenuState extends State {
	var items:List<Entity>;
	var config:Dynamic;
	var title:String;
	var uiCallback:UICallback;
	var menuCallback:MenuCallback;
	var actions:Hash<String>;
	var x:Int;
	var y:Int;
	var itemHeight:Int = 27;
	
	public function new(id:String, config:Dynamic, ?menuCallback:MenuCallback=null, ?uiCallback:UICallback=null, ?x:Int = 0, ?y:Int = 0) {
		super(id);
		this.config = config;
		title = config.title;
		this.menuCallback = menuCallback;
		this.uiCallback = uiCallback;
		this.x = x;
		this.y = y;
	}

	public override function enter() {
		// HXP.log("creating menu state " + title);		
		var configItems:Array<Dynamic> = cast config.items;		
		actions = new Hash<String>();
		items = new List<Entity>();
		var currentY:Int = y;
		if ( Reflect.hasField(config, "background") ) {
			var bgName:String = config.background;
			var ent:Entity = new Entity(0, 0);
			if (bgName == "@blurred") {
				var bg:Image = HXP.screen.capture();
				bg.applyFilter(new BlurFilter(4, 4));
				bg.scrollX = bg.scrollY = 0;
				ent.graphic = bg;
			} else {
				var bg:Stamp = new Stamp("gfx/" + config.background);
				ent.graphic = bg;
			}
			
			HXP.scene.add(ent);
			items.add(ent);
		} else {
			
		}
		var xStart = 0;
		for ( item in configItems ) {
			var tmp:Bool = config.fullWidth;
			var entity:UIEntity = new TextButton(item.label, item.label, xStart, currentY, this.dispatchEvents, true, true, tmp);

			HXP.scene.add(entity);
			HXP.tween(entity, {x:x}, 0.4);
			items.add(entity);
			actions.set(item.label, item.action);
			// HXP.log("added entity at " + entity.x + ", " + entity.y + " to scene " + Type.getClassName(Type.getClass(HXP.scene)) );
			currentY += itemHeight;
			xStart -= cast Math.min(entity.width, 100);
		}		
	}

	// public override function render() {
	// 	// continuosly blur the background
	// 	var bg:Entity = items.first();
	// 	if (Std.is(bg.graphic, Image)) {
	// 		// cast(bg.graphic, Image).applyFilter(new BlurFilter(2, 2));
	// 		cast(bg.graphic, Image).applyFilter(new GlowFilter(4, 4));
	// 	}
	// }

	// public override function update() {
	// 	HXP.log("updating " + title);
	// }

	public override function exit() {
		// HXP.log("removing items");
		HXP.scene.removeList(items);
		items.clear();
	}

	public function dispatchEvents(eventType:String, source:UIEntity) {
		if (uiCallback != null) {
			uiCallback(eventType, source);
		}
		if (eventType == "onClick" && menuCallback != null) {
			var action:String = actions.get(source.uiName);
			var firstChar:String = action.charAt(0);
			var isInternal:Bool = firstChar == '@';
			if (action == "<") {
				HXP.log("GOT BACK ACTION, sending callback");
				menuCallback( actions.get("<") );
				HXP.log("Popping menu state");
				// cast(parent, Menu).addAction("pop");
				cast(parent, Menu).popState();
				return;
			}
			var isAdvanced:Bool = firstChar == ':';
			if (isInternal) {
				action = action.substr(1);
				if (action == "exit") {
					this.isDone = true;
					return;
				}
				// cast(parent, Menu).addAction("push", action);
				cast(parent, Menu).pushState(action);
			} else if (isAdvanced) {
				action = action.substr(1);
				var args:Array<String> = action.split(" ");
				if (args[0] == "scene") {
					HXP.log("attempting to start scene[scenes." + args[1] + "]");
					HXP.scene = Type.createInstance(Type.resolveClass("scenes."+args[1]), [] );
					return;
				}
			} else {
				menuCallback( actions.get(source.uiName) );								
			}
		}
	}
	public function toString():String {
		return "MenuState{" + this.title + "}";
	}
}

class Menu extends StateMachine<MenuState> {
	var config:Dynamic;
	var uiCallback:UICallback;
	var menuCallback:MenuCallback;
	var x:Int;
	var y:Int;
	public var isActive(get_isActive, set_isActive):Bool;
	public function new(name:String, menuCallback:MenuCallback, ?uiCallback:UICallback=null, ?x:Int=0, ?y:Int=0) {
		super(name);	
		this.x = x;
		this.y = y;
		this.uiCallback = uiCallback;	
		this.menuCallback = menuCallback;
		config = Utils.loadJson(name);
	
	}

	public override function enter() {
		// HXP.log("setting up menu: " + name);
		var sections = config.sections;

		for ( item in Reflect.fields(sections) ) {			
			var sectionName:String = item;
			// HXP.log("creating menu state " + sectionName);
			var menuState:MenuState = new MenuState( sectionName, Reflect.field(sections, sectionName), menuCallback, uiCallback,  x, y );
			addState(menuState);
		}	
		// HXP.log("fields:" + states);
		// addAction(config.start);		
		replaceState(config.start);
		super.enter();		
		isActive = true;
	}

	public override function exit() {
		// HXP.log("exiting hopefully");
		isActive = false;
		super.exit();
	}

	public override function update() {
		// [@todo this is for cascading menus - put it back eventually]
//		isActive = stateStack.length > 0;
	}

	public override function render() {
		// var x:Int = cast (HXP.screen.width / 4);
		// var y:Int = cast (HXP.screen.height / 2);
		// Draw.text(config.sections.main.title, x, y, {color:0xdddddd, align:TextFormatAlign.CENTER});
		// for ( item in cast(config.sections.main.items, Array<Dynamic>)) {
		// 	y += 20;
		// 	Draw.text(item.label, x, y);
		// }
		super.render();
	}

	public function get_isActive():Bool {
		return isActive;
	}
	private function set_isActive(val:Bool):Bool {
		isActive = val;
		return isActive;
	}

}