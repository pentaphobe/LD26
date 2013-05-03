
package ui;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;
import com.haxepunk.HXP;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Draw;

class NineSlice extends Image {
	var region:Rectangle;
	var actualWidth:Int;
	var actualHeight:Int;
	var minWidth:Int;
	var minHeight:Int;

	var topLeft:Rectangle;
	var topMiddle:Rectangle;
	var topRight:Rectangle;
	var midLeft:Rectangle;
	var midMiddle:Rectangle;
	var midRight:Rectangle;
	var botLeft:Rectangle;
	var botMiddle:Rectangle;
	var botRight:Rectangle;

	public function new(width:Int, height:Int, region:Rectangle, skin:Dynamic) {
		super(skin, region);
		this.region = region;
		this.actualWidth = width;
		this.actualHeight = height;

		var sliceWidth:Int = cast(region.width / 3);
		var sliceHeight:Int = cast(region.height / 3);
		minWidth = cast region.width;
		minHeight = cast region.height;

		topLeft = new Rectangle(0, 0, sliceWidth, sliceHeight);
		topMiddle = new Rectangle(sliceWidth, 0, sliceWidth, sliceHeight);
		topRight = new Rectangle(region.width - sliceWidth, region.y, sliceWidth, sliceHeight);

		midLeft = new Rectangle(0, 0 + sliceHeight, sliceWidth, sliceHeight);
		midMiddle = new Rectangle(0 + sliceWidth, 0 + sliceHeight, sliceWidth, sliceHeight);
		midRight = new Rectangle(region.width - sliceWidth, 0 + sliceHeight, sliceWidth, sliceHeight);

		botLeft = new Rectangle(0, region.height - sliceHeight, sliceWidth, sliceHeight);
		botMiddle = new Rectangle(0 + sliceWidth, region.height - sliceHeight, sliceWidth, sliceHeight);
		botRight = new Rectangle(region.width - sliceWidth, region.height - sliceHeight, sliceWidth, sliceHeight);

	}
	public function setSize(width:Float, height:Float) {
		if (width < minWidth) width = minWidth;
		if (height < minHeight) height = minHeight;
		this.actualWidth = cast width;
		this.actualHeight = cast height;
	}
	public override function render(target:BitmapData, point:Point, camera:Point) {
		// determine drawing location
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;
		// Draw.rectPlus(cast _point.x, cast _point.y, actualWidth, actualHeight, 0xff00ff,1,false);

		// super.render(target, point, camera);
		var midWidth:Int = actualWidth - cast (topLeft.width + topRight.width);
		var midHeight:Int = actualHeight - cast(topLeft.height + botLeft.height);
		var stepsAcross:Int = cast(midWidth / topMiddle.width) + 1;
		var stepsDown:Int = cast(midHeight / midMiddle.height) + 1;
		var pt:Point = _point.clone();

		target.copyPixels(_buffer, topLeft, pt, null, null, true);
		pt.x += topLeft.width;
		for (i in 0...stepsAcross) {
			target.copyPixels(_buffer, topMiddle, pt, null,null, true);
			pt.x += topMiddle.width;
		}
		target.copyPixels(_buffer, topRight, pt, null, null, true);



		
		pt.y = _point.y + topLeft.height;
		for (j in 0...stepsDown) {
			pt.x = _point.x;
			target.copyPixels(_buffer, midLeft, pt, null, null, true);
			pt.x += midLeft.width;
			for (i in 0...stepsAcross) {
				target.copyPixels(_buffer, midMiddle, pt, null,null, true);
				pt.x += midMiddle.width;
			}
			target.copyPixels(_buffer, midRight, pt, null, null, true);
			pt.y += midLeft.height;
		}

		pt.x = _point.x;
		pt.y = _point.y + (midHeight + topLeft.height);
		target.copyPixels(_buffer, botLeft, pt, null, null, true);
		pt.x += topLeft.width;
		for (i in 0...stepsAcross) {
			target.copyPixels(_buffer, botMiddle, pt, null,null, true);
			pt.x += topMiddle.width;
		}
		target.copyPixels(_buffer, botRight, pt, null, null, true);

		// Draw.rectPlus(cast _point.x, cast _point.y, actualWidth, actualHeight, 0xff00ff, 1, false);
	}

}