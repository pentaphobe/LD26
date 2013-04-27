
package ;
import tjson.TJSON;
import com.haxepunk.HXP;

class Utils {

	public static function loadJson(fname:String):Dynamic {
		var basePath:String = "config/";
		var path = basePath + fname + ".json";

		var contents:String;
		contents = nme.Assets.getText(path);
		if (contents == null) {
			HXP.log(" -- couldn't load json " + path);
			return null;
		}
		var object = TJSON.parse(contents);
		// HXP.log(object);
		if (object == null) {
			HXP.log(" -- loaded json file but got no data");
			return null;
		}
		return object;		
	}	

}