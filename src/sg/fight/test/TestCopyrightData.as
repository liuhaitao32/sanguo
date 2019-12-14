package sg.fight.test 
{
	import sg.fight.logic.cfg.ConfigFight;
	import sg.manager.ModelManager;
	/**
	 * ...
	 * @author zhuda
	 */
	public class TestCopyrightData 
	{
		///当前选择章节
		public static var currChapter:int = 0;
		
		///英雄购买数据
		public static var heroInitArr:Array = [
			{
				hid:'hero738',
				lv:1
			},
			{
				hid:'hero706',
				lv:3
			},
			{
				hid:'hero701',
				lv:6,
				gold:1500
			},
			{
				hid:'hero716',
				lv:16,
				gold:20000
			},
			{
				hid:'hero729',
				lv:36,
				gold:250000
			},
			{
				hid:'hero736',
				lv:56,
				gold:1800000
			},
			{
				hid:'hero714',
				lv:76,
				gold:9000000
			}
		];
		///英雄技能数据
		public static var heroSkillConfig:Object = {
			'hero738':{//孙乾
				'skill204': 5,
				'skill213': 3
			},
			'hero706':{//关羽
				'skill225': 5, 
				'skill227': 14, 
                'skill210': 9 
			},
			'hero701':{//马超
				'skill209': 15, 
                'skill210': 5, 
                'skill207': 17
			},
			'hero716':{//赵云
				'skill227': 19, 
                'skill206': 13, 
                'skill214': 8
			},
			'hero729':{//姜维
				'skill232': 15, 
                'skill235': 17, 
                'skill223': 18
			},
			'hero736':{//黄忠
				'skill225': 25, 
                'skill214': 17, 
                'skill217': 14
			},
			'hero714':{//诸葛亮
				'skill233': 24, 
				'skill238': 25, 
                'skill224': 20, 
                'skill220': 16
			}
		};
		
		///英雄升级数据 0~3次项,保留整百
		public static var heroLvArr:Array = [200, 50, 10, 4];
		
		///英雄每10级升星数据 0~3次项,保留整百
		public static var heroStarArr:Array = [5000, 2000, 100, 10];

		
		/**
		 * 初始化
		 */
		public static function init():void
		{
			for (var i:int = ConfigFight.testChapter.length-1; i >= 0; i--) 
			{
				var chapterConfig:Object = ConfigFight.testChapter[i];
				var troopArr:Array = chapterConfig.troop;
				for (var j:int = troopArr.length-1; j >= 0; j--) 
				{
					var troopObj:Object = troopArr[j];
					if (!troopObj.hasOwnProperty('uname')){
						troopObj.uname = "先锋部队";
					}
					if (!troopObj.hasOwnProperty('country')){
						troopObj.country = chapterConfig.country;
					}
					
					troopObj.armyRank = TestCopyright.getArmyRankByLv(troopObj.lv);
					troopObj.armyLv = troopObj.lv;
					troopObj.hero_star = TestCopyright.getHeroStarByLv(troopObj.lv);
				}
			}
			ConfigFight.damageOutPer = 1;
			TestCopyrightData.currChapter = Math.min(ConfigFight.testChapter.length -1,ModelManager.instance.modelUser.records.testChapter);
		}
		
		/**
		 * 得到章节信息
		 */
		public static function getChapterConfig(index:int):Object
		{
			return ConfigFight.testChapter[index];
		}
		/**
		 * 得到英雄初始化信息
		 */
		public static function getHeroInitConfig(hid:String):Object
		{
			for (var i:int = TestCopyrightData.heroInitArr.length-1; i >= 0; i--) 
			{
				var obj:Object = TestCopyrightData.heroInitArr[i];
				if (obj.hid == hid){
					return obj;
				}
			}
			return null;
		}
		
		/**
		 * 得到初始化战役数据
		 */
		public static function getFightData():*
		{
			var data:*;
			//特殊章节战斗
			data = {
				'mode':0,
				'title':ConfigFight.testChapter[TestCopyrightData.currChapter].title,
				'fireCountry':1,
				'country':ConfigFight.testChapter[TestCopyrightData.currChapter].country,
				'rnd':Math.floor(Math.random() * 10000)
			};
			data.team = [
				{
					'troop':TestCopyright.getMyTroops()
				},
				{
					'troop':ConfigFight.testChapter[TestCopyrightData.currChapter].troop
				}
			];
			return data;
		}
	}

}