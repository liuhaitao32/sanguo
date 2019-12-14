package sg.fight.test
{
	import laya.events.Event;
	import laya.net.LocalStorage;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientFight;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import sg.model.ModelHero;
	import sg.model.ModelOfficial;
	import sg.model.ModelPrepare;
	import sg.model.ModelSkill;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import ui.battle.fightTestTroopUI;
	
	/**
	 * 测试模式-1，修改部队属性
	 * @author ...
	 */
	public class TestFightTroop extends fightTestTroopUI
	{
		public var troopIndex:int;
		///技能选项框*4
		public var skillArr:Array;
		
		public var data:Object;
		///上一次存储的json转prepare前对象
		public var inputData:Object;
		
		public var hasInit:Boolean = false;
		
		public var statistics:TestStatistics;
		
		public var testBeast:TestBeast;
		
		///需要缓存纪录的键
		static public var saveLocalKeys:Object = {
			'openArr':1, 'armyTypeArr':1, 'playerArr':1, 'awakenArr':1, 'fateArr':1, 'politicsArr':1,
			'equipArr':1, 'starArr':1, 'scienceArr':1, 'adjutantArr':1, 'officialArr':1, 'titleArr':1, 'legendArr':1, 'formationArr':1, 'spiritArr':1,
			'hpPointArr':1, 'proudArr':1, 'openSkillArr':1, 'beastArr':1, 'openBeastArr':1, 'useJsonArr':1   
		};
		
		///左右  [英雄 星级 等级 技级 兵段 兵阶 兵科 官邸级（演武场/3） 幕府]
		static public var openArr:Array;
		///强制修改的兵种 左右
		static public var armyTypeArr:Array;
		///是否是玩家 左右
		static public var playerArr:Array;
		///是否是觉醒 左右
		static public var awakenArr:Array;
		///是否满宿命 左右
		static public var fateArr:Array;
		///是否满内政技 左右
		static public var politicsArr:Array;
		
		///使用预设的宝物组 左右
		static public var equipArr:Array;
		///使用预设的星辰组 左右
		static public var starArr:Array;
		///使用预设的科技组 左右
		static public var scienceArr:Array;
		///使用预设的副将组 左右
		static public var adjutantArr:Array;
		///使用预设的官职 左右
		static public var officialArr:Array;
		///使用预设的称号 左右
		static public var titleArr:Array;
		///使用预设的传奇 左右
		static public var legendArr:Array;
		///使用预设的阵法 左右
		static public var formationArr:Array;
		///使用预设的激励 左右
		static public var spiritArr:Array;
		
		///使用预设的兵力比例 左右
		static public var hpPointArr:Array;
		///使用预设的傲气 左右
		static public var proudArr:Array;
		
		///左右  类别位置只有4个  技能索引  [[[1,0,1],[1,1,0],[0,0,1],[1,1,1]],[。。。]]
		static public var openSkillArr:Array;
		
		
		///是否整体使用预设的兽灵 左右
		static public var openBeastArr:Array;
		///兽灵数据 左右，内部有8。最后一位表示是否开启
		static public var beastArr:Array;
		
		///当前实例 左右
		static public var currentArr:Array = [null,null];
		///使用输入的json 左右
		static public var useJsonArr:Array;
		static public var jsonStrArr:Array;
		static public var isInit:Boolean;
		
		public function TestFightTroop(index:int,statistics:TestStatistics)
		{
			this['noAlignByPC'] = 1;
			super();
			
			this.troopIndex = index;
			this.statistics = statistics;
			if (index == 0)
			{
				this.left = 0;
			}
			else
			{
				this.right = 0;
			}
			TestFightTroop.currentArr[index] = this;
			TestFightTroop.initStaticData();
			
			this.once(Event.ADDED, this, this.initAll);
		}
		
		public function initAll():void
		{
			//this.initData();
			this.initUI();
			this.initData();
		}
		
		public function initUI():void
		{
			this.skillArr = [];
			var ui:TestFightTroopSkill;
			for (var i:int = 0; i < 4; i++)
			{
				ui = new TestFightTroopSkill(i, this);
				this.boxSkill.addChild(ui);
				this.skillArr.push(ui);
			}
			this.testBeast = new TestBeast(this);
			this.boxBeast.addChild(testBeast);
			this.boxBeast.visible = false;
			
			//this.checkBoxPlayer.selected = TestFightTroop.playerArr[this.troopIndex];
			this.checkBoxPlayer.clickHandler = new Handler(this, this.onChangeCheckBoxPlayer);
			EffectManager.bindMouseTips(this.checkBoxPlayer, '玩家间对决，使用战力补偿');
			//this.checkBoxAwaken.selected = TestFightTroop.awakenArr[this.troopIndex];
			this.checkBoxAwaken.clickHandler = new Handler(this, this.onChangeCheckBoxAwaken);
			EffectManager.bindMouseTips(this.checkBoxAwaken, '神将，获得觉醒天赋');
			//this.checkBoxFate.selected = TestFightTroop.fateArr[this.troopIndex];
			this.checkBoxFate.clickHandler = new Handler(this, this.onChangeCheckBoxFate);
			EffectManager.bindMouseTips(this.checkBoxFate, '解锁全部宿命，并模拟同时上阵');
			//this.checkBoxPolitics.selected = TestFightTroop.politicsArr[this.troopIndex];
			this.checkBoxPolitics.clickHandler = new Handler(this, this.onChangeCheckBoxPolitics);
			EffectManager.bindMouseTips(this.checkBoxPolitics, '所有内政技满级，确保激活天赋');
			
			//this.checkBoxBeast.selected = TestFightTroop.openBeastArr[this.troopIndex];
			this.checkBoxBeast.on(Event.CHANGE, this, this.onChangeCheckBoxBeast);
			//this.checkBoxBeast.clickHandler = new Handler(this, this.onChangeCheckBoxBeast);
			this.btnBeast.on(Event.CLICK, this, this.onBtnBeast);
			

			

			//ui = new TestFightTroopSkill(1.5, this);
			//ui.list.array = [ModelSkill.getModel('skill201'), ModelSkill.getModel('skill202'), ModelSkill.getModel('skill203')];
			//this.boxSkill.addChild(ui);

			
			this.hsLv.on(Event.CHANGE, this, this.onChangeLv);
			this.hsStar.on(Event.CHANGE, this, this.onChangeStar);
			this.hsSkillLv.on(Event.CHANGE, this, this.onChangeSkillLv);
			this.hsArmyRank.on(Event.CHANGE, this, this.onChangeArmyRank);
			this.hsArmyLv.on(Event.CHANGE, this, this.onChangeArmyLv);
			this.hsArmyAdd.on(Event.CHANGE, this, this.onChangeArmyAdd);
			this.hsBuild.on(Event.CHANGE, this, this.onChangeBuild);
			this.hsShogun.on(Event.CHANGE, this, this.onChangeShogun);
			this.hsShogun.max = 1.34;
			
			this.inputPrepare.leading = 5;
			//this.inputPrepare.fontSize = 20;
			this.inputPrepare.on(Event.INPUT, this, this.onChangeInputPrepare);
			this.inputPrepare.text = TestFightTroop.jsonStrArr[this.troopIndex];
			this.onChangeInputPrepare(true);
			this.updateUseJson();
			this.uiPower.on(Event.CLICK, this, this.onChangeUseJson);
		}
		
		static public function initStaticData():void
		{
			//只执行一次
			if (!TestFightTroop.isInit)
			{
				//如果之前本机有缓存，使用缓存数据，否则使用后台配置
				
				var temp:Object;
				var key:String;
				//选项缓存
				temp = LocalStorage.getJSON('testFightTroopOption');
				if (temp){
					for (key in TestFightTroop.saveLocalKeys){
						TestFightTroop[key] = temp[key];
					}
				}
				else{
					for (key in TestFightTroop.saveLocalKeys){
						TestFightTroop[key] = null;
					}
				}
				if (!TestFightTroop.openArr)
					TestFightTroop.openArr = [ConfigFight.testInitArr.concat(), ConfigFight.testInitArr.concat()];
				if (!TestFightTroop.playerArr)
					TestFightTroop.playerArr = [1, 1];
				if (!TestFightTroop.awakenArr)
					TestFightTroop.awakenArr = [1, 1];
				if (!TestFightTroop.fateArr)
					TestFightTroop.fateArr = [1, 1];
				if (!TestFightTroop.politicsArr)
					TestFightTroop.politicsArr = [1, 1];
					
				if (!TestFightTroop.equipArr)
					TestFightTroop.equipArr = [0, 0];
				if (!TestFightTroop.starArr)
					TestFightTroop.starArr = [0, 0];
				if (!TestFightTroop.scienceArr)
					TestFightTroop.scienceArr = [0, 0];
				if (!TestFightTroop.adjutantArr)
					TestFightTroop.adjutantArr = [0, 0];
				if (!TestFightTroop.officialArr)
					TestFightTroop.officialArr = [0, 0];
				if (!TestFightTroop.titleArr)
					TestFightTroop.titleArr = [0, 0];
				if (!TestFightTroop.legendArr)
					TestFightTroop.legendArr = [0, 0];
				if (!TestFightTroop.formationArr)
					TestFightTroop.formationArr = [0, 0];
				if (!TestFightTroop.spiritArr)
					TestFightTroop.spiritArr = [0, 0];
					
				if (!TestFightTroop.hpPointArr)
					TestFightTroop.hpPointArr = [0, 0];
				if (!TestFightTroop.proudArr)
					TestFightTroop.proudArr = [0, 0];
				
				if (!TestFightTroop.openSkillArr)
					TestFightTroop.openSkillArr = [[],[]];
					
				if (!TestFightTroop.beastArr)
					TestFightTroop.beastArr = [FightUtils.clone(ConfigFight.testBeasts), FightUtils.clone(ConfigFight.testBeasts)];
				if (!TestFightTroop.openBeastArr)
					TestFightTroop.openBeastArr = [0, 0];
					
				if(!TestFightTroop.useJsonArr)
					TestFightTroop.useJsonArr = [0, 0];
					
				if (!TestFightTroop.armyTypeArr){
					var hid:String = TestFightTroop.openArr[0][0];
					var heroCfg:Object = ConfigServer.hero[hid];
					var arr:Array = heroCfg.army;
					TestFightTroop.armyTypeArr = [arr.concat(), arr.concat()];
				}

				
				//json缓存
				var testFightTroopJsonArr:Array;
				temp = LocalStorage.getJSON('testFightTroopJson');
				if (temp){
					testFightTroopJsonArr = temp.testFightTroop;
				}
				else{
					testFightTroopJsonArr = FightUtils.clone(ConfigServer.fight.testJsonStrs);
				}
				TestFightTroop.jsonStrArr = testFightTroopJsonArr;
				
				TestFightTroop.isInit = true;
			}

		}
		
		/**
		 * 包装保存testFightTroop数据（json）
		 */
		static public function saveLocalJson():void
		{
			var obj:Object = {};
			obj.testFightTroop = TestFightTroop.jsonStrArr;
			LocalStorage.setJSON('testFightTroopJson', obj);
		}
		/**
		 * 包装保存testFightTroop数据（选项）
		 */
		static public function saveLocalJsonOption():void
		{
			var obj:Object = {};
			var key:String;
			for (key in TestFightTroop.saveLocalKeys){
				obj[key] = TestFightTroop[key];
			}
			LocalStorage.setJSON('testFightTroopOption', obj);
		}
		
		/**
		 * 清空testFightTroop数据并使用后台数据重新初始化
		 */
		static public function clearLocal():void
		{
			LocalStorage.removeItem('testFightTroopJson');
			LocalStorage.removeItem('testFightTroopOption');
			TestFightTroop.isInit = false;
			TestFightTroop.initStaticData();
			for (var i:int = 0; i < 2; i++) 
			{
				var testFightTroop:TestFightTroop = TestFightTroop.currentArr[i];
				if (testFightTroop){
					testFightTroop.initData();
					//testFightTroop.inputPrepare.on(Event.INPUT, this, this.onChangeInputPrepare);
					testFightTroop.inputPrepare.text = TestFightTroop.jsonStrArr[i];
					testFightTroop.onChangeInputPrepare(true);
					testFightTroop.updateUseJson();
					
					testFightTroop.testBeast.updateAnyData();
				}
			}
			FightMain.instance.ui.showTipsTxt('对战模拟：清理json和选项缓存');
		}
		
		override public function initData():void
		{
			//initStaticData();

			this.hasInit = false;
			var arr:Array = TestFightTroop.openArr[this.troopIndex];
			
			this.checkBoxPlayer.selected = TestFightTroop.playerArr[this.troopIndex];
			this.checkBoxAwaken.selected = TestFightTroop.awakenArr[this.troopIndex];
			this.checkBoxFate.selected = TestFightTroop.fateArr[this.troopIndex];
			this.checkBoxPolitics.selected = TestFightTroop.politicsArr[this.troopIndex];
			this.checkBoxBeast.selected = TestFightTroop.openBeastArr[this.troopIndex];

			this.initHid(arr[0]);
			this.initDefault();
			this.initEquips();
			this.initStars();
			this.initSciences();
			this.initAdjutants();
			this.initOfficials();
			this.initTitles();
			this.initLegends();
			this.initFormations();
			this.initSpirits();
			this.initHpPoints();
			this.initProuds();
			
			this.updateHSliders();
			this.updateProps();

			this.hasInit = true;
			//this.updatePower();
		}
		///更新当前属性显示
		public function updateProps():void{
			this.uiPower.setNum(this.getCurrData().power);
		}
		
		public function updateHSliders():void{
			var arr:Array = TestFightTroop.openArr[this.troopIndex];
			this.hsStar.value = arr[1];
			this.hsLv.value = arr[2];
			
			this.hsSkillLv.value = arr[3];
			this.hsArmyRank.value = arr[4];
			this.hsArmyLv.value = arr[5];
			this.hsArmyAdd.value = arr[6];
			
			this.hsBuild.value = arr[7];
			this.hsShogun.value = arr[8];
			
			this.updateChangeLv();
			this.updateChangeStar();
			this.updateChangeSkillLv();
			this.updateChangeArmyRank();
			this.updateChangeArmyLv();
			this.updateChangeArmyAdd();
			this.updateChangeBuild();
			this.updateChangeShogun();
		}


		private function initHid(currHid:String):void
		{
			this.comboHid.off(Event.CHANGE, this, this.onChangeHid);
			this.comboHid.scrollBar.hide = true;
			//this.initDefaultSkills(currHid);
			this.initSkills(currHid);
			var i:int;
			var len:int = ConfigFight.testHids.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var hid:String = ConfigFight.testHids[i];
				var heroCfg:Object = ConfigServer.hero[hid];
				if (heroCfg){
					str += ModelHero.getHeroExtendName(hid);
				}
				else{
					str += hid;
				}
				
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboHid.labels = str;
			i = ConfigFight.testHids.indexOf(currHid);
			if (i < 0) i = 0;
			//this.hidIndex = i;
			this.comboHid.selectedIndex = i;
			this.comboHid.on(Event.CHANGE, this, this.onChangeHid);
			//开关觉醒显示
			this.updateAwaken(currHid);
		
			//this.btnMode.text.text = "模式" + TestFightData.testMode.toString();
		}
		private function initDefault():void
		{
			this.comboDefault.off(Event.CHANGE, this, this.onChangeDefault);
			this.comboDefault.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testLvArr2.length;
			var str:String = '选择预设等级,';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testLvArr2[i];
				var msg:String = '预设' + arr[1]+ '级';
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboDefault.labels = str;

			this.comboDefault.selectedIndex = 0;
			this.comboDefault.on(Event.CHANGE, this, this.onChangeDefault);
		}
		private function initEquips():void
		{
			this.comboEquip.off(Event.CHANGE, this, this.onChangeEquips);
			this.comboEquip.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testEquips.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testEquips[i];
				var msg:String = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboEquip.labels = str;

			this.comboEquip.selectedIndex = TestFightTroop.equipArr[this.troopIndex];
			this.comboEquip.on(Event.CHANGE, this, this.onChangeEquips);
		}
		private function initStars():void
		{
			this.comboStar.off(Event.CHANGE, this, this.onChangeStars);
			this.comboStar.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testStars.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testStars[i];
				var msg:String = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboStar.labels = str;

			this.comboStar.selectedIndex = TestFightTroop.starArr[this.troopIndex];
			this.comboStar.on(Event.CHANGE, this, this.onChangeStars);
		}
		private function initSciences():void
		{
			this.comboScience.off(Event.CHANGE, this, this.onChangeSciences);
			this.comboScience.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testSciences.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testSciences[i];
				var msg:String = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboScience.labels = str;

			this.comboScience.selectedIndex = TestFightTroop.scienceArr[this.troopIndex];
			this.comboScience.on(Event.CHANGE, this, this.onChangeSciences);
		}
		private function initAdjutants():void
		{
			this.comboAdjutant.off(Event.CHANGE, this, this.onChangeAdjutants);
			this.comboAdjutant.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testAdjutants.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testAdjutants[i];
				var msg:String = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboAdjutant.labels = str;

			this.comboAdjutant.selectedIndex = TestFightTroop.adjutantArr[this.troopIndex];
			this.comboAdjutant.on(Event.CHANGE, this, this.onChangeAdjutants);
		}
		private function initOfficials():void
		{
			this.comboOfficial.off(Event.CHANGE, this, this.onChangeOfficials);
			this.comboOfficial.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testOfficials.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var value:* = ConfigFight.testOfficials[i];
				var msg:String;
				if (i == 0){
					msg = value;
				}
				else{
					msg = ModelOfficial.getOfficerName(value, 5, this.troopIndex);
				}
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboOfficial.labels = str;

			this.comboOfficial.selectedIndex = TestFightTroop.officialArr[this.troopIndex];
			this.comboOfficial.on(Event.CHANGE, this, this.onChangeOfficials);
		}
		private function initTitles():void
		{
			this.comboTitle.off(Event.CHANGE, this, this.onChangeTitles);
			this.comboTitle.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testTitles.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var value:* = ConfigFight.testTitles[i];
				var msg:String;
				if (i == 0){
					msg = value;
				}
				else{
					msg = Tools.getMsgById(value);
				}
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboTitle.labels = str;

			this.comboTitle.selectedIndex = TestFightTroop.titleArr[this.troopIndex];
			this.comboTitle.on(Event.CHANGE, this, this.onChangeTitles);
		}
		private function initLegends():void
		{
			this.comboLegend.off(Event.CHANGE, this, this.onChangeLegends);
			this.comboLegend.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testLegends.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testLegends[i];
				var msg:String = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboLegend.labels = str;

			this.comboLegend.selectedIndex = TestFightTroop.legendArr[this.troopIndex];
			this.comboLegend.on(Event.CHANGE, this, this.onChangeLegends);
		}
		private function initFormations():void
		{
			this.comboFormation.off(Event.CHANGE, this, this.onChangeFormations);
			this.comboFormation.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testFormations.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testFormations[i];
				var msg:String = arr[0];
				if (!msg)
					msg = Tools.getMsgById('formation' + arr[1]);
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboFormation.labels = str;

			this.comboFormation.selectedIndex = TestFightTroop.formationArr[this.troopIndex];
			this.comboFormation.on(Event.CHANGE, this, this.onChangeFormations);
		}
		private function initSpirits():void
		{
			this.comboSpirit.off(Event.CHANGE, this, this.onChangeSpirits);
			this.comboSpirit.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testSpirits.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testSpirits[i];
				var msg:String = arr[0];
				if (!msg)
					msg = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboSpirit.labels = str;

			this.comboSpirit.selectedIndex = TestFightTroop.spiritArr[this.troopIndex];
			this.comboSpirit.on(Event.CHANGE, this, this.onChangeSpirits);
		}
		private function initHpPoints():void
		{
			this.comboHpPoint.off(Event.CHANGE, this, this.onChangeHpPoints);
			this.comboHpPoint.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testHpPoints.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testHpPoints[i];
				var msg:String = arr[0];
				if (!msg)
					msg = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboHpPoint.labels = str;

			this.comboHpPoint.selectedIndex = TestFightTroop.hpPointArr[this.troopIndex];
			this.comboHpPoint.on(Event.CHANGE, this, this.onChangeHpPoints);
		}
		private function initProuds():void
		{
			this.comboProud.off(Event.CHANGE, this, this.onChangeProuds);
			this.comboProud.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testProuds.length;
			var str:String = '';
			for (i = 0; i < len; i++)
			{
				var arr:Array = ConfigFight.testProuds[i];
				var msg:String = arr[0];
				if (!msg)
					msg = arr[0];
				
				str += msg;
				if (i < len - 1)
				{
					str += ',';
				}
			}
			this.comboProud.labels = str;

			this.comboProud.selectedIndex = TestFightTroop.proudArr[this.troopIndex];
			this.comboProud.on(Event.CHANGE, this, this.onChangeProuds);
		}
		
		
		public function initSkills(currHid:String = null):void
		{
			if (!currHid)
				currHid = this.getCurrHid();
			//var heroCfg:Object = ConfigServer.hero[currHid];
			for (var i:int = 0; i < 4; i++)
			{
				var ui:TestFightTroopSkill = this.skillArr[i];
				if (i == 0)
				{
					ui.setType(4);
				}
				else if (i == 3)
				{
					ui.setType(5);
				}
				else
				{
					ui.setType(armyTypeArr[this.troopIndex][i-1]);
				}
			}
			if(this.hasInit)
				this.updateAllData();
		}
		
		private function onChangeHid():void
		{
			//this.hidIndex = this.comboHid.selectedIndex;
			var currHid:String = ConfigFight.testHids[this.comboHid.selectedIndex];
			var heroCfg:Object = ConfigServer.hero[currHid];
			if(heroCfg){
			
				TestFightTroop.openArr[this.troopIndex][0] = currHid;
				this.updateDefaultSkills(currHid);
				
				var ui1:TestFightTroopSkill = this.skillArr[1];
				ui1.updateArmyType();
				var ui2:TestFightTroopSkill = this.skillArr[2];
				ui2.updateArmyType();
				
				//开关觉醒显示
				this.updateAwaken(currHid);
				this.updateAllData();
			}
			else{
				
			}
		}
		private function updateAwaken(currHid:String):void
		{
			var inbornCfg:Object = ConfigServer.inborn[currHid + 'a'];
			if (inbornCfg){
				this.checkBoxAwaken.gray = false;
			}else{
				this.checkBoxAwaken.gray = true;		
			}
		}
		
		private function onChangeDefault():void
		{
			var index:int = this.comboDefault.selectedIndex -1;
			if(index >= 0){
				var testLvArr:Array = ConfigFight.testLvArr2[index];
				TestFightTroop.openArr[this.troopIndex][1] = testLvArr[0];
				TestFightTroop.openArr[this.troopIndex][2] = testLvArr[1];
				TestFightTroop.openArr[this.troopIndex][3] = testLvArr[2];
				TestFightTroop.openArr[this.troopIndex][4] = testLvArr[3];
				TestFightTroop.openArr[this.troopIndex][5] = testLvArr[4];
				TestFightTroop.openArr[this.troopIndex][6] = testLvArr[5];
				TestFightTroop.openArr[this.troopIndex][7] = testLvArr[6];
				TestFightTroop.openArr[this.troopIndex][8] = testLvArr[7];
				
				this.comboDefault.selectedIndex = 0;
				this.updateAllData();
				this.updateHSliders();
			}
		}
		
		private function onChangeEquips():void
		{
			TestFightTroop.equipArr[this.troopIndex] = this.comboEquip.selectedIndex;
			this.updateAllData();
		}
		private function onChangeStars():void
		{
			TestFightTroop.starArr[this.troopIndex] = this.comboStar.selectedIndex;
			this.updateAllData();
		}
		
		private function onChangeSciences():void
		{
			TestFightTroop.scienceArr[this.troopIndex] = this.comboScience.selectedIndex;
			this.updateAllData();
		}
		private function onChangeAdjutants():void
		{
			TestFightTroop.adjutantArr[this.troopIndex] = this.comboAdjutant.selectedIndex;
			this.updateAllData();
		}
		
		private function onChangeOfficials():void
		{
			TestFightTroop.officialArr[this.troopIndex] = this.comboOfficial.selectedIndex;
			this.updateAllData();
		}
		private function onChangeTitles():void
		{
			TestFightTroop.titleArr[this.troopIndex] = this.comboTitle.selectedIndex;
			this.updateAllData();
		}
		private function onChangeLegends():void
		{
			TestFightTroop.legendArr[this.troopIndex] = this.comboLegend.selectedIndex;
			this.updateAllData();
		}
		private function onChangeFormations():void
		{
			TestFightTroop.formationArr[this.troopIndex] = this.comboFormation.selectedIndex;
			this.updateAllData();
		}
		private function onChangeSpirits():void
		{
			TestFightTroop.spiritArr[this.troopIndex] = this.comboSpirit.selectedIndex;
			//this.updateAllData();
			TestFightTroop.saveLocalJsonOption();
		}
		private function onChangeHpPoints():void
		{
			TestFightTroop.hpPointArr[this.troopIndex] = this.comboHpPoint.selectedIndex;
			TestFightTroop.saveLocalJsonOption();
		}
		private function onChangeProuds():void
		{
			TestFightTroop.proudArr[this.troopIndex] = this.comboProud.selectedIndex;
			TestFightTroop.saveLocalJsonOption();
		}
		
		/**
		 * 切换英雄，自动适配技能
		 */
		public function updateDefaultSkills(currHid:String):void
		{
			if (!TestStatistics.useDefaultSkills)
				return;
			var skills:Object;
			var defaultCfg:Object = ConfigFight.testDefaultSkills;
			var heroCfg:Object = ConfigServer.hero[currHid];
			if (defaultCfg[currHid]){
				skills = defaultCfg[currHid];
			}
			else{
				var key:String = 'type' + heroCfg.type + 'sex' + heroCfg.sex;
				if (defaultCfg[key]){
					skills = defaultCfg[key];
				}
				else {
					skills = defaultCfg['default'];
				}
			}
			//修改默认英雄和辅助技能
			var i:int;
			var smd:ModelSkill;
			var currListArr:Array = TestFightTroop.openSkillArr[this.troopIndex];
			var openSkillArr0:Array = currListArr[0];
			var openSkillArr3:Array = currListArr[3];
			var ui0:TestFightTroopSkill = this.skillArr[0];
			var ui1:TestFightTroopSkill = this.skillArr[1];
			var ui2:TestFightTroopSkill = this.skillArr[2];
			var ui3:TestFightTroopSkill = this.skillArr[3];
			//比对与配置相同的技能，指定为已选
			var len:int;
			len = ui0.listData.length;
			for (i = 0; i < len; i++) 
			{
				smd = ui0.listData[i];
				openSkillArr0[i] = skills[smd.id]?1:0;
			}
			len = ui3.listData.length;
			for (i = 0; i < len; i++) 
			{
				smd = ui3.listData[i];
				openSkillArr3[i] = skills[smd.id]?1:0;
			}
			
			
			ui0.setType(4);
			ui1.setType(heroCfg.army[0]);
			ui2.setType(heroCfg.army[1]);
			ui3.setType(5);
		}
		
		
		public function onChangeStar():void
		{
			this.updateChangeStar();
			TestFightTroop.openArr[this.troopIndex][1] = this.hsStar.value;
			this.updatePropData();
		}
		public function updateChangeStar():void
		{
			this.tStar.text = '英雄星级 ' + this.hsStar.value;
		}

		
		
		public function onChangeLv():void
		{
			this.updateChangeLv();
			TestFightTroop.openArr[this.troopIndex][2] = this.hsLv.value;
			this.updatePropData();
		}
		public function updateChangeLv():void
		{
			this.tLv.text = '英雄等级 ' + this.hsLv.value;
		}

		
		public function onChangeSkillLv():void
		{
			this.updateChangeSkillLv();
			TestFightTroop.openArr[this.troopIndex][3] = this.hsSkillLv.value;
			if (this.hasInit){
				this.initSkills();
			}
		}
		public function updateChangeSkillLv():void
		{
			this.tSkillLv.text = '技能等级 ' + this.hsSkillLv.value;
		}
		
		public function onChangeArmyRank():void
		{
			this.updateChangeArmyRank();
			TestFightTroop.openArr[this.troopIndex][4] = this.hsArmyRank.value;
			this.updatePropData();
		}
		public function updateChangeArmyRank():void
		{
			this.tArmyRank.text = '兵种段位 ' + this.hsArmyRank.value;
		}
		
		public function onChangeArmyLv():void
		{
			this.updateChangeArmyLv();
			TestFightTroop.openArr[this.troopIndex][5] = this.hsArmyLv.value;
			this.updatePropData();
		}
		public function updateChangeArmyLv():void
		{
			this.tArmyLv.text = '兵种阶级 ' + this.hsArmyLv.value;
		}
		
		public function onChangeArmyAdd():void
		{
			this.updateChangeArmyAdd();
			TestFightTroop.openArr[this.troopIndex][6] = this.hsArmyAdd.value;
			this.updatePropData();
		}
		public function updateChangeArmyAdd():void
		{
			this.tArmyAdd.text = '兵种科技 ' + this.hsArmyAdd.value;
		}
		
		public function onChangeBuild():void
		{
			this.updateChangeBuild();
			TestFightTroop.openArr[this.troopIndex][7] = this.hsBuild.value;
			this.updatePropData();
		}
		public function updateChangeBuild():void
		{
			this.tBuild.text = '官邸等级 ' + this.hsBuild.value;
		}
		
		public function onChangeShogun():void
		{
			this.updateChangeShogun();
			TestFightTroop.openArr[this.troopIndex][8] = this.hsShogun.value;
			this.updatePropData();
		}
		public function updateChangeShogun():void
		{
			this.tShogun.text = '幕府加成 ' + Tools.percentFormat(this.hsShogun.value);
		}
		
		public function updateTroopSkillList():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				var ui:TestFightTroopSkill = this.skillArr[i];
				ui.list.array = ui.listData;
			}
		}
		public function onChangeCheckBoxPlayer():void
		{
			TestFightTroop.playerArr[this.troopIndex] = this.checkBoxPlayer.selected?1:0;
			this.updateAllData();
		}
		public function onChangeCheckBoxAwaken():void
		{
			TestFightTroop.awakenArr[this.troopIndex] = this.checkBoxAwaken.selected?1:0;
			this.updateAllData();
		}
		public function onChangeCheckBoxFate():void
		{
			TestFightTroop.fateArr[this.troopIndex] = this.checkBoxFate.selected?1:0;
			this.updateAllData();
		}
		public function onChangeCheckBoxPolitics():void
		{
			TestFightTroop.politicsArr[this.troopIndex] = this.checkBoxPolitics.selected?1:0;
			this.updateAllData();
		}
		
		public function onChangeCheckBoxBeast():void
		{
			TestFightTroop.openBeastArr[this.troopIndex] = this.checkBoxBeast.selected?1:0;
			this.updateAllData();
		}
		
		public function onBtnBeast():void
		{
			var b:Boolean = !this.boxBeast.visible;
			this.boxBeast.visible = b;
			this.boxSkill.visible = !b;
			if (b){
				this.checkBoxBeast.selected = true;
				//TestFightTroop.openBeastArr[this.troopIndex] = t;
				//this.updateAllData();
			}
			
			//this.updateBeast();
		}
		
		//public function onBtnFight():void
		//{
			//if(FightMain.instance.ui.testUI)
				//FightMain.instance.ui.testUI.startChangeFight();
		//}
		
		public function updateAllData():void
		{
			if (!this.hasInit)
				return;
			this.statistics.updateAllData(this.troopIndex);
			TestFightTroop.saveLocalJsonOption();
		}
		private function updatePropData():void
		{
			if (!this.hasInit)
				return;
			this.statistics.updatePropData(this.troopIndex);
			TestFightTroop.saveLocalJsonOption();
		}

		public function getCurrHid():String
		{
			var obj:Object = this.getJson();
			if (obj){
				return obj.hid;
			}
			return TestFightTroop.openArr[this.troopIndex][0];
		}
		/**
		 * 获得当前输入的数据
		 */
		public function getJson():Object
		{
			if (TestFightTroop.useJsonArr[this.troopIndex])
			{
				return this.inputData;
			}
			return null;
		}
		/**
		 * 修改输入数据
		 */
		public function onChangeInputPrepare(isForce:*):void
		{
			if (isForce || TestFightTroop.useJsonArr[this.troopIndex])
			{
				var obj:Object;
				var b:Boolean = false;
				try 
				{
					obj = JSON.parse(this.inputPrepare.text);
					if (obj){
						if(!obj.hid || !ConfigServer.hero[obj.hid]){
							obj.hid = 'hero701';
						}
						//设定为玩家
						if(!obj.uid){
							obj.uid = 1000 + this.troopIndex;
						}
						if(!obj.hasOwnProperty('country')){
							obj.country = this.troopIndex;
						}
						this.packOthers(obj,false);
					}
					//this.updateAllData();
					b = true;	
				}
				catch (err:Error)
				{
					trace(err);
				}
				if (b){
					TestFightTroop.jsonStrArr[this.troopIndex] = this.inputPrepare.text;
					this.inputData = obj;
					this.tHeroName.text = ModelHero.getHeroExtendName(obj.hid, obj.awaken);
					if(TestFightTroop.isInit){
						TestFightTroop.saveLocalJson();
					}
				}
				
				this.updateAllData();
			}
		}
		public function onChangeUseJson():void
		{
			TestFightTroop.useJsonArr[this.troopIndex] = !TestFightTroop.useJsonArr[this.troopIndex];
			this.updateUseJson();
			if(TestFightTroop.useJsonArr[this.troopIndex]){
				this.onChangeInputPrepare(true);
			}
			else{
				this.updateAllData();
			}
		}
		public function updateUseJson():void
		{
			var b:Boolean = TestFightTroop.useJsonArr[this.troopIndex];
			this.boxJson.visible = b;
			this.boxMain.visible = !b;
			//this.tHeroName.text = ModelHero.getHeroExtendName(this.getCurrHid());
		}

		/**
		 * 获得当前某个技能的等级
		 */
		public function getCurrSkillLv(smd:ModelSkill):int
		{
			return TestFightTroop.formatSkillLv(this.getCurrHid(), smd, TestFightTroop.openArr[this.troopIndex][3]);
		}
		/**
		 * 获得对应某个技能的等级
		 */
		static public function formatSkillLv(hid:String, smd:ModelSkill, baseSkillLv:int):int
		{
			var bornLv:int = getHeroBornSkillLv(hid, smd);
			//天生技能等级有所加成
			var maxLv:int = smd.getMaxLv();
			var lv:int =  Math.max(bornLv,Math.min(maxLv,Math.ceil(baseSkillLv * maxLv / 25 + bornLv * 0.3)));
			return lv;
		}
		/**
		 * 获得某英雄某技能的天生等级
		 */
		static public function getHeroBornSkillLv(hid:String, smd:ModelSkill):int
		{
			var cfg:Object = ConfigServer.hero[hid].skill;
			if (cfg && cfg[smd.id]){
				return cfg[smd.id];
			}
			return 0;
		}
		
		/**
		 * 获得当前装备数据
		 */
		public function getCurrEquipArr():Array
		{
			var index:int = TestFightTroop.equipArr[this.troopIndex];
			return ConfigFight.testEquips[index][1];
		}
		
		/**
		 * 获得当前星辰数据
		 */
		public function getCurrStarData():Object
		{
			var index:int = TestFightTroop.starArr[this.troopIndex];
			return ConfigFight.testStars[index][1];
		}
		/**
		 * 获得当前科技数据
		 */
		public function getCurrScienceData():Object
		{
			var index:int = TestFightTroop.scienceArr[this.troopIndex];
			return ConfigFight.testSciences[index][1];
		}
		/**
		 * 获得当前副将数据
		 */
		public function getCurrAdjutantArr():Array
		{
			var index:int = TestFightTroop.adjutantArr[this.troopIndex];
			return ConfigFight.testAdjutants[index][1];
		}
		/**
		 * 获得当前官职数据
		 */
		public function getCurrOfficial():int
		{
			var index:int = TestFightTroop.officialArr[this.troopIndex];
			var value:* = ConfigFight.testOfficials[index];
			if (value is int){
				return value;
			}
			else{
				return -100;
			}
		}

		/**
		 * 获得当前称号数据
		 */
		public function getCurrTitle():String
		{
			var index:int = TestFightTroop.titleArr[this.troopIndex];
			if (index > 0){
				return ConfigFight.testTitles[index];
			}
			else{
				return '';
			}
		}
		/**
		 * 获得当前传奇数据
		 */
		public function getCurrLegend():Object
		{
			var index:int = TestFightTroop.legendArr[this.troopIndex];
			return ConfigFight.testLegends[index][1];
		}
		/**
		 * 获得当前阵法数据
		 */
		public function getCurrFormation():Array
		{
			var index:int = TestFightTroop.formationArr[this.troopIndex];
			return ConfigFight.testFormations[index][1];
		}
		/**
		 * 获得当前激励数据
		 */
		public function getCurrSpirit():Array
		{
			var index:int = TestFightTroop.spiritArr[this.troopIndex];
			return ConfigFight.testSpirits[index][1];
		}
		/**
		 * 获得当前兵力比例
		 */
		public function getCurrHpPoint(armyIndex:int):int
		{
			var index:int = TestFightTroop.hpPointArr[this.troopIndex];
			var value:* = ConfigFight.testHpPoints[index][1];
			if(value is Array){
				return value[armyIndex];
			}
			else{
				return value;
			}
		}
		/**
		 * 获得当前傲气
		 */
		public function getCurrProud():int
		{
			var index:int = TestFightTroop.proudArr[this.troopIndex];
			return ConfigFight.testProuds[index][1];
		}
		
		/**
		 * 获得当前建筑数据
		 */
		public function getBuildArr(lv:int):Array
		{
			return [Math.floor(lv/3),lv];
		}
		/**
		 * 获得当前幕府数据
		 */
		public function getShogunArr(value:Number):Array
		{
			return [value,value,value];
		}

		
		/**
		 * 按当前特性选择，统一包装数据对象
		 */
		public function packCurrData(obj:Object):Object
		{
			obj.uid = this.troopIndex + 1;
			if (!TestFightTroop.playerArr[this.troopIndex])
				obj.uid = -obj.uid;
			obj.country = this.troopIndex;
			obj.milepost = 5;
			
			obj.hid = this.getCurrHid();
			obj.equip = this.getCurrEquipArr();
			obj.star = this.getCurrStarData();
			obj.science_passive = this.getCurrScienceData();
			obj.adjutant = this.getCurrAdjutantArr();
			obj.official = this.getCurrOfficial();
			obj.title = this.getCurrTitle();
			obj.legend = this.getCurrLegend();
			obj.formation = this.getCurrFormation();

			obj.awaken = TestFightTroop.awakenArr[this.troopIndex];
			
			if(obj.uid > 0)
				obj.fate = this.getFateArr();
			
			if (TestFightTroop.openBeastArr[this.troopIndex]){
				//开启了兽灵
				obj.beast = TestFightTroop.beastArr[this.troopIndex];
			}
			
			return obj;
		}
		/**
		 * 按当前特性选择，最终统一包装数据对象
		 */
		public function packCurrDataEnd(obj:Object):Object
		{
			var hpPoint0:int = this.getCurrHpPoint(0);
			var hpPoint1:int = this.getCurrHpPoint(1);
			if (hpPoint0 != ConfigFight.ratePoint){
				obj.army[0].hp = Math.ceil(obj.army[0].hpm * FightUtils.pointToPer(hpPoint0));
			}
			if (hpPoint1 != ConfigFight.ratePoint){
				obj.army[1].hp = Math.ceil(obj.army[1].hpm * FightUtils.pointToPer(hpPoint1));
			}
			obj.proud = this.getCurrProud();
			
			this.packOthers(obj,true);
			return obj;
		}
		/**
		 * 包装others数据对象
		 */
		public function packOthers(obj:Object, isCurr:Boolean):Object
		{
			var spiritArr:Array;
			if (obj.uid > 0){
				obj.others = {};
				obj.others.attends = TestStatistics.allAttends;
				if(isCurr){
					spiritArr = this.getCurrSpirit();
					if(spiritArr)
						obj.others.spirit = spiritArr;
				}
			}
			if (!spiritArr){
				//激励至少加上自己
				var cfg:Object = ConfigFight.legendTalentFight;
				if (cfg[obj.hid]){
					if (!obj.others)
						obj.others = {};
					obj.others.spirit = [[obj.hid, obj.hero_star]];
				}
			}
			return obj;
		}
		
		/**
		 * 包装全局较好的others数据对象
		 */
		static public function packGoodOthers(obj:Object):Object
		{
			var spiritArr:Array;
			if (obj.uid > 0){
				obj.others = {};
				obj.others.attends = TestStatistics.allAttends;
			}
			if (!spiritArr){
				//激励至少加上自己
				var cfg:Object = ConfigFight.legendTalentFight;
				if (cfg[obj.hid]){
					if (!obj.others)
						obj.others = {};
					obj.others.spirit = [[obj.hid, obj.hero_star]];
				}
			}
			return obj;
		}
		
		/**
		 * 获得当前档次数据
		 */
		public function getCurrData(isNew:Boolean = false):Object
		{
			var obj:Object;
			if (isNew || !this.data)
			{
				obj = this.getJson();
				if (obj){
					this.data = new ModelPrepare(obj, true).data;
				}
				else{
					//return {};
					obj = {};
					this.packCurrData(obj);

					obj.hero_star = TestFightTroop.openArr[this.troopIndex][1];
					obj.lv = TestFightTroop.openArr[this.troopIndex][2];

					obj.building = this.getBuildArr(TestFightTroop.openArr[this.troopIndex][7]);
					if(TestFightTroop.openArr[this.troopIndex][8])
						obj.shogun = this.getShogunArr(TestFightTroop.openArr[this.troopIndex][8]);
					obj.army = [];
					
					var i:int;
					for (i = 0; i < 2; i++)
					{
						var armyObj:Object = {rank: TestFightTroop.openArr[this.troopIndex][4], lv: TestFightTroop.openArr[this.troopIndex][5], add: [TestFightTroop.openArr[this.troopIndex][6], 0]};
						armyObj.type = TestFightTroop.armyTypeArr[this.troopIndex][i];
						obj.army.push(armyObj);
					}
					
					obj.skill = this.getSkillData(TestFightTroop.openArr[this.troopIndex][3]);

					
					this.data = new ModelPrepare(obj, true).data;
					this.packCurrDataEnd(this.data);
				}
			}
			return this.data;
		}
		/**
		 * 获得模拟档次数据
		 */
		public function getStatisticsData(index:int):Object
		{
			var obj:Object;
			obj = this.getJson();
			if (obj){
				obj = new ModelPrepare(obj, true).data;
				return obj;
			}
			
			var testLvArr:Array = ConfigFight.testLvArr[index];
			obj = {};
			this.packCurrData(obj);
			
			obj.hero_star = testLvArr[0];
			obj.lv = testLvArr[1];
			
			obj.building = this.getBuildArr(testLvArr[6]);
			if(testLvArr[7])
				obj.shogun = this.getShogunArr(testLvArr[7]);
			obj.army = [];
			
			var i:int;
			for (i = 0; i < 2; i++)
			{
				var armyObj:Object = {rank: testLvArr[3], lv: testLvArr[4], add: [testLvArr[5], 0]};
				armyObj.type = TestFightTroop.armyTypeArr[this.troopIndex][i];
				obj.army.push(armyObj);
			}
			
			obj.skill = this.getSkillData(testLvArr[2]);
			
			obj = new ModelPrepare(obj, true).data;
			this.packCurrDataEnd(obj);

			return obj;
		}
		
		/**
		 * 获得技能数据
		 */
		public function getSkillData(baseSkillLv:int):Object
		{
			var i:int;
			var skillObj:Object = {};
			for (i = 0; i < 4; i++)
			{
				var ui:TestFightTroopSkill = this.skillArr[i];
				var arr:Array = ui.list.array;
				for (var j:int = 0; j < arr.length; j++) 
				{
					var smd:ModelSkill = arr[j];
					if(smd['open'+this.troopIndex]){
						skillObj[smd.id] = TestFightTroop.formatSkillLv(this.getCurrHid(), smd, baseSkillLv);
					}
				}
			}
			//如果满内政技能，增加所有内政技
			if (TestFightTroop.politicsArr[this.troopIndex]){
				for (var key:String in ConfigFight.testPoliticsSkills){
					skillObj[key] = ConfigFight.testPoliticsSkills[key];
				}
			}
			
			return skillObj;
		}
		/**
		 * 获得宿命数据
		 */
		public function getFateArr():Array
		{
			if (!TestFightTroop.fateArr[this.troopIndex])
				return [];
			var i:int;
			var hid:String = this.getCurrHid();
			var heroCfg:Object = ConfigServer.hero[hid];
			var fateArr:Array = [];
			for (var key:String in heroCfg.fate){
				fateArr.push(key);
			}
			return fateArr;
		}
	}

}