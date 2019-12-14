package sg.map.view.entity {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Handler;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigClass;
	import sg.explore.model.ModelTreasureHunting;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.view.ChangeChengInfo;
	import sg.map.view.MapViewMain;
	import sg.model.ModelCityBuild;
	import sg.model.ModelGame;
	import sg.model.ModelOfficial;
	import sg.scene.SceneMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.InputManager;
	import sg.scene.view.MapCamera;
	import sg.scene.view.MarchPathManager;
	import sg.scene.view.entity.EntityClip;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class ChangChengClip extends EntityClip {
		
		
		public var city:EntityCity;
		
		
		public var grid:MapGrid;
		
		public var bid:String;
		
		public var info:ChangeChengInfo = new ChangeChengInfo();
		
		
		public function ChangChengClip(scene:SceneMain) {
			super(scene);			
		}
		
		override public function init():void {
			super.init();
			this._ani = EffectManager.loadAnimation("map052", '', 0, null, "map");
			this._clip.addChild(this._ani);
			this._clip.x = MapModel.instance.mapGrid.gridHalfW;
			this._clip.y = MapModel.instance.mapGrid.gridHalfH;
			
			this.on(Event.CLICK, this, this.onClick);
			
			this.hitArea = new Rectangle(0, 0, MapModel.instance.mapGrid.gridW, MapModel.instance.mapGrid.gridH);
			this.changeInfo();
			this.city.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeInfo);
			//this.event(EventConstant.UPDATE_BUILD, {cid:np.receiveData.cid, bid:np.receiveData.bid, name:np.receiveData.uname});
			ModelManager.instance.modelGame.on(EventConstant.UPDATE_BUILD, this, this.updateChangeCheng);
			
			this.bid = ModelCityBuild.getChangeChengId(this.city.cityId.toString());			
		}
		
		
		private function updateChangeCheng(o:Object):void {
			if (o.bid == this.bid) {
				this.changeInfo();
			}
		}
		
		private function onHidePathHandler():void {
			for (var i:int = 0, len:int = this.ways.length; i < len; i++) {
				Sprite(this.ways[i]).removeSelf();
			}
		}
		
		private function changeInfo():void {
			this.info.update(this);
		}
		
		override public function event(type:String, data:* = null):Boolean {
			var isClick:Boolean = (type == Event.CLICK);
			if (isClick) {
				if (!InputManager.instance.canClick) return true;
				if (data is Event) {
					Event(data).stopPropagation();
				}
			}
			return super.event(type, data);
		}
		
		private var ways:Array = [];
		
		public function get locked():Boolean {			
			return !this.city.myCountry  || !this.city.isFaith;
		}
		
		
		
		override public function onClick():void {			
			super.onClick();
			var isFirst:Boolean = this.ways.length == 0;
			var cityId:int = this.city.cityId;
			
			var gw:Array = ModelCityBuild.getGreatWall3(cityId.toString());
			//key 是目的地 value 是代表是否解锁。
			
			if (gw) {
				var arr:Array = [];
				for (var j:int = 0, len2:int = gw.length; j < len2; j++) {
					var targetId:String = gw[j].city;
					if (isFirst) {//首次 显示~					
						this.ways = this.ways.concat(MarchPathManager.instance.createPath(cityId, parseInt(targetId), false));
					}
					arr.push({type:targetId, visible:true, city:targetId, lock:gw[j].open, label:EntityCity(MapModel.instance.citys[targetId]).getName(), icon:"ui/home_60.png", gray:!gw[j].open || this.locked, handler:Handler.create(this, function(city:int):void {
						MapCamera.lookAtCity(city, 800);
					}, [targetId])});
				}
				
				MapViewMain.instance.mapLayer.menu.showMenu(this, arr, 120, new Point(this._scene.mapGrid.gridHalfW, this._scene.mapGrid.gridHalfH));
				MapViewMain.instance.mapLayer.menu.cityBar.removeSelf();
				MapViewMain.instance.mapLayer.menu.show();
			}
			
			InputManager.instance.once(Event.CLICK, this, onHidePathHandler);
			
			
			//不是首次的话 有缓存 直接添加就好了。
			if (!isFirst) {
				for (var i:int = 0, len:int = this.ways.length; i < len; i++) {
					MapViewMain.instance.mapLayer.floorLayer.addChildAt(this.ways[i], 0);
				}
			}
		}
		
		override public function show():void {
			super.show();
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			ModelManager.instance.modelGame.off(EventConstant.UPDATE_BUILD, this, this.updateChangeCheng);
			super.destroy(destroyChild);
			this.city.off(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeInfo);
			while (this.ways.length) {
				Tools.destroy(this.ways.shift());
			}
		}
	}

}