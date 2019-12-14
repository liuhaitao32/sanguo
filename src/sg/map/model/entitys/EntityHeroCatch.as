package sg.map.model.entitys {
	import sg.cfg.ConfigServer;
	import sg.map.model.MapModel;
	import sg.map.view.MapViewMain;
	import sg.map.view.entity.HeroCatchClip;
	import sg.model.ModelGame;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class EntityHeroCatch extends EntityCityTile {
		
		public var heroId:String;
		private var _enabled:Boolean = false;
		
		public function EntityHeroCatch(netId:int =-1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			
			//if ((this.city && this.city.cityId == data.cityId) && this.heroId == data.heroId) return;			
			
			
			super.initConfig(data);
			
			if (this.mapGrid) {
				this.mapGrid.removeEntity(this);
			}
			
			this.city = MapModel.instance.citys[data.cityId];
			this.heroId = data.heroId;
			
			var heroConfig:* = ConfigServer.hero[this.heroId];
			this.name = Tools.getMsgById(heroConfig.name);
			
			this.mapGrid = MapModel.instance.mapGrid.getGrid(parseInt(ConfigConstant.mapData["city"][this.city.cityId]["heroCatch"].x), parseInt(ConfigConstant.mapData["city"][this.city.cityId]["heroCatch"].y));
			
			this.mapGrid.addEntity(this);
			
			this.enabled = true;
			this.event(EventConstant.HERE_CATCH);
			
			//如果是在外面的大地图 则生成一下。
			if (this.mapGrid.gridSprite && !this.mapGrid.gridSprite.destroyed && !this.view) {
				var clip:HeroCatchClip = new HeroCatchClip(MapViewMain.instance);
				clip.entity = this;
				this.view = clip;
				clip.init();
			}
		}
		
		private function onCompleteHandler():void {
			this.enabled = false;
		}
		
		
		public function get countDown():Number {
			var now:Number=ConfigServer.getServerTimer();
			var dt:Date=new Date(now);
			var m:Number = 60 * 60 * 1000 - (dt.getMinutes() * 60 * 1000 + dt.getSeconds() * 1000 + dt.getMilliseconds());	
			return m;
		}
	
		
		override public function get type():int {
			return ConfigConstant.ENTITY_HERO_CATCH;
		}
		
		public function get enabled():Boolean {
			return this._enabled && ModelGame.unlock(null, "catch_hero").visible;
		}
		
		public function set enabled(value:Boolean):void {			
			if (this._enabled == value) return;
			this._enabled = value;
			if (!value) {
				Laya.timer.clear(this, this.onCompleteHandler);
			} else {				
				Laya.timer.once(this.countDown, this, this.onCompleteHandler);
			}
		}
	}

}