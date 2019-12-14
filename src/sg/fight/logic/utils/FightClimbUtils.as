package sg.fight.logic.utils 
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	/**
	 * 过关斩将机器人生成工具
	 * @author zhuda
	 */
	public class FightClimbUtils 
	{
		
		 /**
         * 给一个权重池对象和随机种子，稳定的获取随机结果（排除可能因为遍历顺序的不同，生成不同的数组）
         */
        public static function randomWeightObj(weightObj:*, fightRnd:FightRandom):String {
			//先按字段顺序排序，保证数组有序再遍历
			var sortArr:Array;
			var key:String;
			if (!(weightObj is Array)){
				sortArr = [];
			    for (key in weightObj) {
                    sortArr.push([key,weightObj[key]]);
                }
				sortArr.sort(MathUtil.sortByKey('0',false,false));
			}
			else{
				sortArr = weightObj as Array;
			}
			var weight:int = 0;
			var sumArr:Array = [];
			var num:Number;
			var i:int;
			var len:int = sortArr.length;

			for (i = 0; i < len; i++) 
			{
				var arr:Array = sortArr[i];
				key = arr[0];
				num = arr[1];
				if(num > 0){
					weight += num;
					sumArr.push([key, weight]);
				}
			}
			if (weight > 0){
				var value:int = fightRnd.getRandomIndex(weight);
				len = sumArr.length;
				for (i = 0; i < len; i++) 
				{
					var keyValue:Array = sumArr[i];
					if (value < keyValue[1]){
						return keyValue[0];
					}
				}
			}
			return null;
		}
		
		/**
         * 给对应技能个数等级数组，以及4种技能池配置，返回随机出的技能
         */
        public static function getRandomSkill(skillLvArr:Array, weightObjArr:Array, fightRnd:FightRandom):Object {
			var reObj:Object = {};
			var i:int;
			var len:int = skillLvArr.length;
			for (i = 0; i < len; i++ ){
				var arr:Array = skillLvArr[i];
				var num:int = arr[0];
				var weightObj:Object = weightObjArr[i];
				if (num > 1)
					weightObj = FightUtils.clone(weightObj);
				for (var j:int = 0; j < num; j++) 
				{
					var skillId:String = FightClimbUtils.randomWeightObj(weightObj, fightRnd);
					reObj[skillId] = arr[1];
					if (j < num - 1){
						delete weightObj[skillId];
					}
				}
			}
			return reObj;
		}
		
		/**
         * 指定等级、兵种，获得过关斩将随机敌军部队数据
         */
        public static function getRandomTroopByLv(lv:int, armyType0:int, armyType1:int, fightRnd:FightRandom, climbCfg:Object):Object {
			var reObj:Object = {};
			reObj.hid = FightClimbUtils.randomWeightObj(ConfigServer.system_simple.herorange_base, fightRnd);

			var robotConfig:Object = ConfigServer.pk_robot[climbCfg.robotrange];
			var npcConfig:Object = robotConfig[lv.toString()] || robotConfig['default'];
			reObj.lv = lv;
			reObj.hero_star = npcConfig.hero_star;
			reObj.army = [
				{
					lv:npcConfig.armylv, 
					rank:npcConfig.armyRank, 
					type:armyType0
				}, 
				{
					lv:npcConfig.armylv, 
					rank:npcConfig.armyRank, 
					type:armyType1
				}
			];
			//reObj.armylv = npcConfig.armylv;
			//reObj.armyRank = npcConfig.armyRank;
			reObj.passive = npcConfig.passive;
			//reObj.uid = -1;

			var weightObjArr:Array = [climbCfg.heroskill];
			weightObjArr.push(climbCfg['armyskill' + armyType0]);
			weightObjArr.push(climbCfg['armyskill' + armyType1]);
			weightObjArr.push(climbCfg.helplimit);
			
			reObj.skill = FightClimbUtils.getRandomSkill(npcConfig.skill, weightObjArr, fightRnd);
			return reObj;
		}
		
		/**
         * 指定世界等级、当前波数、兵种，获得过关斩将随机敌军部队数据
         */
        public static function getRandomTroop(worldLv:int, waveNum:int, armyType0:int, armyType1:int, fightRnd:FightRandom, climbCfg:Object):Object {
			var lvConfigArr:Array = climbCfg.lv;
			var rankArr:Array = FightUtils.getRankArr(waveNum, lvConfigArr);
			var waveExtra:int = waveNum - rankArr[0];
			//向上取整([1]*世界等级 + [2] + x'*[3]) 
			var lv:int = Math.ceil(rankArr[1] * worldLv + rankArr[2] + rankArr[3] * waveExtra);
			
			return FightClimbUtils.getRandomTroopByLv(lv, armyType0, armyType1, fightRnd, climbCfg);
		}
		
	}

}