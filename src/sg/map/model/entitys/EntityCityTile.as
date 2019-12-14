package sg.map.model.entitys {
	import sg.cfg.ConfigServer;
	import sg.map.model.MapModel;
	import sg.scene.model.MapGrid;
	import sg.scene.model.entitys.EntityBase;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author light
	 */
	public class EntityCityTile extends EntityBase {
		
		public var city:EntityCity;
		
		
		public function EntityCityTile(netId:int=-1) {
			super(netId);			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);		
		}
		
		override public function getData():Object {
			return {x:this.x, y:this.y};
		}
		
	}

}