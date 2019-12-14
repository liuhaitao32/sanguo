package sg.map.view {
	import laya.display.Sprite;
	import laya.filters.ColorFilter;
	import sg.cfg.ConfigColor;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.Vector2D;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	import sg.scene.view.CityTileClip;
	
	/**
	 * ...
	 * @author light
	 */
	public class AroundClip extends CityTileClip {
		
		
		public var mapType:String;
		
		private var aroundCitys:Array = [];
		
		
		
		public function AroundClip() {
			
		}
		
		override public function init():void {
			super.init();			
			var aroundDic:Object = AroundManager.instance.aroundData[this.grid.toString2()];
			for (var name:String in aroundDic) {
				if (name == "-99") continue;
				var city2:EntityCity = MapModel.instance.citys[parseInt(name)];
				this.aroundCitys.push(city2);
			}
			
			var v:Vector2D = this.grid.toScreenPos();
			this.pos(v.x, v.y);
		}
		
		public override function show():void {
			MapViewMain.instance.mapLayer.maskLayer.addChild(this);
			this.removeChildren();
			super.show();
			if (this.city && this.city.country < 3) {				
				AroundManager.instance.getGridView(this.grid, this, this.mapType, this.city.country);
				//AroundManager.instance.getGridView(this.grid, this, this.mapType, 2);
			}
			
			for (var i:int = 0, len:int = this.aroundCitys.length; i < len; i++) {
				EntityCity(this.aroundCitys[i]).on(EventConstant.CITY_COUNTRY_CHANGE, this, this.show);
			}
		}
		
		public override function hide():void {
			super.hide();
			for (var i:int = 0, len:int = this.aroundCitys.length; i < len; i++) {
				EntityCity(this.aroundCitys[i]).off(EventConstant.CITY_COUNTRY_CHANGE, this, this.show);
			}
			this.removeSelf();
			//this.removeChildren();
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			this.hide();
			super.destroy(destroyChild);
		}
	}

}