
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Grid;

import scenes.PlayScene;

class Level extends EntityGroup {
	var jsonData:Dynamic;
	var mapWidth:Int;
	var mapHeight:Int;
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
		// HXP.log(jsonData);
		HXP.log("Creating Map:" + jsonData.id + "[" + jsonData.title + "] size:" + jsonData.map.size.x + ", " + jsonData.map.size.y);
		mapWidth = jsonData.map.size.x;
		mapHeight = jsonData.map.size.y;
		width = cast toScreenX(mapWidth);
		height = cast toScreenY(mapHeight);
		var map:Tilemap = new Tilemap(HXP.getBitmap("gfx/tiles.png"), width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		var mask:Grid = new Grid(width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		for (y in 0...mapHeight) {
			for (x in 0...mapWidth) {
				if ( x == 0 || x == mapWidth-1 || y == 0 || y == mapHeight-1 ) {
					map.setTile(x, y, 1);
					mask.setTile(x, y, true);
				} else {
					map.setTile(x, y, 0);
					mask.setTile(x, y, false);
				}
			}
		}
		var e:Entity = new Entity(0, 0, map, mask);
		add(e);
		// HXP.scene.add(e);
	}

	public function createActors() {
		// var e:Entity = new Entity(0, 0, Image.createRect(20, 20)); 
		// add(e);
	}

	public function toScreenX(mapX:Int):Float {
		return (mapX * PlayScene.TILE_SIZE);
	}
	public function toScreenY(mapY:Int):Float {
		return (mapY * PlayScene.TILE_SIZE);
	} 

	public function toMapX(mapX:Float):Int {

		return cast(HXP.clamp(mapX / cast(PlayScene.TILE_SIZE,Float), 1, mapWidth-1));
	}
	public function toMapY(mapY:Float):Int {
		return cast( HXP.clamp(mapY / cast(PlayScene.TILE_SIZE, Float), 1, mapHeight-1));
	} 


}