package sg.map.model.entitys {
	import sg.scene.constant.ConfigConstant;
	import sg.scene.constant.EventConstant;
	
	/**
	 * ...
	 * @author light
	 */
	public class EntityGreatWall extends EntityCityTile {
				
		public function EntityGreatWall(netId:int =-1) {
			super(netId);
			
		}
		
		override public function initConfig(data:* = null):void {
			super.initConfig(data);
		}
		
		
		override public function get type():int {
			return ConfigConstant.ENTITY_GREAT_WALL;
		}
		
	}

}