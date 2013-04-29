
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Grid;

import scenes.PlayScene;
import server.Agent;

class Level extends EntityGroup {
	public var jsonData:Dynamic;
	public var mapWidth(default, default):Int;
	private function set_mapWidth(w:Int):Int { mapWidth = w; return mapWidth; }
	public var mapHeight(default, default):Int;
	private function set_mapHeight(w:Int):Int { mapHeight = w; return mapHeight; }

	var entityMap:Array<Agent>;
	var map:Tilemap;
	var grid:Grid;
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
		entityMap = new Array();
		entityMap[mapWidth*mapHeight-1] = null;
		width = cast toScreenX(mapWidth);
		height = cast toScreenY(mapHeight);

		map = new Tilemap(HXP.getBitmap("gfx/tiles.png"), width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		grid = new Grid(width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		var idx:Int = 0;
		for (y in 0...mapHeight) {
			for (x in 0...mapWidth) {
				if ( x == 0 || x == mapWidth-1 || y == 0 || y == mapHeight-1 ) {
					map.setTile(x, y, 1);
					grid.setTile(x, y, true);
				} else {
					map.setTile(x, y, 0);
					grid.setTile(x, y, false);
				}
				entityMap[idx] == null;
				idx++;
			}
		}
		var e:Entity = new Entity(0, 0, map, grid);
		add(e);
		// HXP.scene.add(e);
	}

	public function setAgent(x:Int, y:Int, agent:Agent) {
		entityMap[y * mapWidth + x] = agent;
		map.clearTile(x, y);
		if (agent != null) {
			map.setTile(x, y, 1);
		} else {
			map.setTile(x, y, 0);			
		}

	}

	public function getAgent(x:Int, y:Int):Agent {
		return entityMap[y * mapWidth + x];
	}

	public function getWall(x:Int, y:Int):Bool {
		return grid.getTile(x, y);
	}

	public function createActors() {
		// var e:Entity = new Entity(0, 0, Image.createRect(20, 20)); 
		// add(e);
	}

	public function toScreenX(mapX:Int):Float {
		return (mapX * PlayScene.TILE_SIZE) /* + PlayScene.HTILE_SIZE*/;
	}
	public function toScreenY(mapY:Int):Float {
		return (mapY * PlayScene.TILE_SIZE) /* + PlayScene.HTILE_SIZE*/;
	} 

	public function toMapX(scrX:Float):Int {
		// scrX -= PlayScene.HTILE_SIZE;
		return cast(HXP.clamp(scrX / cast(PlayScene.TILE_SIZE,Float), 1, mapWidth-1));
	}
	public function toMapY(scrY:Float):Int {
		// scrY -= PlayScene.HTILE_SIZE;
		return cast( HXP.clamp(scrY / cast(PlayScene.TILE_SIZE, Float), 1, mapHeight-1));
	} 


}