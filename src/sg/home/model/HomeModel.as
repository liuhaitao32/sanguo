package sg.home.model {
	import sg.cfg.ConfigServer;
	import sg.home.model.entitys.EntityBuild;
	import sg.model.ModelBase;
	import sg.scene.constant.ConfigConstant;
	import sg.scene.model.MapGridManager;
	
	public class HomeModel extends ModelBase {

		
		public var mapGrid:MapGridManager = new MapGridManager();
		
		public static var instance:HomeModel;
		
		public var builds:* = {};
		
		
		public function HomeModel() {
			instance = this;
		}	
		
		


		public function initHome():void {
			this.builds = {};
			var tJsonData:* = ConfigConstant.homeConfigData;
			this.mapGrid.init(tJsonData.width, tJsonData.height, tJsonData.tilewidth, tJsonData.tileheight, tJsonData.orientation);
			
			for (var name:String in ConfigServer.home) {
				var build:EntityBuild = new EntityBuild();
				build.id = name;
				build.initConfig(ConfigServer.home[name]);
				this.builds[name] = build;
			}
			
			
			
		}
		
		
		//public function getCitys(params:Object):Array {
			//var result:Array = [];
			//for (var cityId:String in this.citys) {				
				//var entity:EntityCity = this.citys[cityId];
				//for (var name:String in params) {
					//if(entity[name] == params[name]){
						//result.push(entity);
					//}
				//}
			//}
			//return result;
		//}
		
		
		private function parseData(receiveData:Object):void {
			var cityDatas:Object = receiveData.cities;
			
			
		}
		


	}
}