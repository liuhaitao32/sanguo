package sg.map.view.miniMap {
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.resource.Texture;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigAssets;
	import sg.cfg.ConfigClass;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.utils.MapUtils;
	import sg.map.utils.TestUtils;
	import sg.map.view.AroundClip;
	import sg.map.view.AroundManager;
	import sg.map.view.MapViewMain;
	import sg.outline.view.OutlineViewMain;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.CityTileClip;
	import sg.utils.Tools;
	import ui.mapScene.MiniMap0UI;
	import sg.cfg.ConfigServer;
	
	/**
	 * ...
	 * @author light
	 */
	public class MiniMap0 extends MiniMap0UI {
		
		private var _rate:Number;	
		
		private var _occupy:Sprite = new Sprite();
		
		private var _occupyTexture:Object = {0:Laya.loader.getRes("map2/mblue.png"), 1:Laya.loader.getRes("map2/mgreen.png"), 2:Laya.loader.getRes("map2/mred.png")};
		
		private var _cityOccupy:Object = {};
		
		private var fireDic:Object = {};	
		
		private var _effect:Sprite = new Sprite();
		
		public function MiniMap0() {			
			this._rate = this.bg_img.width / MapModel.instance.mapGrid.width;
			
			//this._occupy.visible = false;
			this.on(Event.CLICK, this, function():void {				
				ViewManager.instance.showView(ConfigApp.isPC ? ConfigClass.MINI_MAPTOP2 : ConfigClass.MINI_MAPTOP);
			});
		}
		
		
		
		public function onScaleHandler(e:Event = null):void {
			var sc:Number = MapViewMain.instance.tMap.scale;
			var p:Point = this.toLocal(new Point(Laya.stage.width / sc, Laya.stage.height / sc));
			this.rect_img.size(p.x, p.y);			
			this.changeMove()
		}
		
		public function changeMove(e:Event = null):void {
			Point.TEMP.setTo(-MapViewMain.instance.tMap.viewPortX, -MapViewMain.instance.tMap.viewPortY);
			var p:Point = this.toLocal(Point.TEMP);
			this.rect_img.x = p.x;
			this.rect_img.y = p.y;
		}
		
		public override function init():void {
			var arr:Array = [4, 5, 9];
			TestUtils.timeStart("drawRect");
			var this2:MiniMap0 = this;
			//TODO:这里fun不用了 用handler好一点。
			var citys:Array = MapModel.instance.getFilterCitys(function(entity:EntityCity):Boolean{				
				entity.on(EventConstant.CITY_COUNTRY_CHANGE, this2, updateOccupy);
				entity.on(EventConstant.CITY_FIRE, this2, onFireHandler);
				onFireHandler(entity);
				return ArrayUtils.contains(entity.cityType, arr);
			});
			this.updateOccupy();
			TestUtils.getRumTime("drawRect");
			this.addChild(this._occupy);
			this._occupy.cacheAsBitmap = true;
			for (var i:int = 0, len:int = citys.length; i < len; i++) {
				var city:MiniMap0City = new MiniMap0City(citys[i], this);
				this.addChild(city);
			}
			this.addChild(this._effect);
			this.addChild(this.rect_img);
			MapViewMain.instance.on(EventConstant.SCALE_CHANGE, this, this.onScaleHandler);
			MapViewMain.instance.on(EventConstant.MOVE_CHANGE, this, this.changeMove);
			this.onScaleHandler();
			
			
		}
		
		
		private function onFireHandler(city:EntityCity):void {
			if (city.fire) {
				var bu:Animation = EffectManager.loadAnimation("smap_battle");
				
				MapUtils.getPos(city.mapGrid.col, city.mapGrid.row, Point.TEMP);			
				var p:Point = this.toLocal(Point.TEMP);
				bu.x = p.x;
				bu.y = p.y;
				
				this.fireDic[city.cityId] = bu;
				this._effect.addChild(bu);
			} else {
				if (this.fireDic[city.cityId]) {
					Tools.destroy(this.fireDic[city.cityId])
					delete this.fireDic[city.cityId];
				}
			}			
		}
		
		
		private function updateOccupy():void {
			this._occupy.removeChildren();
			
			var fillContent:Sprite = new Sprite();
			var river:Sprite = new Sprite();
			var lineContent:Sprite = new Sprite();
			
			
			this._occupy.addChild(fillContent);
			this._occupy.addChild(river);
			river.texture = Laya.loader.getRes("map2/minimap_04.png");
			this._occupy.addChild(lineContent);
			AroundManager.instance.fillMiniMap([fillContent, lineContent], this._rate, false, [ConfigServer.world.COUNTRY_MAP_LIGHT_COLORS, ConfigServer.world.COUNTRY_MAP_COLORS]);
		}
		
		
		public function toGlobal(p:Point, result:Point = null):Point {
			result ||= Point.TEMP;
			result.x = p.x / this._rate;
			result.y = p.y / this._rate;
			return result;
		}
		
		public function toLocal(p:Point, result:Point = null):Point {
			result ||= Point.TEMP;
			result.x = p.x * this._rate;
			result.y = p.y * this._rate;
			return result;
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			for (var name:String in MapModel.instance.citys) {
				EntityCity(MapModel.instance.citys[name]).off(EventConstant.CITY_COUNTRY_CHANGE, this, this.updateOccupy);
				EntityCity(MapModel.instance.citys[name]).off(EventConstant.CITY_FIRE, this, this.onFireHandler);
			}		
			
			MapViewMain.instance.off(EventConstant.SCALE_CHANGE, this, this.onScaleHandler);
			MapViewMain.instance.off(EventConstant.MOVE_CHANGE, this, this.changeMove);
		}
		
	}

}