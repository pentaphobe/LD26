
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import states.UIState;
import states.PrototypeState;
import states.StateMachine;
import states.State;
import nme.text.TextFormatAlign;
import com.haxepunk.utils.Draw;
import ui.Menu;
import Utils;

class MenuScene extends Scene {
	var menu:Menu;
	var title:String;
	var config:Dynamic;
	public function new() {
		super();
		menu = new Menu("menu");
		config = Utils.loadJson("mainmenu");
		title = config.title;
		var main = config.sections.main.items;
		for ( item in cast(main, Array<Dynamic>) ) {			
			HXP.log(item.label);
		}
	}

	public override function render() {
		var x:Int = cast (HXP.screen.width / 4);
		var y:Int = cast (HXP.screen.height / 2);
		Draw.text(title, x, y, {color:0xdddddd, align:TextFormatAlign.CENTER});
		for ( item in cast(config.sections.main.items, Array<Dynamic>)) {
			y += 20;
			Draw.text(item.label, x, y);
		}
	}

	public override function update() {
		if (Input.pressed(Key.ANY) || Input.mousePressed) {
			HXP.scene = new PlayScene();
		}
	}
}