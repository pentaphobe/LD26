
package entities;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Grid;

import scenes.PlayScene;
import server.ComputerPlayer;
import server.Agent;

class Level extends EntityGroup<Entity> {
	public var jsonData:Dynamic;
	public var mapWidth(default, default):Int;
	private function set_mapWidth(w:Int):Int { mapWidth = w; return mapWidth; }
	public var mapHeight(default, default):Int;
	private function set_mapHeight(w:Int):Int { mapHeight = w; return mapHeight; }

	var entityMap:Array<Agent>;
	var map:Tilemap;
	var grid:Grid;
	public var title:String;
	public function new() {
		super(0, 0);				
	}

	public function load(levelName:String) {		
		HXP.log("loading level " + levelName);
		clearEntities();
		jsonData = Utils.loadJson(levelName);

		createMap();
		createActors();		
		updateDifficultySettings();
	}

	public function updateDifficultySettings() {
		if (!Reflect.hasField(jsonData, "ai")) return;
		var getDefault:String->Float->Float;
		getDefault = function (name:String, defaultValue:Float):Float {
			if ( Reflect.hasField(jsonData.ai, name) ) {
				return cast Reflect.field(jsonData.ai, name);
			}
			return defaultValue;
		};

		ComputerPlayer.TICKS_PER_THINK = cast getDefault("think_delay", 12);
		ComputerPlayer.LOW_POPULATION_THRESH = cast getDefault("low_population_thresh", 6);
		ComputerPlayer.DESIRED_POPULATION_LEAD = cast getDefault("desired_population_lead", 1.5);
		ComputerPlayer.IMPATIENCE_TICKS = cast getDefault("impatience_delay", 1.5);
	}

	public function createMap() {
		// HXP.log(jsonData);
		// HXP.log("Creating Map:" + jsonData.id + "[" + jsonData.title + "] size:" + jsonData.map.size.x + ", " + jsonData.map.size.y);
		if (jsonData == null) {
			HXP.log("YOU SUUUUUCK");
			return;
		}
		mapWidth = jsonData.map.size.x;
		mapHeight = jsonData.map.size.y;
		entityMap = new Array();
		entityMap[mapWidth*mapHeight-1] = null;
		width = cast toScreenX(mapWidth);
		height = cast toScreenY(mapHeight);
		title = jsonData.title;
		map = new Tilemap(HXP.getBitmap("gfx/tiles.png"), width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		grid = new Grid(width, height, PlayScene.TILE_SIZE, PlayScene.TILE_SIZE);
		var idx:Int = 0;
		for (y in 0...mapHeight) {
			for (x in 0...mapWidth) {
				entityMap[idx] == null;
				idx++;

				if ( x == 0 || x == mapWidth-1 || y == 0 || y == mapHeight-1 ) {
					var tileIndex:Int = 1;
					if (x == 0) tileIndex = 9;
					if (x == mapWidth-1) tileIndex = 11;
					if (y == 0) tileIndex = 10;
					if (y == mapHeight-1) tileIndex = 8;
					if ( (x == 0 || x == mapWidth-1) && (y == 0 || y == mapHeight-1) ) {
						continue;
					}

					map.setTile(x, y, tileIndex);
					grid.setTile(x, y, true);
				} else {
					map.setTile(x, y, 0);
					grid.setTile(x, y, false);
				}
			}
		}
		var e:Entity = new Entity(0, 0, map, grid);
		e.type = "gameMap";
		add(e);
		// HXP.scene.add(e);
	}

	public function setAgent(x:Int, y:Int, agent:Agent):Bool {
		var offs:Int = y * mapWidth + x;

		// if (entityMap[offs] != null) {
		// 	// dangerously iterate through neighboring areas
		// 	if (setAgent(x - 1, y, agent)) return true;
		// 	if (setAgent(x + 1, y, agent)) return true;
		// 	if (setAgent(x, y- 1, agent)) return true;
		// 	if (setAgent(x, y+1, agent)) return true;
		// 	return false;
		// }

		entityMap[offs] = agent;
		map.clearTile(x, y);
		if (agent != null) {
			map.setTile(x, y, 1);
		} else {
			map.setTile(x, y, 0);			
		}
		return true;
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