
package ui;
import entities.EntityGroup;
import com.haxepunk.HXP;
import flash.geom.Rectangle;
// import ext.com.kpulv.NineSlice;
// import ext.com.haxepunk.NineSlice;
import ui.NineSlice;
// import com.haxepunk.graphics.atlas.Atlas;
// import com.haxepunk.graphics.atlas.AtlasRegion;

class UIDialog extends EntityGroup<UIEntity> {

	public function new(?x:Float=0, ?y:Float = 0, ?w:Float=0, ?h:Float=0) {
		super(x, y);
		
		graphic = new NineSlice(cast w, cast h, new Rectangle(0, 0, 12, 12), "gfx/testslice.png");
		// setHitbox(cast w, cast h, cast x, cast y);
	}

	public function setSize(width:Float, height:Float) {
		cast(graphic, NineSlice).setSize(width, height);
		setHitbox(cast width, cast height, 0, 0);
	}

	public override function add(e:UIEntity):UIEntity {
		e.x += x;
		e.y += y;
		super.add(e);
		return e;
	}

}