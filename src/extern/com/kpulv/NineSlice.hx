/* Ported from the AS3 version at
 * http://kpulv.com/96/Flashpunk_NineSlice_Class__Updated__/
 */
package com.kpulv;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
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
	
	public var snapWidth:Boolean = false;
	public var snapHeight:Boolean = false;
	
	public var stretchLeft:Boolean = false;
	public var stretchTop:Boolean = false;
	public var stretchRight:Boolean = false;
	public var stretchBottom:Boolean = false;
	public var stretchCenter:Boolean = false;
	
	private static var cachedPoint:Point = new Point();
	private static var cachedRect:Rectangle = new Rectangle();
	
	private var _sliceSource:BitmapData;
	
	public var sliceBuffer:BitmapData;
	
	public var image:Image;
	
	public var slices:Vector.<BitmapData> = new Vector<BitmapData>(9);
	
	private var needsRefresh:Boolean = false;
	
	public function new(sliceSource:Dynamic, width:UInt = 1, height:UInt = 1) {
		_bitmap = new Bitmap
		_width = width;
		_height = height;
		
		if (Std.is(source, Class)) {
			this.sliceSource = HXP.getBitmap(sliceSource);
		}
		else {
			this.sliceSource = sliceSource
		}
		
		copy();
		
		super(sliceBuffer);
	}
	
	public function updateSliceBuffer():void {
		if (_source) {
			_source.dispose();
		}
		_source = sliceBuffer;
		_sourceRect = sliceBuffer.rect;
		createBuffer();
		updateBuffer();
	}
	
	public function copy():void {
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
			slices[i].copyPixels(_sliceSource, cacheRect(xx, yy, gridX, gridY), cachePoint(0, 0));
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
		}a
		
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

	
	private function cachePoint(x:Number = 0, y:Number = 0):Point {
		cachedPoint.x = x;
		cachedPoint.y = y;
		return cachedPoint;
	}
	
	private function cacheRect(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0 ):Rectangle {
		cachedRect.x = x;
		cachedRect.y = y;
		cachedRect.width = width;
		cachedRect.height = height;
		return cachedRect;
	}
	
	public function get sliceSource():BitmapData { return _sliceSource; }
	public function set sliceSource(value:*):void {
		if (value == _sliceSource) return;
		
		if (value is Class) {
			_sliceSource = FP.getBitmap(value);
		}
		else {
			_sliceSource = value;
		}
		
		gridX = _sliceSource.width / 3;
		gridY = _sliceSource.height / 3;
		
		copy();
		updateSliceBuffer();
	}
	
	public function set width(value:UInt):void {
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
	
	public function set height(value:UInt):void {
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
	
	public function get y2():Number {
		return y + height;
	}
	
	public function get x2():Number {
		return x + width;
	}
	
	public function get centerX():Number {
		return x + width / 2;
	}
	
	public function get centerY():Number {
		return y + height / 2;
	}

	protected function scaleBitmapData(bitmapData:BitmapData, scaleX:Number, scaleY:Number):BitmapData {
        scaleX = Math.abs(scaleX);
        scaleY = Math.abs(scaleY);
        var width:int = (bitmapData.width * scaleX) || 1;
        var height:int = (bitmapData.height * scaleY) || 1;
        var transparent:Boolean = bitmapData.transparent;
        var result:BitmapData = new BitmapData(width, height, transparent);
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        result.draw(bitmapData, matrix);
        return result;
    }

    protected function convert2dX(i:int, width:UInt):int {
		return i % width;
	}

	protected function convert2dY(i:int, width:UInt):int {
		return Math.floor(i / width);
	}
	
}
