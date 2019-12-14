package sg.scene.constant {
	import sg.cfg.ConfigServer;
	import sg.map.utils.TestUtils;
	/**
	 * ...
	 * @author light
	 */
	public class ConfigConstant {
		
		//public static const GRID_DIST:Number = 0
		
		public static var ENTITY_CITY:int = 100;
		public static var ENTITY_ESTATE:int = 101;
		public static var ENTITY_HERO_CATCH:int = 102;
		public static var ENTITY_MONSTER:int = 103;
		public static var ENTITY_FTASK:int = 104;
		public static var ENTITY_GTASK:int = 105;
		public static var ENTITY_GREAT_WALL:int = 106;
		public static var ENTITY_XIAN_HE:int = 107;
		public static var ENTITY_CHANG_CHENG:int = 108;
		public static var ENTITY_ARENA:int = 109;
		public static var ENTITY_BUILD:int = 200;
		
		
		public static var WAY_DIST_UNIT:int = 10000;
		
		
		public static var isEdit:Boolean = false;
		
		public static const CITY_TYPE_FORT:int		= 0; // 要塞
		public static const CITY_TYPE_TOWN:int 		= 1; // 县城
		public static const CITY_TYPE_CITY_S:int	= 2; // 郡城
		public static const CITY_TYPE_CITY_M:int	= 3; // 关城
		public static const CITY_TYPE_CITY_L:int	= 4; // 都城
		public static const CITY_TYPE_CAPITAL:int 	= 5; // 首都
		public static const CITY_TYPE_CAMP:int 		= 7; // 战阵
		public static const CITY_TYPE_GATE:int 		= 8; // 城门
		public static const CITY_TYPE_DEST:int 		= 9; // 襄阳（目的地）
		
		public static var SPEED_MARCH:Number = 100.0;
		
		public static function init():void {
			ConfigConstant.mapData = Laya.loader.getRes("map/mapData.json");
			ConfigConstant.mapConfigData = Laya.loader.getRes("map/map.json");
			ConfigConstant.homeConfigData = Laya.loader.getRes("home/home.json");
			
			ConfigConstant.SPEED_MARCH = ConfigServer.world["marchSpeedBase"];
			ConfigConstant.WAY_DIST_UNIT = ConfigServer.world["mapPathDis"];
			if(TestUtils.isTestShow == -1)
				TestUtils.isTestShow = ConfigServer.system_simple["is_map_test"];
		}
		
		//地图配置
		public static var mapData:Object = null;
		
		//编辑器 导出的地图配置。
		public static var mapConfigData:Object = null;
		public static var homeConfigData:Object = null;
		
		
		
	}
	
	

}