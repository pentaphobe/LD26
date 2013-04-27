import com.haxepunk.Engine;
import com.haxepunk.HXP;
import scenes.TestScene;

class Main extends Engine
{

	override public function init()
	{
#if debug
		HXP.console.enable();
#end
		HXP.scene = new TestScene();
	}

	public static function main() { new Main(); }

}