package ext.com.haxepunk;

import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.atlas.AtlasRegion;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import com.haxepunk.utils.Draw;

class NineSlice extends Graphic
{

        public var width:Float;
        public var height:Float;

        public function new(width:Float, height:Float, ?clipRect:Rectangle, ?skin:AtlasRegion)
        {
                super();
                this.width = width;
                this.height = height;

                // _skin = (skin != null) ? skin : Control.currentSkin;
                _skin = skin;

                if (clipRect == null) clipRect = new Rectangle(0, 0, 1, 1);
                _clipRect = clipRect;
                _showTopRow = true;

                var rect = clipRect.clone();

                _topLeft = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width;
                _topCenter = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width * 2;
                rect.y = clipRect.y;
                _topRight = _skin.clip(rect);

                rect.x = clipRect.x;
                rect.y = clipRect.y + clipRect.height;
                _centerLeft = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width;
                rect.y = clipRect.y + clipRect.height;
                _centerCenter = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width * 2;
                rect.y = clipRect.y + clipRect.height;
                _centerRight = _skin.clip(rect);

                rect.x = clipRect.x;
                rect.y = clipRect.y + clipRect.height * 2;
                _bottomLeft = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width;
                rect.y = clipRect.y + clipRect.height * 2;
                _bottomCenter = _skin.clip(rect);

                rect.x = clipRect.x + clipRect.width * 2;
                rect.y = clipRect.y + clipRect.height * 2;
                _bottomRight = _skin.clip(rect);
        }

        override public function render(target:BitmapData, point:Point, camera:Point)
        {
                // determine drawing location
                _point.x = point.x + x - camera.x * scrollX;
                _point.y = point.y + y - camera.y * scrollY;

                var xScale = (width - _clipRect.width * 2) / _clipRect.width;
                var yScale = (height - _clipRect.height * 2) / _clipRect.height;
                var sx = HXP.screen.fullScaleX;
                var sy = HXP.screen.fullScaleY;

                // width and height
                var hw = _clipRect.width;
                var hh = _clipRect.height;
                // scaled width and height
                var hsw = (_clipRect.width + (xScale * _clipRect.width));
                var hsh = (_clipRect.height + (yScale * _clipRect.height));

                if (_showTopRow)
                {
                        _topLeft.draw(_point.x * sx, _point.y * sy, layer, sx, sy);
                        _topCenter.draw((_point.x + hw) * sx, _point.y * sy, layer, sx * xScale, sy);
                        _topRight.draw((_point.x + hsw) * sx, _point.y * sy, layer, sx, sy);
                }

                _centerLeft.draw(_point.x * sx, (_point.y + hh) * sy, layer, sx, yScale * sy);
                _centerCenter.draw((_point.x + hw) * sx, (_point.y + hh) * sy, layer, xScale * sx, yScale * sy);
                _centerRight.draw((_point.x + hsw) * sx, (_point.y + hh) * sy, layer, sx, yScale * sy);

                _bottomLeft.draw(_point.x * sx, (_point.y + hsh) * sy, layer, sx, sy);
                _bottomCenter.draw((_point.x + hw) * sx, (_point.y + hsh) * sy, layer, xScale * sx, sy);
                _bottomRight.draw((_point.x + hsw) * sx, (_point.y + hsh) * sy, layer, sx, sy);

                // _skin.draw(0, 0, layer, 1, 1);
                Draw.rectPlus(0, 0, cast width, cast height, 0xff00ff, 1, false);
        }

        public function hideTop()
        {
                _showTopRow = false;
        }

        private var _clipRect:Rectangle;
        private var _skin:AtlasRegion;
        private var _showTopRow:Bool;

        private var _topLeft:AtlasRegion;
        private var _topCenter:AtlasRegion;
        private var _topRight:AtlasRegion;
        private var _centerLeft:AtlasRegion;
        private var _centerCenter:AtlasRegion;
        private var _centerRight:AtlasRegion;
        private var _bottomLeft:AtlasRegion;
        private var _bottomCenter:AtlasRegion;
        private var _bottomRight:AtlasRegion;
}