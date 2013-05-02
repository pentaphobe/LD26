import com.haxepunk.Engine;
import com.haxepunk.HXP;
import flash.events.Event;
import flash.events.MouseEvent;
import scenes.TestScene;
import scenes.MenuScene;

class Main extends Engine
{
	public static inline var kScreenWidth:Int = 640;
	public static inline var kScreenHeight:Int = 400;
	public static inline var kFrameRate:Int = 60;
	public static inline var kClearColor:Int = 0x222222;
	public static inline var kUseFixedUpdate:Bool = false;

	public static var VERSION:String = "Jam/Post-Compo 0.0.8";

	public override function new() {
		//super(kScreenWidth, kScreenHeight, kFrameRate, kUseFixedUpdate);
		super();
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
		});
		
		HXP.stage.addEventListener(Event.DEACTIVATE, function (e:Event) {
			HXP.focused = false;
			focusLost();
		});

		// detectMouseOutOfBounds();


	}

	public override function focusLost() {
			HXP.scene.focusLost();
	}

	public override function focusGained() {
			HXP.scene.focusGained();
	}

	/* The following snippet was ported wholly from the
	 * following answer on StackOverflow:
	 * http://stackoverflow.com/a/2850951/679950
	 */
	// Stage rollout detection:
	private var mouse_dx:Float;
	private var mouse_dy:Float;

	private function detectMouseOutOfBounds ():Void {
	    mouse_dx = HXP.screen.mouseX;
	    mouse_dy = HXP.screen.mouseY;

	    var mouseListener:Dynamic = { };
	    HXP.stage.addEventListener(MouseEvent.MOUSE_MOVE, function (e:Event) {
	            mouse_dx = Math.abs(mouse_dx-HXP.screen.mouseX);
	            mouse_dy = Math.abs(mouse_dy-HXP.screen.mouseY);
	            var speed:Float = Math.max(mouse_dx, mouse_dy) + 5; // Precautionary buffer added.
	            var willBeOutOfBounds:Bool = (
	                HXP.screen.mouseX - speed < 0 || 
	                HXP.screen.mouseX + speed > HXP.screen.width ||
	                HXP.screen.mouseY - speed < 0 ||
	                HXP.screen.mouseY + speed > HXP.screen.height
	            );
	            if (willBeOutOfBounds) {
	                focusLost();
	            } else {
	                focusGained();
	            }
	            mouse_dx= HXP.screen.mouseX;
	            mouse_dy = HXP.screen.mouseY;
	        }
	    );
	}
	/* end snippet of other code */

	public static function main() { new Main(); }

}