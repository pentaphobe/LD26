
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Tilemap;

import scenes.PlayScene;

class Level extends EntityGroup {
	var jsonData:Dynamic;
	public function new() {
		super(0, 0);		
	}

	public function load(levelName:String) {		
		HXP.log("loading level " + levelName);
		clearEntities();
		jsonData = Utils.loadJson(levelName);
		createMap();
		createActors();
	}

	public function createMap() {
		HXP.log(jsonData);
		HXP.log("Creating Map:" + jsonData.id + "[" + jsonData.title + "] size:" + jsonData.map.size.x + ", " + jsonData.map.size.y);
		width = cast (jsonData.map.size.x * PlayScene.TILE_SIZE);
		height = cast (jsonData.map.size.y * PlayScene.TILE_SIZE);
		var map:Tilemap = new Tilemap(HXP.getBitmap("gfx/tiles.png"), width, height, jsonData.map.size.x, jsonData.map.size.y);
		var e:Entity = new Entity(0, 0, map);
	}

	public function createActors() {

	}
}