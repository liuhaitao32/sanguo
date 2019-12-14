package sg.fight.test
{
	import laya.display.Node;
	import laya.maths.MathUtil;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.model.ModelGame;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.utils.Tools;
	
	/**
	 * ...
	 * @author zhuda
	 */
	public class TestCopyright
	{
		public function TestCopyright()
		{
		
		}
		
		/**
		 * 没有关卡数据，初始化
		 */
		public static function sendInit():void
		{
			if (ModelManager.instance.modelUser.records.hasOwnProperty('testChapter')) return;
			
			var testChapter:int = 0;
			var gold:Number = 4000;
			var heroObj:Object = {};
			var len:int = TestCopyrightData.heroInitArr.length;
			for (var i:int = 0; i < len; i++)
			{
				var obj:Object = TestCopyrightData.heroInitArr[i];
				var hid:String = obj.hid;
				var heroData:Object;
				if (obj.gold)
				{
					break;
				}
				else
				{
					heroData = TestCopyright.createMyHeroData(hid, obj.lv);
				}
				
				heroObj[hid] = heroData;
			}
			
			var data:Object = {gold: gold, hero: heroObj, testChapter: testChapter};
			NetSocket.instance.send(EventConstant.TEST_CHANGE, data, null);
			
			ModelManager.instance.modelUser.hero = heroObj;
			ModelManager.instance.modelUser.records.testChapter = testChapter;
			ModelManager.instance.modelUser.gold = gold;
		}
		
		/**
		 * 收获钱币，收益受防沉迷打折
		 */
		public static function sendGainGold(value:int):void
		{
			value = Math.floor(value * ModelGame.getCurrProfitRate());
			var gold:Number = value + ModelManager.instance.modelUser.gold;
			var data:Object = {gold: gold};
			NetSocket.instance.send(EventConstant.TEST_CHANGE, data, null);
			//NetSocket.instance.send(EventConstant.TEST_CHANGE, data, Handler.create(this, function(vo:NetPackage):void {
			//}));
			ModelManager.instance.modelUser.gold = gold;
			TestCopyright.gainGold(value, 1);
			
			FightMain.instance.ui.updateTop();
			
			FightMain.instance.ui.updateLowerPanel();
		}
		
		/**
		 * 购买或升级英雄
		 */
		public static function sendUpgradeHero(hid:String):void
		{
			var arr:Array = TestCopyright.checkUpgradeHero(hid);
			var gold:Number = ModelManager.instance.modelUser.gold - arr[2];
			if (gold >= 0)
			{
				var heroLv:int = arr[1] + (arr[0] ? 1 : 0);
				var heroData:Object = TestCopyright.createMyHeroData(hid, heroLv);
				
				if (arr[0] == 0)
				{
					//购买了新英雄，立即上阵
					FightMain.instance.client.addTroop(getMyTroop(hid, heroData), 0);
				}
				else
				{
					var battle:ClientBattle = FightMain.instance.client;
					var troop:ClientTroop = battle.findTroop(0, hid) as ClientTroop;
					if (troop != null)
					{
						//仍然存活，在阵上升级，如未战斗补充兵力，更新队形
						var troopIndex:int = troop.troopIndex;
						if (troopIndex >= 0)
						{
							battle.removeTroop(troop);
							FightMain.instance.client.addTroop(getMyTroop(hid, heroData), 0, troopIndex);
						}
						else
						{
							//战斗中不允许使用
							//battle.skip();
							//battle.removeTroop(troop);
							return;
						}
						
					}
				}
				
				ModelManager.instance.modelUser.gold = gold;
				FightMain.instance.ui.updateTop();
				
				ModelManager.instance.modelUser.hero[hid] = heroData;
				FightMain.instance.ui.updateLowerPanel();
				
				var data:Object = {gold: gold, hero: ModelManager.instance.modelUser.hero};
				NetSocket.instance.send(EventConstant.TEST_CHANGE, data, null);
				
			}
		}
		
		/**
		 * 通关后自动挑战下一关，战败不调用此方法
		 */
		public static function sendNextChapter():void
		{
			var value:int = 0;
			var testChapter:int = ModelManager.instance.modelUser.records.testChapter;
			if (TestCopyrightData.currChapter == testChapter)
			{
				//新章通关，收益不打折
				value = ConfigFight.testChapter[TestCopyrightData.currChapter].gold;
				TestCopyright.gainGold(value, 50, 320, 400);
				
				testChapter++;
				ModelManager.instance.modelUser.records.testChapter = testChapter;
				
				var gold:Number = value + ModelManager.instance.modelUser.gold;
				ModelManager.instance.modelUser.gold = gold;
				
				var data:Object = {gold: gold, testChapter: testChapter};
				NetSocket.instance.send(EventConstant.TEST_CHANGE, data, null);
				
				FightMain.instance.ui.updateTop();
				FightMain.instance.ui.updateLowerPanel();
			}
			
			TestCopyrightData.currChapter = Math.min(ConfigFight.testChapter.length - 1, testChapter, TestCopyrightData.currChapter + 1);
		
		}
		
		/**
		 * 获得购买或升级英雄的类型和金币
		 */
		public static function gainGold(value:int, num:int = 1, startX:int = 550, startY:int = 550):void
		{
			num = Math.ceil(Math.pow(value, 0.1) * 5 + num);
			var parent:Node = FightMain.instance.ui.effectLayer;
			EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_GOLD), startX, startY, 30, 30, 1, num, parent);
			EffectManager.createLabelRise('+' + value, startX, startY - 20, 1000, 50, '#FFFF00', '#333333', parent);
		}
		
		/**
		 * 获得购买或升级英雄的类型和金币
		 */
		public static function checkUpgradeHero(hid:String):Array
		{
			var type:int;
			var gold:Number;
			var heroLv:int;
			
			var heroData:Object = ModelManager.instance.modelUser.hero[hid];
			if (heroData)
			{
				heroLv = heroData.lv;
				type = 1;
				gold = TestCopyrightData.heroLvArr[0] + TestCopyrightData.heroLvArr[1] * heroLv + TestCopyrightData.heroLvArr[2] * heroLv * heroLv + TestCopyrightData.heroLvArr[3] * heroLv * heroLv * heroLv;
				if (heroLv % 10 == 9)
				{
					gold += TestCopyrightData.heroStarArr[0] + TestCopyrightData.heroStarArr[1] * heroLv + TestCopyrightData.heroStarArr[2] * heroLv * heroLv + TestCopyrightData.heroStarArr[3] * heroLv * heroLv * heroLv;
				}
			}
			else
			{
				var heroConfig:Object = TestCopyrightData.getHeroInitConfig(hid);
				type = 0;
				gold = heroConfig.gold;
				heroLv = heroConfig.lv;
			}
			return [type, heroLv, gold];
		}
		
		/**
		 * 获得某英雄在某等级下的数据
		 */
		public static function createMyHeroData(hid:String, lv:int):Object
		{
			var armyRank:int = getArmyRankByLv(lv);
			var hero_star:int = getHeroStarByLv(lv);
			var armyLv:int = lv + 30;
			
			//var heroData:Object = {'armyRank': armyRank, 'armyLv': armyLv, 'block': 0, 'equip': [], 'exp': 0, 'fate': [], 'hero_star': hero_star, 'lv': lv, 'star': {}, 'title': null};
			var heroData:Object = {'armyRank': armyRank, 'armyLv': armyLv, 'hero_star': hero_star, 'lv': lv};
			if (TestCopyrightData.heroSkillConfig[hid])
			{
				heroData.skill = TestCopyrightData.heroSkillConfig[hid];
			}
			return heroData;
		}
		
		/**
		 * 获得我方队列数据
		 */
		public static function getMyTroop(hid, heroData:Object = null):Object
		{
			if (!heroData)
			{
				heroData = ModelManager.instance.modelUser.hero[hid];
			}
			heroData = FightUtils.clone(heroData);
			heroData.country = 1;
			
			var heroCfg:Object = ConfigServer.hero[hid];
			heroData.uname = Tools.getMsgById(heroCfg.name);
			heroData.hid = hid;
			heroData.uid = 1;
			return heroData;
		}
		
		/**
		 * 获得我方队列数据
		 */
		public static function getMyTroops():Array
		{
			var arr:Array = [];
			for (var hid:String in ModelManager.instance.modelUser.hero)
			{
				arr.push(getMyTroop(hid));
			}
			arr.sort(MathUtil.sortByKey('lv', true));
			return arr;
		}
		
		/**
		 * 获得某等级下的英雄星级
		 */
		public static function getHeroStarByLv(lv:int):int
		{
			return Math.floor(lv / 10) * (10 + lv) + lv;
		}
		
		/**
		 * 获得某等级下的兵种段位
		 */
		public static function getArmyRankByLv(lv:int):int
		{
			return Math.min(3, Math.floor(lv / 20));
		}
		
		/**
		 * 获得某英雄当前战前准备数据
		 */
		public static function getPrepareObj(hid:String):Object
		{
			var heroData:Object = ModelManager.instance.modelUser.hero[hid];
			var obj:Object = {hid: hid, hero_star: heroData.hero_star, lv: heroData.lv, armyRank: heroData.armyRank, armyLv: heroData.armyLv, skill: heroData.skill};
			
			return obj;
		}
	}

}