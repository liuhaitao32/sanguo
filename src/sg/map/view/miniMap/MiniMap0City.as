package sg.map.view.miniMap {
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.ColorFilter;
	import laya.maths.Point;
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.MapUtils;
	import sg.map.view.MapViewMain;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.entity.EntityClip;
	
	/**
	 * ...
	 * @author light
	 */
	public class MiniMap0City extends Sprite {
		
		private var _entity:EntityCity;
		
		private var _miniMap:MiniMap0;
		
		public function MiniMap0City(entity:EntityCity, miniMap0:MiniMap0) {
			this._entity = entity;
			this._miniMap = miniMap0;
			//this._entity.on
			this._entity.on(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeCity);
			this.changeCity();
			
			this.scale(0.5, 0.5);
			MapUtils.getPos(this._entity.mapGrid.col, this._entity.mapGrid.row, Point.TEMP);			
			var p:Point = this._miniMap.toLocal(Point.TEMP);
			this.x = p.x;
			this.y = p.y;
		}
		
		private function changeCity(e:Boolean = false):void {
			
			this.texture = Laya.loader.getRes("map2/minimap_m0" + Math.min(3, this._entity.country) + ".png");
			this.pivotX = this.texture.width / 2;
			this.pivotY = this.texture.height / 2;
			//this.filters = [new ColorFilter(ConfigServer.world.COUNTRY_COLOR_FILTER_MATRIX[Math.min(3, this._entity.country)])];
		}
		
		override public function destroy(destroyChild:Boolean = true):void {
			super.destroy(destroyChild);
			this._entity.off(EventConstant.CITY_COUNTRY_CHANGE, this, this.changeCity);
		}
		
	}

}