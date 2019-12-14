package sg.fight.test 
{
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelPrepare;
	/**
	 * ...
	 * @author zhuda
	 */
	public class TestFightData 
	{
		public static var testModeArr:Array = [0,1,3,4,5,6,7,10,100,101,102,103,104,200,201,202,203,-3,-2,-1];
		///0国战,1过关斩将,3比武大会,4王者之巅,5异族入侵,6军团贡品,7讨伐张角,8草上谈兵,10擂台赛,100沙盘演义,101群雄逐鹿,102传奇试炼,103蓬莱寻宝,104福将踏关,200名将切磋,201占领产业,202叛军野战,203山贼
		public static var testMode:int = 0;
		///是否对比同英雄special和同类act的优先级是否冲突
		public static var testFightPrint:int = 0;
		public static var testPartArr:Array = null;
		
		public static var testUid:int = 226;
		public static var testUname:String = '测试者';
		public static var testCountry:int = 1;
		///特定战役的初始化信息
		public static var testInitBattleData:Object;
		///特定战斗的初始化信息
		public static var testInitFightData:Object;
		///打印下一个伤害详细报告
		public static var testNextHurt:Boolean;
		
		///左右首个英雄，使用特殊数据
		public static var testUseStatistics:int = 0;
		
		///各种类型技能的数量
		//static public var skillNums:Array;
		
		/**
		 * 得到对应技能类型的数量
		 */
		//public static function getSkillNums(skillType:int):int
		//{
			//if (!TestFightData.skillNums){
				//TestFightData.skillNums = [];
				////该类技能集合
				//for (var i:int = 0; i < ConfigFight.testSkills.length; i++) 
				//{
					//var num:int = FightUtils.getObjectLength(ConfigFight.testSkills[i]);
					//TestFightData.skillNums[i] = num;
				//}
			//}
			//return TestFightData.skillNums[skillType];
		//}
		
		/**
		 * 得到当前testMode是否可以呼出testStatistics zxc
		 */
		public static function get canTestStatistics():Boolean
		{
			return testMode == -1 || testMode == 104;
		}
		
		/**
		 * 可被随机到的国家id
		 */
		public static function getRandomCountryId():int
		{
			return Math.floor(Math.random() * 17);
		}
		/**
		 * 可被随机到的城市id
		 */
		public static function getRandomCityId():int
		{
			var cfg:Object = ConfigServer.city;
			var arr:Array = [];
			for (var key:String in cfg) 
			{
				arr.push(parseInt(key));
			}
			return arr[Math.floor(Math.random() * arr.length)];
			//return Math.floor(Math.random() * 394);
		}
		
		public static var heroIdArr:Array = [
				'hero701', 'hero702', 'hero703', 'hero704', 'hero705', 'hero706', 'hero707', 'hero708', 'hero709', 'hero710', 'hero711', 'hero712', 'hero713', 'hero714', 'hero715', 'hero716', 'hero717', 'hero718', 'hero719',
				'hero720', 'hero721', 'hero722', 'hero723', 'hero724', 'hero725', 'hero726', 'hero727', 'hero728', 'hero729', 'hero730', 'hero731', 'hero732', 'hero733', 'hero734', 'hero735', 'hero736', 'hero737', 'hero738', 'hero739', 
				'hero740', 'hero741', 'hero742', 'hero743', 'hero744', 'hero745', 'hero746', 'hero747', 'hero748', 'hero749', 'hero750', 'hero751', 'hero752', 'hero753', 'hero754', 'hero755', 'hero756', 'hero757', 'hero758', 'hero759',
				'hero760', 'hero761', 'hero762', 'hero763', 'hero764', 'hero765', 'hero766', 'hero767', 'hero768', 'hero769', 'hero770', 'hero771', 'hero774', 'hero776'
				//, 'hero761'
			];
		/**
		 * 可被随机到的英雄
		 */
		public static function getRandomHeroId():String
		{
			return ArrayUtils.getRandomValue(heroIdArr);
		}
		
		/**
		 * 得到异族入侵，过关斩将等过程中会掉落道具的奖励结构
		 */
		public static function getRewardData(waveNum:int):Object
		{
			var data:Object = {};
			var itemIds:Array = ['item303','item304','item305','item306','item307','gold','coin'];
			for (var i:int = 0; i < waveNum; i++){
				var key:String = i.toString();
				var itemId:String = ArrayUtils.getRandomValue(itemIds);
				var itemNum:int = Math.floor(Math.random() * 50 + 1);
				if (Math.random() > 0.5){
					var obj:Object = {};
					obj[itemId] = itemNum;
					if(Math.random()>0.5){
						obj['item717'] = 3;
					}
					data[key] = obj;
				}
				else{
					data[key] = [itemId, itemNum];
				}
			}
			return data;
		}

		/**
		 * 得到全战斗科技2级数据
		 */
		public static function getAllScience(lv:int):*
		{
			var re:Object = {};
			var config:Object = ConfigServer.science;
			for (var key:* in config){
				var scienceObj:Object = config[key];
				if (scienceObj.type == 'passive'){
					re[key] = lv;
				}
			}
			return re;
		}
		/**
		 * 得到测试初始化单挑数据
		 */
		public static function getSoloInitData():*
		{
			return{
			   'mode':testMode,  //默认0国战 1过关斩将 2叛军野战 3比武大会 4王者之巅   100沙盘演义 101群雄逐鹿   200切磋 201产业 202山贼
			   'rnd':113425,
			   'team':[
				  {  //左方进攻部队
					 'uid':221,
					 'uname':'玩家名',
					 'country':2,
					 'troop':[
						{
						   'hid':'hero706',
						   //'building':[2222,1],
						   'hero_star':8,
						   //'skill':{'fate001':8},
						   //'skill':{'skill216':8},
						   'agi':90,
						   //'skill':{'skill228':15, 'skill229':15},
						  'equip':[ //   宝物及其洗炼数据[宝物等级,洗炼0,洗炼1…]   缺省无
							['equip011', 4, []]
						  ],
						   'skill':{'skill226':20},
						   //'skill':{'skill232':15,'skill236':15,'skill225':15,  'skill214':15,'skill203':15,'skill221':15,'skill289':15,'skill290':15,'skill260':15,'skill261':15,'skill270':15},
						   'title':'title001',
						   //'passive': {'rslt':{'hpm':10000,'block':1500,'crit':1150, 'bash':800, 'bashDmg':100}},
						   'lv':80
						}
					 ]
				  },
				  {  //右方防守部队
					 'uid':-1,
					 'troop':[
						{
						   'hid':'hero708',
						   'building':[1,0],
						   'hero_star':2,
						   'cha':30,
						   //'agi':80,
						   //'skill':{'skill230':15,'skill231':15,  'skill214':15,'skill203':15,'skill221':15,'skill289':15,'skill290':15,'skill260':15,'skill261':15,'skill270':15},
						   'passive': {'rslt':{'army[0].hpm':1000,'army[1].hpm':3000,'block':1200,'crit':1650, 'bash':800, 'bashDmg':100}},
						   'army':[{'type':1,'rank':1},{'type':3,'rank':1}]
						}
					 ]
				  }
			   ]
			};
		}
		/**
		 * 得到测试初始化战役数据
		 */
		public static function getBattleInitData():*
		{
			var data:Object = {
			   'mode':testMode,  //默认0国战 1过关斩将 2叛军野战 3比武大会 4王者之巅   100沙盘演义 101群雄逐鹿   200切磋 201产业 202山贼
			   'rnd':1251,
			   'team':[
				  {  //左方进攻部队
					 'uid':221,
					 'country':1,
					 'uname':'制霸九州',
					 'troop':[
						//{
						   //'hid':'hero762',
						   //'hero_star':12,
						   //'fate':['fate7141'],
						   ////'skill':{'skill229':20,'skill238':20,'skill206':15,'skill204':5,'skill203':14,'skill219':5,'skill220':4,'skill221':14},
						   //'shogun':[0.08, 0.12, 0.16],
						   //'equip':[['equip059',4,[]],['equip060',4,[]],['equip061',4,[]],['equip062',4,[]],['equip063',4,[]]],
						   ////'title':'title002',
						   //'adjutant' : [null,['hero702',123,250]],
						   ////'passive': {'rslt':{'bash':1000, 'bashDmg':100}},
						   //'army':[{'type':1, 'rank':0}, {'type':2, 'rank':5}],
						   //'armyHp':[300,20],
						   ////'passive': {'cond':['lv', '*',1],'rslt':{'hpm':1000,'atk':1000,'def':500}},
						   //'lv':3
						//},
						//{
						   //'hid':'hero716',
						   //'hero_star':18,
						   //'str':102,
						   //'fate':['fate7161'],
						   //'skill':{'skill226':15},
						   //'adjutant' : [['hero712', 23, 250], ['hero706', 23, 250]],
						   ////'armyHp':[100,0],
						   ////'shogun':[0.08, 0.12, 0.16],
						   ////'title':'title002',
						   ////'passive': {'rslt':{'bash':1000, 'bashDmg':100}},
						   ////'army':[{'type':1,'rank':0,'hp':0},{'type':2,'rank':5,'hp':100}],
						   //'lv':8
						//},
						//{
						   //'hid':'hero703',
						   //'hero_star':31,
						   //'lv':33,
						   ////'fate':['fate001'],
						   //'shogun':[0, 0, 0],
						   //'title':'title019',
						   //'army':[{'type':1,'rank':0},{'type':2,'rank':5}]
						//},
						//{
						   //'hid':'hero762',
						   //'hero_star':18,
						   //'lv':8,
						   ////'fate':['fate001'],
						   //'shogun':[0, 0, 0],
						   //'title':'title019',
						   //'army':[{'type':1,'rank':0},{'type':2,'rank':5}]
						//},
						{
						   'hid':'hero761',
						   'hero_star':1,
						   'lv':8,
						   //'fate':['fate001'],
						   'shogun':[0, 0, 0],
						   'title':'title019',
						   'army':[{'type':1,'rank':0},{'type':2,'rank':5}]
						}
						//{
						   //'hid':'hero708',
						   //'hero_star':3,
						   //'lv':133,
						   //'shogun':[0.2, 0, 0.3],
						   //'title':'title027',
						   //'fate':['fate7081']
						//},
						//{
						   //'hid':'hero716',
						   //'lv':82,
						   //'fate':['fate7161'],
						   ////'title':'title010',
						   //'str':110,
						   ////'cha':12,
						   ////'agi':92,
						   ////'skill':{'skill203':12},
						   ////'skill':{},
						   ////'army':[{'type':1,'rank':0,'hp':1000},{'type':2,'rank':5,'hp':777,'hpm':1000}],
						   ////'passive': {'rslt':{'atk':10002}},
						   //'skill':{'skill217':10, 'skill216':15, 'skill226':15},
						   //'hero_star':23
						//}
					 ]
				  },
				  {  //右方防守部队
					 //'uid':33,
					 //'uname':'轩辕杀',
					 'troop':[
						{
						   'hid':'hero710',
						   'hero_star': 25,
						   'shogun':[0.18, 0.2, 0.3],
						   //'str':120,
						   //'cha':90,
						   'agi':80,
						   'fate':['fate7081'],
						   'adjutant' : [['hero703', 23, 11], ['hero708', 23, 250]],
						   'armyHp':[0,2000],
						   //'skill':{},
						   
						   //'skill':{'skill236':12,'skill227':25,'skill209':15,'skill210':5,'skill207':4,'skill219':5,'skill220':4,'skill221':14},
						   //'passive': {'rslt':{'hpm':110}},
						   //'army':[{'type':1, 'rank':5, 'hp':100}, {'type':3, 'rank':5, 'hp':0}],
						   'lv':153
						   //'army':[{'type':1,'rank':1},{'type':3,'rank':1}]
						},
						{
						   'hid':'hero711',
						   'shogun':[0, 0, 0],
						   'hero_star':5,
						   'lv':34
						},
						{
						   'hid':'hero712',
						   'hero_star':10,
						   'adjutant' : [['hero703',23,22],null],
						   'lv':33,
						   'str':110
						   //'army':[{'type':1,'rank':0},{'type':2,'rank':5}]
						}
						//{
						   //'hid':'hero710',
						   //'hero_star':10,
						   //'lv':33
						//},
						//{
						   //'hid':'hero826',
						   //'hero_star':10,
						   //'lv':33
						//},
						//{
						   //'hid':'hero827',
						   //'hero_star':10,
						   //'lv':33
						//},
						//{
						   //'hid':'hero727',
						   //'hero_star':10,
						   //'lv':40
						//}
					 ]
				  }
			   ]
			};
			if (testMode == 1)
			{
				data.team[1].troop = [];
				data.climb = {worldLv:20, armyType0:0, armyType1:3};
				if(!ConfigApp.testTimeRate)
					data.skipTime = Math.random()>0.5?(Math.random() * 200):0;
			}
			else if (testMode == 5)
			{
				if(!ConfigApp.testTimeRate)
					data.skipTime = Math.random() * 200;
				for (var i:int = 0; i < 30; i++){
					data.team[1].troop.push({'hid':'hero712','hero_star':i,'lv':i});
				}
			}
			else if (testMode == 10)
			{
				//擂台
				data.arena_group = Math.floor(Math.random() * 8 + 1);
				data.team[1].uid = 20;
				data.canEndTime = ConfigServer.getServerTimer() / 1000 + 3;
				
				data.team[0].bless = 10.35;
				//data.team[1].bless = 110.15;
			}
			
			if (testMode == 0 || testMode == 3 || testMode == 4 || testMode == 101)
			{
				//PVP模式对手为玩家
				//0国战1过关斩将,3比武大会,4王者之巅,5异族入侵,6军团贡品,7讨伐张角,8草上谈兵,100沙盘演义,101群雄逐鹿,102传奇试炼,103魔将来袭,200名将切磋,201占领产业,202叛军野战,203山贼
				data.team[1].uid = 33;
				data.team[1].uname = '玩家轩辕杀';
			}
			
			return data;
		}
		/**
		 * 得到测试初始化战斗数据
		 */
		public static function getFightInitData():*
		{
			return {
				'rnd':10,
				'troop':[
					{
                      'uname':'NPC难民',
                      'hid':'hero722',
					  'lv':13,
					  'equip':[ //   宝物及其洗炼数据[宝物等级,洗炼0,洗炼1…]   缺省无
						['equip001', 0, ['wash005']],
						['equip001', 3, []],
						['equip004', 4, ['wash002', 'wash001', 'wash003']]
					  ],
                      'skill':{'skill208':8}
					},
					{
                      'uid':2,
                      'uname':'蜀帝',
                      'country':1,
                      'hid':'hero706',
                      'hero_star':10,
                      'lv':50,
                      'skill':{'skill201':6},
                      'army':[{'type':1,'rank':0,'hp':162},{'type':2,'rank':5,'hp':130}]
					}
				]
			};
		}
		/**
		 * 得到初始化战役数据
		 */
		public static function getFightData():*
		{
			if (ConfigApp.testFightType == 2){
				//特殊章节战斗
				return TestCopyrightData.getFightData();
			}
			var data:*;
			var i:int;
			var len:int;
			var troopData:Object;

			if (testMode <= 0){

				if (testMode == -3)
				{
					data = {
						'mode':0,
						'rnd':Math.floor(Math.random() * 10000)
					};
					data.team = [
						{
							'troop':[  //左方进攻部队
								//TestFightData.getRandomTroopData(fireCountry),
								//TestFightData.getRandomTroopData(fireCountry),
								//TestFightData.getRandomTroopData(fireCountry),
								TestFightData.getRandomTroopData(fireCountry),
								TestFightData.getRandomTroopData(fireCountry),
								TestFightData.getRandomTroopData(fireCountry),
								TestFightData.getRandomTroopData(fireCountry)
							]
						},
						{
							'troop':[  //右方防守部队
								//TestFightData.getRandomTroopData(country),
								TestFightData.getRandomTroopData(country)
							]
						}
					];
					data.readyTime = Math.random() > 0.5?0:3000;
				}
				else if (testMode == -2)
				{
					data = FightUtils.clone(ConfigFight.testBattle);
					data.mode = -2;
				}
				else if (testMode == -1)
				{
					data = {
						'mode':-1,
						'rnd':Math.floor(Math.random() * 10000)
					};
					data.team = [
						{
							'troop':[  //左方进攻部队
								ConfigFight.testFightInit[0]
							]
						},
						{
							'troop':[  //右方防守部队
								ConfigFight.testFightInit[1]
							]
						}
					];
				}
				else{
					data = TestFightData.getBattleInitData();
				}
				
				if (data.mode == 0){
					//国战
					var country:int = Math.floor(Math.random() * 3);
					var fireCountry:int = (country + 1) % 3;
					//var fireCountry:int = getRandomCountryId();
					//if (fireCountry == country){
						//fireCountry = (fireCountry + 1) % 17;
					//}
					//if (fireCountry == country){
						//fireCountry = (fireCountry + 1) % 3;
					//}
					if (Math.random() > 0.5)
					{
						var temp:int = country;
						country = fireCountry;
						fireCountry = temp;
					}
					//var country:int = Math.floor(Math.random() * 3);
					
					data.city = getRandomCityId();
					data.country = country;
					data.fireCountry = fireCountry;
					data.rnd = Math.floor(Math.random() * 10000);
					
					delete data.team[0].uid;
					delete data.team[0].uname;
					delete data.team[0].country;
					delete data.team[1].uid;
					delete data.team[1].uname;
					delete data.team[1].country;
					
					
					
					var troopArr:Array;

					data.user_logs = {};
					data.country_logs = {};
					data.country_logs[fireCountry] = {buff:[2, 0.5], milepost:5};
					//data.country_logs[country] = {buff:[0.5, 0.25], milepost:1};
					//data.country_logs[fireCountry] = {buff:[0, 0], milepost:5};
					data.country_logs[country] = {buff:[0, 0], milepost:1};
					data.tower = [Math.floor(3*Math.random()), Math.floor(3*Math.random())];
					data.fight_count = 38;
					
					troopArr = data.team[0].troop;
					for (i = 0; i < troopArr.length; i++) 
					{
						troopData = troopArr[i];
						//troopData.uid = 222;
						//if (i >= 0){
							////troopData.proud = 100;
							////国战中插入少量黄巾军
							//if (Math.random() > 0.5){
								//troopData.hid = 'hero825';
								//troopData.npc_type = 'thief_two';
								//troopData.lv = 20;
							//}
							//else{
								//troopData.hid = 'hero822';
								//troopData.npc_type = 'thief_one';
								//troopData.lv = 20;
							//}
						//}
						troopData.lv = 240;
						//troopData.hid = 'hero716';
						//troopData.hid = 'hero762';
						if (i == 3){
							//troopData.uid = 'hero769';
							//troopData.hid = 'hero769';
						}
						//troopData.proud = 31;
						//troopData.hid = 'hero826';
						troopData.awaken = 1;
						troopData.skill = {'skill204':11};
						//troopData.formation = [Math.floor(Math.random()*6+1), {1:[2, 20]}];
						troopData.uid = 222;
						//troopData.uid = -1;
						//troopData.uid = i%2==0?-i-5:220 + Math.floor(i%3);
						//troopData.uid = 222 + Math.floor(i%2);
						//troopData.official = troopArr.length - i;
						troopData.country = fireCountry;
						//if (i == 0){
							//troopData.adjutant = [null,['hero702',23,250]];
						//}
						
						data.user_logs[troopData.uid] = {
							uname:"吞食天下吞食天"+i,
							head:'hero'+(733+i),
							country:fireCountry,
							//official:troopData.official,
							//guild_id:0,
							//guild_name:"厉害军团" + i,
							power:0,
							kill:0
						};
					}
					troopArr = data.team[1].troop;
					for (i = 0; i < troopArr.length; i++) 
					{
						troopData = troopArr[i];
						troopData.uid = 226 + Math.floor(i % 3);
						//troopData.uname = "不服就干" + Math.floor(i%3);
						//troopData.uid = 225;
						//troopData.uid = -1;
						if (i == 0){
							//华佗
							troopData.hid = 'hero763';
							//troopData.skill.skill272 = 1;
							troopData.fate = [];
							troopData.skill = {'skill204':11};
							//troopData.proud = 100;
						}
						else{
							troopData.hid = 'hero762';
							troopData.lv = 199;
						}
						//troopData.official = i%3 != 0 ?(i%3 == 1?-2:-1):-100;
						//troopData.hid = 'hero711';
						//troopData.formation = [Math.floor(Math.random()*6+1), {1:[2, 20]}];
						troopData.awaken = 1;
						troopData.country = country;
						//if (i == 1){
							//troopData.adjutant = [['hero707',125,10],['hero709',125,10]];
						//}
						
						data.user_logs[troopData.uid] = {
							uname:"WWWwwwWWWwwwW" +troopData.uid,
							head:'hero708',
							country:country,
							official:troopData.official,
							//guild_id:10,
							//guild_name:"厉害军团2" + i,
							power:0,
							kill:0
						};
					}
				}
			}
			else if (testMode < 200)
			{
				data = TestFightData.getBattleInitData();
				if (data.mode == 1 || data.mode == 5)
				{
					var waveNum:int = data.mode == 1 ? 100:data.team[1].troop.length;
					data.reward = TestFightData.getRewardData(waveNum);
				}
				else if (data.mode == 6)
				{
					//异邦来访，做一个受弱点的强大敌人
					data.team[1].troop = [					
						{
						  //'uname':'邪马台来使',hero809  hero810
						  'hid':'hero809',
						  'lv':3,
						  'skill':{},
						  //'skill':{'skill238':1},
						  'passive': {'rslt':{'army[0].hpm':10000,'army[0].atk':10000,'army[1].hpm':1000,'spd':-50}},
						  //'passive': {'rslt':{'army[0].hpm':10000, 'army[1].hpm':3000, 'bash':500, 'bashDmg':3333}},
						  //'passive': {'rslt':{'army[0].hpm':10000,'army[1].hpm':3000,'block':5000,'crit':500, 'bash':500, 'bashDmg':3333}},
						  'weak': [['resSex0',0,20.5],['resType0',0,0.5]]
						  //'weak': [['rarity',3,10], ['rarity',1,0.75]]
						}
					];
				}
				else if (data.mode == 100)
				{
					data.gift = {'item303':303, 'item001':1, 'gold':800};
					if (Math.random() > 0.5){
						data.gift.coin = 222;
					}
				}
				else if (data.mode == 103)
				{
					//蓬莱寻宝，增加奖励和卜卦
					data.gift = {'item303':111, 'item001':222, 'gold':333};
					if (Math.random() > 0.5){
						data.gift.coin = 444;
					}
					data.team[0].troop[0].magic = Math.random() > 0.5?'magic007':'magic008';
				}
				else if (data.mode == 104)
				{
					//福将挑战，我方固定使用当前部队复制5份，敌方使用预设
					if(TestFightData.testPartArr == null)TestFightData.testPartArr = ConfigFight.testBlessPart[0];
					var partStr:String = ConfigServer.bless_hero_npc[TestFightData.testPartArr[1]]?TestFightData.testPartArr[1]:'default';
					data.team[1].troop = ConfigServer.bless_hero_npc[partStr];
					data.rnd = Math.floor(Math.random() * 10000);
					
					if (TestFight.lastTestStatistics){
						var troopObj:Object =  TestFight.lastTestStatistics.getTestFightTroop(0).getCurrData(true);
						data.team[0].troop = [];
						len = data.team[1].troop.length;
						for (i = 0; i < len; i++) 
						{
							data.team[0].troop.push(FightUtils.clone(troopObj));
						}
					}

					if (TestFightData.testPartArr[2]){
						//有额外预设战力，映射到活动挑战的额外等级，附加进去
						data.team[1].troop = FightUtils.clone(data.team[1].troop);
						var extraLvArr:Array = FightUtils.getRankArr(TestFightData.testPartArr[2], ConfigServer.bless_hero.secondary_lv.convert);
						len = extraLvArr.length-1;
						for (i = 0; i < len; i++) 
						{
							troopData = data.team[1].troop[i];
							troopData.lv += extraLvArr[i + 1];
						}
					}
				}
			}
			else
			{
				data = TestFightData.getSoloInitData();
			}
			//data.rnd = Math.floor(Math.random() * 10000);
			
			
			if (testUseStatistics){
				//使用-1模式中的测试对象进行覆盖
				if(TestFight.lastTestStatistics){
					var testStatistics:TestStatistics = TestFight.lastTestStatistics;
					var ui0:TestFightTroop = testStatistics.getTestFightTroop(0);
					var ui1:TestFightTroop = testStatistics.getTestFightTroop(1);
					
					var troop0:Object = ui0.getCurrData(true);
					var troop1:Object = ui1.getCurrData(true);
					data.team[0].troop[0] = troop0;
					data.team[1].troop[0] = troop1;
					//data.timeScale = 9999999;
				}
				
			}
			
			return data;
		}
		/**
		 * 得到初始化备战数据
		 */
		public static function getRandomTroopData(country:int = -1):*
		{
			return ModelPrepare.getData(TestFightData.getPrepareInData(country), true);
			//return new ModelPrepare(TestFightData.getPrepareInData(country), true).getData();
		}
		/**
		 * 得到随机备战数据
		 */
		public static function getRandomPrepareInData(country:int = -1):*
		{
			var data:* = {
				//'hid':'hero701',
				//'hero_star':3
			};
			if (Math.random() > 0.5)
			{
				data.uid = 1;
				data.uname = "玩家";
				//data.country = Math.floor(Math.random() * 3);
				//   宝物及其洗炼数据[宝物等级,洗炼0,洗炼1…]   缺省无
				if (Math.random() > 0.5){
					data.equip =[ 
						['equip001', 0, ['wash005']],
						['equip001', 3, []],
						['equip004', 4, ['wash002', 'wash001', 'wash003']]
					];
				}
			}
			else{
				data.uname = 'NPC';
				//data.country = Math.floor(Math.random() * 17);
				if (data.country == 3)
				{
					data.country ++;
				}
			}
			if(country >= 0){
				data.country = country;
			}
			else{
				data.country = Math.floor(Math.random() * 17);
			}
			//data.country = Math.floor(Math.random() * 17);
			data.lv = Math.floor(Math.random() * 99 + 1);
			data.hero_star = Math.floor(Math.random() * 20);
			//data.hid = 'hero' + Math.floor(Math.random() * 30 + 701);
			//data.hid = 'hero701';
			data.hid = getRandomHeroId();
			
			if (Math.random() > 0.7){
				data.armyLv = 50;
				data.armyRank = 1;
				data.armyAdd = 3;
			}
			else{
				var type:int;
				var rank:int;
				//data.army = [{'id':'army20'}, {'id':'army20'}];
				data.army = [{'type':0,'rank':1}, {'type':2,'rank':6}];

				if (Math.random() > 0.1){
					data.army[0].type = Math.floor(Math.random() * 2);
					data.army[0].rank = Math.floor(Math.random() * 2);
					//data.army[0].add = [100,5];
				}
				if (Math.random() > 0.15){
					data.army[1].type = Math.floor(Math.random() * 2+2);
					data.army[1].rank = Math.floor(Math.random() * 2);
				}
			}
			//data.passive = TestFightData.getPassiveData();
			
			//if (Math.random() > 0.5){
				//data.skill = {'skill201': Math.ceil(Math.random()*25)};
			//}
			//data.skill = {'skill201': Math.ceil(Math.random() * 25)};
			data.skill = {'skillTest': Math.ceil(Math.random() * 25)};
			
			//战斗科技
			data.science_passive = {};
			for (var i:int = 0; i < 100; i++) 
			{
				data.science_passive[i.toString()] = i;
			}
			
			data.official = Math.random() > 0.5 ?'gen':'minister0';
			
			//data.skill = {'skill201': 13,'skill202': 5};
			//if (Math.random() > 0.3){
				//var arr:Array = [['hero701', 23, 88]];
				//if (Math.random() > 0.5){
					//arr.push(['hero701',17,90]);
				//}
				//data.adjutant = arr;
			//}
			
			return data;
		}
		/**
		 * 得到初始化备战数据
		 */
		public static function getPrepareInData(country:int = -1):*
		{
			return {
			  'hid':'hero722',
			  'lv':1,
			  'hero_star':1,
			  'armyAdd':20,
			  'skill':{'skill210':18}
			  //'passive': {'rslt':{'army[0].hpm':10000,'army[0].atk':10000,'army[1].hpm':1000,'spd':-50}},
			  //'weak': [['resSex0',0.5],['resType0',110.5]]
			}
			return getRandomPrepareInData(country);	
		}
		/**
		 * 得到一系列被动属性
		 */
		public static function getPassiveData():Array
		{
			var arr:Array = [];
			arr.push({
				'rslt':{'str':1}
			});
			//arr.push({
				//'cond':['str','*', 97, 20],
				//'rslt':{'def':1999},
				//'priority':-1
			//});
			arr.push({
				'cond':['hero_star','>', 11],
				'rslt':{'army[0].atk':13}
			});
			arr.push({
				'cond':['str','>=', 12],
				'rslt':{'str':5},
				'priority':1
			});
			arr.push({
				'cond':['sex','=',1],
				'rslt':{'army[0].atkBase':13}
			});
			return arr;
		}
	}

}