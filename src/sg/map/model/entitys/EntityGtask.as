package sg.map.model.entitys {
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.map.model.MapModel;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.GtaskClip;
	import sg.scene.constant.ConfigConstant;
	/**
	 * ...
	 * @author light
	 */
	public class EntityGtask extends EntityCityTile {
				
		public var modelRes:String = null;
		
		
		public var matrix:Point = new Point();
		
		public var icon:String;
		
		public function EntityGtask(netId:int=-1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
			
			this.mapGrid = MapModel.instance.mapGrid.getGrid(parseInt(ConfigConstant.mapData["city"][this.city.cityId]["monster"].x), parseInt(ConfigConstant.mapData["city"][this.city.cityId]["monster"].y));			
			this.mapGrid.addEntity(this);
			this.modelRes = ConfigServer.gtask["gtask_npc_model"][0];
			this.matrix.x = ConfigServer.gtask["gtask_npc_model"][1];
			this.matrix.y = ConfigServer.gtask["gtask_npc_model"][2];
			
			
			//如果是在外面的大地图 则生成一下。
			if (this.mapGrid.gridSprite && !this.mapGrid.gridSprite.destroyed) {
				var clip:GtaskClip = new GtaskClip(MapViewMain.instance);
				clip.entity = this;
				this.view = clip;
				clip.init();
			}
		}
		
		override public function get type():int {return ConfigConstant.ENTITY_GTASK; }
		
		override public function clear():void {
			super.clear();
			this.mapGrid.removeEntity(this);
		}
	}

}