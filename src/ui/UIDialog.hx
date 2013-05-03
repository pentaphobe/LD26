
package ui;
import entities.EntityGroup;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import flash.geom.Rectangle;
// import ext.com.kpulv.NineSlice;
// import ext.com.haxepunk.NineSlice;
import ui.NineSlice;
// import com.haxepunk.graphics.atlas.Atlas;
// import com.haxepunk.graphics.atlas.AtlasRegion;

class UIDialog extends EntityGroup<Entity> {
	var padding:Int = 15;
	public function new(?x:Float=0, ?y:Float = 0, ?w:Float=0, ?h:Float=0) {
		super(x, y);
		width = cast w;
		height = cast h;
		graphic = new NineSlice(cast w, cast h, new Rectangle(0, 0, 12, 12), "gfx/testslice2.png");
		graphic.scrollX = 0;
		graphic.scrollY = 0;
		// setHitbox(cast w, cast h, cast x, cast y);
	}

	public function setSize(width:Float, height:Float) {
		cast(graphic, NineSlice).setSize(width, height);
		// setHitbox(cast width, cast height, 0, 0);
	}

	public override function add(e:Entity):Entity {
		// if (e.x < padding) {
		// 	x += e.x;
		// 	e.x = padding;
		// }
		// if (e.y < padding) {
		// 	y += e.y;
		// 	e.y = padding;
		// }
		if (e.graphic != null) {
			e.graphic.scrollX = 0;
			e.graphic.scrollY = 0;
			if (e.x + e.width + padding*2 > width || e.y + e.height + padding*2 > height) {
				cast(graphic, NineSlice).setSize(Math.max(width, e.x + e.width + padding*2), Math.max(height, e.y + e.height + padding*2));
			}			
		} else {
			HXP.log("NULL GRAPHIC");
		}
		e.x += x + padding;
		e.y += y + padding;	
		e.layer = layer - 1;	
		super.add(e);
		return e;
	}

}