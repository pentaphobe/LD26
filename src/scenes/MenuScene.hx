
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import nme.text.TextFormatAlign;
import com.haxepunk.utils.Draw;
import com.haxepunk.tweens.sound.SfxFader;

import Assets;
import states.UIState;
import states.PrototypeState;
import states.StateMachine;
import states.State;
import ui.Menu;
import ui.UIEntity;
import Utils;

class MenuScene extends Scene {
	var menu:Menu;
	public function new() {
		super();
		menu = new Menu("mainmenu", menuEvent, uiEvent, cast(HXP.screen.width / 2 - HXP.screen.width / 6) , cast(HXP.screen.height / 3 + HXP.screen.height / 3));
	}

	public override function begin() {
		super.begin();
		menu.enter();
		Assets.sfxMenuMusic.loop(0.1);
		var fader:SfxFader = new SfxFader(Assets.sfxMenuMusic /*, function (_) { Assets.sfxMenuMusic.stop(); } */ );
		fader.fadeTo(0.7, 4);
		addTween(fader);

	}

	public override function render() {
		super.render();		
		menu.render();
	}

	public override function end() {
		super.end();
		// HXP.tween(Assets.sfxMenuMusic, {volume:0}, 4.0);
		// var fader:SfxFader = new SfxFader(Assets.sfxMenuMusic, function (_) { Assets.sfxMenuMusic.stop(); });
		// fader.fadeTo(0, 1);
		// addTween(fader);
		Assets.sfxMenuMusic.stop();
	}

	public override function update() {
		// if (Input.pressed(Key.ANY) || Input.mousePressed) {
		// 	HXP.scene = new PlayScene();
		// }
		menu.update();
		super.update();
	}

	public function uiEvent(eventType:String, source:UIEntity) {
		// HXP.log("uiEvent:" + eventType + ", " + source);
		if (eventType == "onGotMouse") {
			Assets.sfxHover.play();
		} else if (eventType == "onClick") {
			Assets.sfxClick.play();
		}
	}

	public function menuEvent(action:String) {
		// HXP.log("menuEvent:" + action);
		if (action == "start") {
			HXP.scene = new PlayScene();
		}
	}
}