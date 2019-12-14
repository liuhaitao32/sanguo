package sg.map.utils {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.html.dom.HTMLDivElement;
	import laya.maths.Point;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.map.model.MapModel;
	import sg.map.view.MapViewMain;
	import sg.scene.model.MapGrid;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	/**
	 * ...
	 * @author light
	 */
	public class MapUtils {
		
		/**
		 * 游戏里45度角 转 ISO坐标。
		 * @param	v
		 * @return
		 */
		public static function tileToIso(v:Vector2D, result:Vector2D = null):Vector2D {
			var x1:Number = v.x;
			var y1:Number = v.x;
			
			var x2:Number = -parseInt((v.y / 2).toString());
			var y2:Number = ((v.y % 2) == 1 ? 1 : 0) + parseInt((v.y / 2).toString());
			result ||= new Vector2D();
			result.setXY(y1 + y2, -(x1 + x2));
			return result;;
		}
		
		/**
		 * IOS坐标转游戏里坐标。
		 * @param	v
		 * @return
		 */
		public static function isoToTile(v:Vector2D, result:Vector2D = null):Vector2D {
			var y1:Number = v.x + v.y;
			var x1:Number = Math.floor((y1 / 2)) - v.y;
			result ||= new Vector2D();
			result.setXY(x1, y1)
			return result;
		}
		public static const AROUND_STR:Array = ["up", "right", "down", "left"];
		public static const LEFT_TOP:String = "-1_-1";
		public static const TOP:String = "0_-1";
		public static const RIGHT_TOP:String = "1_-1";		
		public static const LEFT:String = "-1_0";
		public static const CENTER:String = "0_0";
		public static const RIGHT:String = "1_0";		
		public static const LEFT_BOTTOM:String = "-1_1";
		public static const BOTTOM:String = "0_1";
		public static const RIGHT_BOTTOM:String = "1_1";
		public static const AROUND:Array = [LEFT_TOP, TOP, RIGHT_TOP, LEFT, RIGHT, LEFT_BOTTOM, BOTTOM, RIGHT_BOTTOM];
		public static const AROUND_4:Array = [TOP, RIGHT, BOTTOM, LEFT];
		
		public static const AROUND_VECTOR_4:Array = [Vector2D.TOP, Vector2D.RIGHT, Vector2D.BOTTOM, Vector2D.LEFT];
		
		
		public static function getAround(center:Array, offset:String):Array {
			var b:Boolean = center[1] % 2 == 0;
			var key:String = b ? "k1" : "k2";
			
			if (!grids[key]) {
				grids[key] = {};
				var arr:Array = [LEFT_TOP, TOP, RIGHT_TOP, LEFT, CENTER, RIGHT, LEFT_BOTTOM, BOTTOM, RIGHT_BOTTOM];
			
				var start:Array = [0, -2];
				for (var i:int = 0; i < 3; i++) {
					var yy:int = start[1] + i;
					var xx:int = start[0] - ((yy + (b ? 0 : 1)) % 2 != 0 ? Math.ceil(i / 2) : Math.floor(i / 2));
					for (var j:int = 0; j < 3; j++) {
						var y:Number = yy + j;
						var x:Number = xx + ((y  + (b ? 0 : 1)) % 2 == 0 ? Math.ceil(j / 2) : Math.floor(j / 2));
						grids[key][arr.shift()] = [x, y];
					}
				}
			}
			
			return grids[key][offset];
		}
		
		public static var grids:Array = [];
		
		
		private static var _aroundHypotenuse:Array = [];
		
		public static function getAroundHypotenuse(dir:int):Vector2D {
			if (!_aroundHypotenuse[dir]) {
				//重新计算下。 在左上角。
				var v1:Vector2D = new Vector2D();
				MapUtils.getPos(0, 0, Point.TEMP);
				v1.setTempPoint();
				
				var v2:Vector2D = new Vector2D();
				v2 = MapUtils.isoToTile(MapUtils.AROUND_VECTOR_4[dir], v2);					
				MapUtils.getPos(v2.x, v2.y, Point.TEMP);
				v2.setTempPoint();					
				var v3:Vector2D = v2.clone().subtract(v1);
				_aroundHypotenuse[dir] = v3;
				
			}
			return _aroundHypotenuse[dir].clone();
			
		}
		
		public static function getOccupyGrid(scale:Number, center:Array):Array {
			scale = Math.ceil(scale);
			if (scale % 2 == 0) scale += 1;
			
			var b:Boolean = center[1] % 2 == 0;
			var key:int = b ? scale : scale - 1;
			var result:Array = grids[key];
			if (!result) {
				result = [];
				grids[key] = result;				
				var start:Array = [0, 0 - (scale - 1)];
				for (var i:int = 0; i < scale; i++) {
					var yy:int = start[1] + i;
					var xx:int = start[0] - ((yy + (b ? 0 : 1)) % 2 != 0 ? Math.ceil(i / 2) : Math.floor(i / 2));
					for (var j:int = 0; j < scale; j++) {
						var y:Number = yy + j;
						var x:Number = xx + ((y  + (b ? 0 : 1)) % 2 == 0 ? Math.ceil(j / 2) : Math.floor(j / 2));
						result.push([x, y]);
					}
				}
				
			}
			return result;
			
		}
		
		public static function changeDir(ani:Animation, dir:int):void {
			var scaleFlag:Boolean = ArrayUtils.contains(dir, [0, 1]);
			var dirFlag:Boolean = ArrayUtils.contains(dir, [0, 3]);
			ani.play(0, true, dirFlag ? "up" : "down");
			ani.scaleX = scaleFlag ? Math.abs(ani.scaleX) : -Math.abs(ani.scaleX);
		}
		
		public static function getGridDir(grid1:MapGrid, grid2:MapGrid):int {
			var v1:Vector2D = Vector2D.createVector(grid1.col, grid1.row);
			Vector2D.TEMP.setXY(grid2.col, grid2.row);
			tileToIso(v1, v1);
			tileToIso(Vector2D.TEMP, Vector2D.TEMP);
			
			Vector2D.TEMP.subtract(v1);
			
			for (var i:int = 0, len:int = 4; i < len; i++) {
				if (Vector2D.TEMP.equals(AROUND_VECTOR_4[i])) return i;
			}
			
			return -1;
			
		}
		
		public static function getPos(col:Number, row:Number, result:Point = null):Point {
			result ||= Point.TEMP;
			result.setTo(col * MapModel.instance.mapGrid.gridW + (row & 1) * MapModel.instance.mapGrid.gridHalfW, row * MapModel.instance.mapGrid.gridHalfH);
			return result;
		}
	}

}