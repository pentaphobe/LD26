
package ;
import com.haxepunk.Sfx;

class Assets {
	public static var sfxHover:Sfx;
	public static var sfxClick:Sfx;
	public static var sfxSuwip:Sfx;

	public static function loadAssets() {
		loadSounds();
	}

	public static function loadSounds() {
		var extension:String;
		#if flash
			extension = "mp3";
		#else
			extension = "wav";
		#end

		sfxHover = new Sfx(nme.Assets.getSound("sfx/ui_blip." + extension));
		sfxClick = new Sfx(nme.Assets.getSound("sfx/ui_click." + extension));				
		sfxSuwip = new Sfx(nme.Assets.getSound("sfx/ui_suwip." + extension));		
	}

	public static function loadGraphics() {
		
	}

}