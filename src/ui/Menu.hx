
package ui;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import nme.text.TextFormatAlign;
import com.haxepunk.utils.Draw;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Stamp;
import scenes.MenuScene;

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

	public function new(id:String, config:Dynamic, ?menuCallback:MenuCallback=null, ?uiCallback:UICallback=null, ?x:Int = 0, ?y:Int = 0) {
		super(id);
		this.config = config;
		title = config.title;
		this.menuCallback = menuCallback;
		this.uiCallback = uiCallback;
		HXP.log("creating menu state " + title);		
		var configItems:Array<Dynamic> = cast config.items;		
		actions = new Hash<String>();
		items = new List<Entity>();

		if ( Reflect.hasField(config, "background") ) {
			var bg:Stamp = new Stamp("gfx/" + config.background);
			var ent:Entity = new Entity(0, 0, bg);
			HXP.scene.add(ent);
			items.add(ent);
		}
		for ( item in configItems ) {
			var entity:UIEntity = new TextButton(item.label, item.label, x, y, this.dispatchEvents);
			HXP.scene.add(entity);
			items.add(entity);
			actions.set(item.label, item.action);
			HXP.log("added entity at " + entity.x + ", " + entity.y + " to scene " + Type.getClassName(Type.getClass(MenuScene)) );
			y += 20;
		}
	}

	// public override function render() {
	// 	HXP.log("render");
	// }

	// public override function update() {
	// 	HXP.log("updating " + title);
	// }

	public override function exit() {
		HXP.scene.removeList(items);
		items.clear();
	}

	public function dispatchEvents(eventType:String, source:UIEntity) {
		if (uiCallback != null) {
			uiCallback(eventType, source);
		}
		if (eventType == "onClick" && menuCallback != null) {
			var action:String = actions.get(source.uiName);
			var isInternal:Bool = action.charAt(0) == '@';
			if (!isInternal) {
				menuCallback( actions.get(source.uiName) );
			} else {
				if (action == "@exit") {
					this.exit();
				}
			}
		}
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
		HXP.log("setting up menu: " + name);
		var sections = config.sections;

		for ( item in Reflect.fields(sections) ) {			
			var sectionName:String = item;
			HXP.log("creating menu state " + sectionName);
			var menuState:MenuState = new MenuState( sectionName, Reflect.field(sections, sectionName), menuCallback, x, y );
			addState(menuState);
		}	
		HXP.log("fields:" + states);
		replaceState(config.start);
		super.enter();		
	}

	public override function exit() {
		exitCurrent();
		if (stateStack.length == 0) {

		}
	}

	public override function update() {
		isActive = stateStack.length > 0;
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