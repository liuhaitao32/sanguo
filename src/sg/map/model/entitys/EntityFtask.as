package sg.map.model.entitys {
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.map.model.MapModel;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.FtaskClip;
	import sg.model.ModelFTask;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.MapGrid;
	import sg.utils.Tools;
	/**
	 * 民情
	 * @author light
	 */
	public class EntityFtask extends EntityCityTile {
		
		public var ftask:ModelFTask;
		
		
		public var modelRes:String = null;
		
		
		public var matrix:Point = new Point();
		
		public var occupyGrids:Array = [];
		
		public var task_type:int = -1;
		/**
		 * 难度
		 */
		public var mode:int = 0;
		
		public function EntityFtask(netId:int =-1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
			this.ftask = data;
			this._data = ConfigServer.ftask["people_task"][this.ftask.task_id];
			
			this.task_type = parseInt(this._data["type"]);
			
			if (this.task_type == 1) {				
				this.mode = this.ftask.showObj.lv;
				//放到左上角。
				var d:int = parseInt((Math.ceil(this.city.size / 2)).toString());
				
				var v:Vector2D = MapUtils.tileToIso(Vector2D.TEMP.setXY(this.city.mapGrid.col, this.city.mapGrid.row), Vector2D.TEMP);
				
				v.x -= d;	
				v = MapUtils.isoToTile(v, Vector2D.TEMP);
				this.width = MapModel.instance.mapGrid.gridW;
				this.height = MapModel.instance.mapGrid.gridH;
				this.mapGrid = MapModel.instance.mapGrid.getGrid(v.x, v.y);
				this.mapGrid.addEntity(this);
				
				
				var occupys:Array = MapUtils.getOccupyGrid(1.5, [v.x, v.y]);
				for (var i:int = 0, len:int = occupys.length; i < len; i++) {
					var grid:MapGrid = MapModel.instance.mapGrid.getGrid(this.mapGrid.col + occupys[i][0], this.mapGrid.row + occupys[i][1]);
					grid.addClickEntity(this);
					this.occupyGrids.push(grid);
				}
				
				//[斥候名字，斥候模型名字,方阵2*2]
				
				
			} else {
				this.mapGrid = MapModel.instance.mapGrid.getGrid(parseInt(ConfigConstant.mapData["city"][this.city.cityId]["monster"].x), parseInt(ConfigConstant.mapData["city"][this.city.cityId]["monster"].y));			
				this.mapGrid.addEntity(this);
				this.mapGrid.addClickEntity(this);
				this.occupyGrids.push(this.mapGrid);
				MapUtils.getPos(this.mapGrid.col, this.mapGrid.row);
				this.x = Point.TEMP.x;
				this.y = Point.TEMP.y;
			}
			this.width = MapModel.instance.mapGrid.gridW;
			this.height = MapModel.instance.mapGrid.gridH;
			var task_armymatrix:Array = this._data["task_armymatrix"][this.mode];
				
				
			this.name = Tools.getMsgById(this._data["task_npc_name"]);
			this.modelRes = task_armymatrix[0];
			this.matrix.setTo(task_armymatrix[1], task_armymatrix[2]);
			
			
			
			//如果是在外面的大地图 则生成一下。
			if (this.mapGrid.gridSprite && !this.mapGrid.gridSprite.destroyed) {
				var clip:FtaskClip = new FtaskClip(MapViewMain.instance);
				clip.entity = this;
				this.view = clip;
				clip.init();
			}
			
			
		}
		
		override public function get type():int {
			return ConfigConstant.ENTITY_FTASK;
		}
			
		override public function clear():void {			
			for (var i:int = 0, len:int = this.occupyGrids.length; i < len; i++) {
				MapGrid(this.occupyGrids[i]).removeOccupyEntity(this);
			}
			this.mapGrid.removeEntity(this);
			super.clear();
		}
		
		
	}
	
	

}