package sg.map.utils {
	import avmplus.variableXml;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.model.ModelBuiding;
	import sg.model.ModelCityBuild;
	import sg.model.ModelHero;
	import sg.model.ModelScience;
	import sg.scene.constant.ConfigConstant;
	/**
	 * 逻辑计算的类。
	 * @author light
	 */
	public class LogicOperation {
		
		public function LogicOperation() {
			
		}
		
		
		public static function abx(a:Number, b:Number, x:Number):Number {
			return a * x + b; 			
		}
		
		public static function armyGo(hid:String):Number {
			var modelHero:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
			//首都建筑等级。
			var key:String = ConfigServer.city_build["army_go"];
			var lv:int = ModelCityBuild.getBuildLv(MapModel.instance.getCapital(ModelManager.instance.modelUser.country).cityId.toString(), ConfigServer.city_build["army_go"]);
			var value:Number = (lv == 0 ? 0 : ConfigServer.city_build["buildall"][key]["effect"][lv - 1][0]);
			//装备
			var equipValue:Number = modelHero.getAllEquipArmyGo();
			//英雄技能
			var skillLv:int = modelHero.getMySkills()["skill282"] || 0;
			var skillValue:Number = (skillLv ? abx(ConfigServer.skill["skill282"]["army_go"][0], ConfigServer.skill["skill282"]["army_go"][1], skillLv) : 0);
			//科技
			var scienceValue:Number = ModelScience.func_sum_type("army_go");
			//军府
			var buildingValue:Number = abx(ConfigServer.system_simple["building_army_go"][2], ConfigServer.system_simple["building_army_go"][1], ModelManager.instance.modelInside.getBuilding003().lv)
			
			return ConfigConstant.SPEED_MARCH * (1 + 
							equipValue + 
							skillValue +
							scienceValue + 
							buildingValue + 
							value);
			
		}
		
		public static function armyGo3(city1:int):Number {			
			var entity:EntityCity = MapModel.instance.citys[city1];
			var faithValue:Number = entity.isFaith && entity.getParamConfig("faith")[2] > 0 ? ConfigServer.world["faithBuffSpeedRate"][entity.getParamConfig("faith")[2] - 1] : 0;
			return faithValue;
		}
		
		public static function armyGo2(city1:int):Number {
			return ModelCityBuild.getEffectValue(city1.toString(), 6);
		}
		
		
		public static function armyFood2(city1:int):Number {
			return ModelCityBuild.getEffectValue(city1.toString(), 7);
		}
		
		public static function armyFood(army:int, count:int):Number {
			return (count * ConfigServer.army["army_ability"][ModelBuiding.getArmyCurrGradeByType(army).toString()][army][4] * ConfigServer.army["army_food_num"]) / (1 + ModelScience.func_sum_type("army_food"));
		}
	}

}