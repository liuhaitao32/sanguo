package sg.map.model.entitys {
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.utils.MapUtils;
	import sg.map.utils.Vector2D;
	import sg.map.view.MapViewMain;
	import sg.map.view.MonsterInfo;
	import sg.map.view.entity.MonsterClip;
	import sg.model.ModelClimb;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.entity.EntityClip;
	import sg.scene.view.ui.Bubble;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	
	/**
	 * 异族入侵。
	 * @author light
	 */
	public class EntityMonster extends EntityCityTile {
		
		/**
		 * 0闲置，
		 */
		public var state:int = 0;
		
		public var modelRes:String = null;
		
		public var climb:ModelClimb;
		
		public var matrix:Point = new Point();
		
		public var occupyGrids:Array = [];
		
		
		public function EntityMonster(netId:int =-1) {
			super(netId);
			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
			
			this.climb = data;
			this.city = MapModel.instance.citys[parseInt(this.climb.cityId)];
			
			
			//放到左上角。
			var d:int = parseInt((Math.ceil(this.city.size / 2)).toString());
			
			var v:Vector2D = MapUtils.tileToIso(Vector2D.TEMP.setXY(this.city.mapGrid.col, this.city.mapGrid.row), Vector2D.TEMP);
			//左上角。站一个格子。
			if (this.climb.isCaptain()) {
				v.y -= d;
			} else {
				v.x -= d;
			}			
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
			
			
			
			//this.event(Event.CHANGE);
			if (this.climb.isCaptain()) { // 名将来袭
				this._data = ConfigServer.pk_npc["captain_show"];
				var heroId:String = this.climb.captain_hero();
				this.name = Tools.getMsgById(ConfigServer.pk_npc["captain_nameandrew"][heroId][0]);
				this.modelRes = this._data[0];
				this.matrix.setTo(this._data[1], this._data[2]);
			} else { // 异族入侵
				var mode:int = this.climb.pk_npc_diff();//难度
				this._data = ConfigServer.pk_npc["alien_diff"][ModelUser.getCountryID()][mode];
				//[斥候名字，斥候模型名字,方阵2*2]
				this.name = Tools.getMsgById(this._data[0]);
				this.modelRes = this._data[1];
				this.matrix.setTo(this._data[2], this._data[3]);
			}
			
			this.climb.on(ModelClimb.EVENT_PK_NPC_VIEW_UPDATE, this, this.checkUpdate);		
			
			
			//如果是在外面的大地图 则生成一下。
			if (this.mapGrid.gridSprite && !this.mapGrid.gridSprite.destroyed) {
				var clip:MonsterClip = new MonsterClip(MapViewMain.instance);
				clip.entity = this;
				this.view = clip;
				clip.init();
			}
		}
		
		private function checkUpdate(v:int):void {
			if (v == 0) {
				this.clear();
			}
		}
		
		override public function clear():void {			
			for (var i:int = 0, len:int = this.occupyGrids.length; i < len; i++) {
				MapGrid(this.occupyGrids[i]).removeOccupyEntity(this);
			}
			this.mapGrid.removeEntity(this);
			delete MapModel.instance.monsters[this.climb.pk_npc_id];
			super.clear();
		}
		
		
		
		override public function get type():int {
			return ConfigConstant.ENTITY_MONSTER;
		}
		
	}

}