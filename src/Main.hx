import com.haxepunk.Engine;
import com.haxepunk.HXP;
import flash.events.Event;
import scenes.TestScene;
import scenes.MenuScene;

class Main extends Engine
{
	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 400;
	public static inline var kFrameRate:Int = 30;
	public static inline var kClearColor:Int = 0x222222;

	public override function new() {
		super(kScreenWidth, kScreenHeight, kFrameRate, false);
	}
	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;

		Assets.loadAssets();
		
		HXP.scene = new MenuScene();

		HXP.stage.addEventListener(Event.ACTIVATE, function (e:Event) {
			HXP.focused = true;
			focusGained();
			HXP.scene.focusGained();
		});
		
		HXP.stage.addEventListener(Event.DEACTIVATE, function (e:Event) {
			HXP.focused = false;
			focusLost();
			HXP.scene.focusLost();

		});

	}

	public static function main() { new Main(); }

}