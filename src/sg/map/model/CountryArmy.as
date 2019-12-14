package sg.map.model {
	import laya.events.EventDispatcher;
	import sg.cfg.ConfigServer;
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.ArrayUtils;
	import sg.map.view.entity.CityClip;
	
	/**
	 * 
	 * @author light
	 */
	public class CountryArmy extends EventDispatcher {
		
		public static var map:Object = {};
		
		public var id:String;
		
		public var index:int;
		
		public var targetCity:EntityCity;
		
		public var country:int = -1;
		
		public function CountryArmy() {
			
		}
		
		public function init(data:Object):void {
			this.index = data.car_type;
			
			this.country = data.country;
			var targetCitys:Array = ConfigServer.country_army[this.country]["target_city"][this.index];
			this.targetCity = MapModel.instance.citys[targetCitys[targetCitys.length - 1]];
			this.id = data.uid;
			ArrayUtils.push(this, this.targetCity.countryArms);
			map[this.id] = this;
			if (this.targetCity.view && !this.targetCity.view.destroyed) {
				CityClip(this.targetCity.view).setCityUI();
			}
		}
		
		public function destroy():void {
			ArrayUtils.remove(this, this.targetCity.countryArms);			
			delete map[this.id];
			if (this.targetCity.view && !this.targetCity.view.destroyed) {
				CityClip(this.targetCity.view).setCityUI();
			}
		}
		
		
		
	}

}