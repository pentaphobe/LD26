
package ;
import com.haxepunk.Sfx;

class Assets {
	public static var sfxHover:Sfx;
	public static var sfxClick:Sfx;
	public static var sfxSuwip:Sfx;
	public static var sfxMenuMusic:Sfx;
	public static var sfxGameMusic:Sfx;

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
		sfxMenuMusic = new Sfx(nme.Assets.getSound("sfx/menu_music." + extension));		
		sfxGameMusic = new Sfx(nme.Assets.getSound("sfx/game_music." + extension));		
	}

	public static function loadGraphics() {
		
	}

}