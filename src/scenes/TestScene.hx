
package scenes;
import com.haxepunk.Scene;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import states.UIState;
import states.PrototypeState;
import states.StateMachine;
import states.State;
import com.haxepunk.utils.Draw;

class TestScene extends Scene {
	var uiState:StateMachine<UIState>;

	public function new() {
		super();		
		uiState = new StateMachine("test");
		var tmp:UIState = new UIState("thing");
		tmp.setOverride(CustomRender, function (state:PrototypeState) {
			Draw.linePlus(0, 0, mouseX, mouseY, 0xffffff);
			Draw.text("Line State!", mouseX, mouseY - 20);
			HXP.screen.color = 0x400040;
		});
		tmp.setOverride(CustomExit, function(state:PrototypeState) {
			HXP.screen.color = 0x333333;
		});
		uiState.addStateAndEnter(tmp);

		tmp = new UIState("another");
		tmp.setOverride(CustomRender, function (state:PrototypeState) {
			Draw.circlePlus(mouseX, mouseY, 50, 0xffffff, 1, false);
			Draw.text("Circle State!", mouseX, mouseY - 20);
			HXP.screen.color = 0x101010;
		});
		uiState.addStateAndEnter(tmp);
		Draw.resetTarget();

	}	

	public override function begin() {
		uiState.enter();
	}

	public override function update() {
		super.update();		
		var shiftIsPressed:Bool = Input.check(Key.SHIFT);		
		uiState.update();
		if (uiState.isDone) {
			HXP.scene = new MenuScene();
		}
	}

	public override function render() {
		super.render();
		Draw.linePlus(cast(Math.random() * HXP.width), cast(Math.random() * HXP.height), 
						cast(Math.random() * HXP.width), cast(Math.random() * HXP.height), 0xff0000);
		Draw.text("This is the game rendering", cast(Math.random() * HXP.width), cast(Math.random() * HXP.height));
		uiState.render();
	}

}