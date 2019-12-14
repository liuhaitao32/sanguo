package sg.scene.view {
	import laya.renders.RenderContext;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.view.IsoObject;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	import sg.scene.model.MapGrid;
	
	/**
	 * ...
	 * @author light
	 */
	public class CityTileClip extends IsoObject {
		
		public var city:EntityCity;
		
		
		public var rate:Number = 1;
		
		
		public var fillColor:String;
		
		
		public var grid:MapGrid;
		
		
		
		public function CityTileClip() {
			super();
			
		}
		
		
		override public function init():void {
			super.init();			
			this.city = grid.getEntitysByType(ConfigConstant.ENTITY_CITY, "occupyEntitys")[0];
			
		}
		
		public function show():void {
			if (this.city) {
				this.city.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.show);
			} else {
				//Trace.log(this.grid.toString2(), "没有边缘");
			}
		}
		
		public function hide():void {
			if (this.city) {
				this.city.off(EventConstant.CITY_COUNTRY_CHANGE, this, this.show);
			}
		}
		
	}

}