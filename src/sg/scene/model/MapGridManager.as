package sg.scene.model {
	import laya.map.MapLayer;
	import laya.map.TiledMap;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.view.EventLayer;
	import sg.map.model.astar.AStarFind;
	import sg.map.model.astar.AStarGrid;
	import sg.map.model.astar.AstarNode;
	import sg.scene.model.MapGrid;
	import sg.map.model.MapModel;
	/**
	 * 地图格子的管理。
	 * @author light
	 */
	public class MapGridManager {
		
		public var astarFind:AStarFind = new AStarFind();
		
		public var astarGrid:AStarGrid = new AStarGrid();		
		
		/**
		 * 二维的格子 里面存储的是Grid的对象。
		 */
		public var grids:Array = [];
				
		public var rows:int;
		public var cols:int;
		public var gridW:int;
		public var gridH:int;
		
		public var gridHalfW:Number;
		public var gridHalfH:Number;
		public var width:int;
		public var height:int;
		
		public var hypotenuse:Number;
		public var halfhypotenuse:Number;
		
		public var hypotenuseV:Vector2D;
		
		
		public function MapGridManager() {
			
		}
		
		public function init(cols:int, rows:int, gridW:int, gridH:int, orientation:String):void {			
			this.cols = cols;
			this.rows = rows;
			
			this.gridW = gridW;
			this.gridH =gridH;
			
			this.gridHalfW = this.gridW * 0.5;
			this.gridHalfH = this.gridH * 0.5;
			
			this.width = this.cols * this.gridW;		
			
			if (orientation == TiledMap.ORIENTATION_STAGGERED) {
				this.height = (0.5 + this.rows * 0.5) * this.gridH;
				this.hypotenuse = Math.sqrt(Math.pow(this.gridW / 2, 2) + Math.pow(this.gridH / 2, 2));
				this.halfhypotenuse = this.hypotenuse * 0.5;
				
			}else{
				this.height = this.rows * this.gridH;
			}
			this.hypotenuseV = new Vector2D(this.gridW, 0).add(new Vector2D(0, this.gridH));
			this.hypotenuseV.normalize().length = this.hypotenuse;
			
			this.grids = [];
			
			if(ConfigConstant.isEdit) {
				this.initEditAstar();
			} else {
				this.initGrid();
			}
			
		}
		
		/**
		 * 正常模式下初始化格子。
		 */
		private function initGrid():void {
			for (var i:int = 0, len:int = this.rows; i < len; i++) {
				for (var j:int = 0, len2:int = this.cols; j < len2; j++) {
					this.setGrid(j, i);
				}
			}
		}
		
		/**
		 * 编辑模式下
		 */
		private function initEditAstar():void{
			this.astarFind.initAStar(this.astarGrid);
			//先横着 
			var index1:int = 1;
			var index2:int = 0;
			for (var i:int = 0, len:int = this.rows; i < len; i++) {
				
				if (i % 2 == 0) index1--;
				else index2++;
				
				for (var j:int = 0, len2:int = this.cols; j < len2; j++) {
					var node:AstarNode = this.astarGrid.setNode(index1 + j, index2 + j);
					var grid:MapGrid = this.setGrid(j, i);
					grid.node = node;
					node.grid = grid;
				}
			}
		}
		
		
		public function setGrid(col:int, row:int):MapGrid {
			if (this.grids[col] == null) this.grids[col] = [];
			if (this.grids[col][row] == null) {
				var grid:MapGrid = new MapGrid(col, row);
				this.grids[col][row] = grid;
			}else {
				//trace("重复设置格子信息", col, row);
			}
			return this.grids[col][row];
		}
		
		public function getGrid(col:int, row:int):MapGrid {
			if (this.grids[col] != null && this.grids[col][row] != null) return this.grids[col][row] as MapGrid;
			return null;
		}
		
		
		/**lichuang修改**/  
		public function getGridByPos(screenX:Number, screenY:Number):Vector2D {
			var result:Vector2D = new Vector2D();
			var tTileW:int = this.gridW;
			var tTileH:int = this.gridH;
			
			var tV:Number = 0;
			var tU:Number = 0;			
			var cx:int, cy:int, rx:int, ry:int;
			cx = Math.floor(screenX / tTileW) * tTileW + tTileW / 2;        //计算出当前X所在的以tileWidth为宽的矩形的中心的X坐标
			cy = Math.floor(screenY / tTileH) * tTileH + tTileH / 2;//计算出当前Y所在的以tileHeight为高的矩形的中心的Y坐标
			
			rx = (screenX - cx) * tTileH / 2;
			ry = (screenY - cy) * tTileW / 2;
			
			if (Math.abs(rx) + Math.abs(ry) <= tTileW * tTileH / 4) {
				tU = Math.floor(screenX / tTileW);
				tV = Math.floor(screenY / tTileH) * 2;
			} else {
				screenX = screenX - tTileW / 2;
				tU = Math.floor(screenX / tTileW) + 1;
				screenY = screenY - tTileH / 2;
				tV = Math.floor(screenY / tTileH) * 2 + 1;
			}
			result.x = tU - (tV & 1);
			result.y = tV;
			
			return result;
		}
		
	}

}