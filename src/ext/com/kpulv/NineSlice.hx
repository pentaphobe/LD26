/* Ported from the AS3 version at
 * http://kpulv.com/96/Flashpunk_NineSlice_Class__Updated__/
 */
package ext.com.kpulv;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
/**
 * NineSlice.as
 * @author kpulv
 */
class NineSlice extends Image {
	
	private var _width:UInt;
	private var _height:UInt;
	
	public var gridX:UInt;
	public var gridY:UInt;
	
	public var snapWidth:Bool = false;
	public var snapHeight:Bool = false;
	
	public var stretchLeft:Bool = false;
	public var stretchTop:Bool = false;
	public var stretchRight:Bool = false;
	public var stretchBottom:Bool = false;
	public var stretchCenter:Bool = false;
	
	private static var cachedPoint:Point = new Point();
	private static var cachedRect:Rectangle = new Rectangle();
	
	private var sliceSource(get_sliceSource, set_sliceSource):BitmapData;
	
	public var sliceBuffer:BitmapData;
	
	public var image:Image;
	
	public var slices:Array<BitmapData>;
	
	private var needsRefresh:Bool = false;
	
	public function new(sliceSource:Dynamic, width:UInt = 1, height:UInt = 1) {
		slices = new Array<BitmapData>();
		_bitmap = new Bitmap();
		_width = width;
		_height = height;
		
		if (Std.is(sliceSource, Class)) {
			this.sliceSource = HXP.getBitmap(sliceSource);
		}
		else {
			this.sliceSource = sliceSource;
		}
		
		copy();
		
		super(sliceBuffer);
	}
	
	public function updateSliceBuffer():Void {
		if (_source != null) {
			_source.dispose();
		}
		_source = sliceBuffer;
		_sourceRect = sliceBuffer.rect;
		createBuffer();
		updateBuffer();
	}
	
	public function copy():Void {
		if (_width == 0 || _height == 0) {
			sliceBuffer = new BitmapData(1, 1);
			sliceBuffer.fillRect(sliceBuffer.rect, 0);
			return;
		}
		
		var i:UInt = 0;
		var j:UInt = 0;
		for (i in 0...9) {
			slices[i] = new BitmapData(gridX, gridY);
			var xx:UInt = convert2dX(i, 3) * gridX;
			var yy:UInt = convert2dY(i, 3) * gridY;
			slices[i].copyPixels(sliceSource, cacheRect(xx, yy, gridX, gridY), cachePoint(0, 0));
		}
		
		sliceBuffer = new BitmapData(_width, _height);
		sliceBuffer.fillRect(sliceBuffer.rect, 0);
		
		
		
		var bd:BitmapData;
		
		/** Draw the center */
		if (stretchCenter) {
			if (_width > gridX + gridX) {
				if (_height > gridY + gridY) {
					bd = scaleBitmapData(slices[4], (_width - gridX - gridX) / gridX, (_height - gridY - gridY) / gridY);
					sliceBuffer.copyPixels(bd, bd.rect, cachePoint(gridX, gridY));
					bd.dispose();
				}
			}
		}
		else {
			var i:Int = gridX;
			while (i < _width - gridX) {
				var j:Int = gridY;
				while (j < _height - gridY) {
					sliceBuffer.copyPixels(slices[4], slices[4].rect, cachePoint(i, j));
					j += gridY;
				}
				i += gridX;
			}
		}
		
		/** Draw the edges */
		if (stretchTop) {
			if (_width > gridX + gridX) {
				bd = scaleBitmapData(slices[1], (_width - gridX - gridX) / gridX, 1);
				sliceBuffer.copyPixels(bd, bd.rect, cachePoint(gridX, 0));
				bd.dispose();
			}
		}
		else {
			var i:Int = gridX;
			while (i < _width - gridX) {
				sliceBuffer.copyPixels(slices[1], slices[1].rect, cachePoint(i, 0));
				i += gridX;
			}
		}
		
		if (stretchBottom) {
			if (_width > gridX + gridX) {
				bd = scaleBitmapData(slices[7], (_width - gridX - gridX) / gridX, 1);
				sliceBuffer.copyPixels(bd, bd.rect, cachePoint(gridX, _height - gridY));
				bd.dispose();
			}
		}
		else {
			var i:Int = gridX;
			while (i < _width - gridX) {
				sliceBuffer.copyPixels(slices[7], slices[7].rect, cachePoint(i, _height - gridY));	
				i += gridX;
			}
		}
		
		if (stretchLeft) {
			if (_height > gridY + gridY) {
				bd = scaleBitmapData(slices[3], 1, (_height - gridY - gridY) / gridY);
				sliceBuffer.copyPixels(bd, bd.rect, cachePoint(0, gridY));
				bd.dispose();
			}
		}
		else {
			var i:Int = gridY;
			while (i < _height - gridY) {
				sliceBuffer.copyPixels(slices[3], slices[3].rect, cachePoint(0, i));
				i += gridY;
			}
		}
		
		if (stretchRight) {
			if (_height > gridY + gridY) {
				bd = scaleBitmapData(slices[5], 1, (_height - gridY - gridY) / gridY);
				sliceBuffer.copyPixels(bd, bd.rect, cachePoint(_width - gridX, gridY));
				bd.dispose();
			}
		}
		else {
			var i:Int = gridY;
			while (i < _height - gridY) {
				sliceBuffer.copyPixels(slices[5], slices[5].rect, cachePoint(_width - gridX, i));
				i += gridY;
			}
		}
		
		/** draw corners */
		sliceBuffer.copyPixels(slices[0], slices[0].rect, cachePoint(0, 0));
		sliceBuffer.copyPixels(slices[2], slices[2].rect, cachePoint(_width - gridX, 0));
		sliceBuffer.copyPixels(slices[6], slices[6].rect, cachePoint(0, _height - gridY));
		sliceBuffer.copyPixels(slices[8], slices[8].rect, cachePoint(_width - gridX, _height - gridY));
		
		bd = null;
	}

	
	private function cachePoint(x:Float = 0, y:Float = 0):Point {
		cachedPoint.x = x;
		cachedPoint.y = y;
		return cachedPoint;
	}
	
	private function cacheRect(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0 ):Rectangle {
		cachedRect.x = x;
		cachedRect.y = y;
		cachedRect.width = width;
		cachedRect.height = height;
		return cachedRect;
	}
	
	public function get_sliceSource():BitmapData { return sliceSource; }
	public function set_sliceSource(value:Dynamic):BitmapData {
		if (Std.is(value, BitmapData) && cast(value, BitmapData) == sliceSource) return sliceSource;
		
		if (Std.is(value, Class)) {
		sliceSource = HXP.getBitmap(value);
		}
		else {
		sliceSource = value;
		}
		
		gridX = cast(sliceSource.width / 3);
		gridY = cast(sliceSource.height / 3);
		
		copy();
		updateSliceBuffer();
		return sliceSource;
	}
	
	public function set_width(value:UInt):Void {
		if (value == _width) return;
		
		var temp:UInt = _width;
		_width = value;
		if (snapWidth) {
			_width = Math.floor(_width / gridX) * gridX;
			if (temp == _width) return;
		}
		
		copy();
		updateSliceBuffer();
	}
	
	public function set_height(value:UInt):Void {
		if (value == _height) return;
		
		var temp:UInt = _height;
		_height = value;
		if (snapHeight) {
			_height = Math.floor(_height / gridY) * gridY;
			if (temp == _height) return;
		}
		
		copy();
		updateSliceBuffer();
	}
	
	public function get_y2():Float {
		return y + height;
	}
	
	public function get_x2():Float {
		return x + width;
	}
	
	public function get_centerX():Float {
		return x + width / 2;
	}
	
	public function get_centerY():Float {
		return y + height / 2;
	}

	function scaleBitmapData(bitmapData:BitmapData, scaleX:Float, scaleY:Float):BitmapData {
        scaleX = Math.abs(scaleX);
        scaleY = Math.abs(scaleY);
        var width:Int = cast (bitmapData.width * scaleX);
        if (width == 0) width = 1;
        var height:Int = cast (bitmapData.height * scaleY);
        if (height == 0) height = 1;
        var transparent:Bool = bitmapData.transparent;
        var result:BitmapData = new BitmapData(width, height, transparent);
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        result.draw(bitmapData, matrix);
        return result;
    }

    function convert2dX(i:Int, width:UInt):Int {
		return i % width;
	}

	function convert2dY(i:Int, width:UInt):Int {
		return Math.floor(i / width);
	}
	
}
