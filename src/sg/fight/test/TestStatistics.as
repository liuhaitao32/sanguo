package sg.fight.test
{
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightInterface;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightTestStatisticsUI;
	
	/**
	 * 测试模式-1，调整分析战斗胜率
	 * @author ...
	 */
	public class TestStatistics extends fightTestStatisticsUI
	{
		public var testFight:TestFight;
		private var testTroopArr:Array;
		private var testTable:TestTable;
		
		static public var listData:Array;
		static public var userLogs:Object;
		static public var allAttends:Object;

		
		
		static public var visible:Boolean = false;
		///自动使用默认技能
		static public var useDefaultSkills:Boolean = true;
		///解锁所有宿命并且合击生效
		//static public var useAllFate:Boolean = true;
		///使用模式战斗
		static public var useMode:int = -1;
		
		///显示技能编号、战力详细
		static public var showSwitch:Boolean = false;
		///显示战力详细
		//static public var showProp:Boolean = false;
		
		static public var useTable:Boolean = false;
		
		
		public function TestStatistics(testFight:TestFight)
		{
			this['noAlignByPC'] = 1;
			super();
			this.testFight = testFight;
			this.initUI();
			
			this.once(Event.ADDED, this, this.initData);
			//this.initData();
		}
		

		
		public function initUI():void
		{
			this.checkBoxSkill.selected = TestStatistics.useDefaultSkills;
			//this.checkBoxFate.selected = TestStatistics.useAllFate;
			//this.updateUseMode();
			
			this.testTable = new TestTable(this);
			//this.testTable.visible = false;
			this.testTable.y = 140;
			this.addChild(this.testTable);
			this.updateTable();
			
			this.btnCurr.on(Event.CLICK, this.testFight, this.testFight.startStatisticsFight);
			this.btnAll.on(Event.CLICK, this.testFight, this.testFight.statisticsAllFight);
			this.btnTable.on(Event.CLICK, this, this.onTable);
			this.btnClean.on(Event.CLICK, this.testFight, this.testFight.onClearLocal);
			EffectManager.bindMouseTips(this.btnClean, 'ha\nhaha\nhahaha\n要慎重');
			
			//this.btnExport.visible = false;
			//this.checkBox.on(Event.CHANGE, this, this.onChangeCheckBox);
			this.checkBoxSkill.clickHandler = new Handler(this, this.onChangeCheckBoxSkill);
			EffectManager.bindMouseTips(this.checkBoxSkill, '啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦啦');
			//this.checkBoxFate.clickHandler = new Handler(this, this.onChangeCheckBoxFate);
			//this.checkBoxCountry.clickHandler = new Handler(this, this.onChangeCheckBoxCountry);
			//this.checkBoxArena.clickHandler = new Handler(this, this.onChangeCheckBoxArena);
			
			this.list.scrollBar.hide = true;
			this.list.renderHandler = new Handler(this, this.listRender);
			
			
			this.testTroopArr = [];
			var i:int;
			for (i = 0; i < 2; i++)
			{
				var ui:TestFightTroop = new TestFightTroop(i, this);
				//ui.width = 320;
				this.testTroopArr.push(ui);
				this.boxTroop.addChild(ui);
			}
			this.visible = TestStatistics.visible;
			if (TestFightData.testMode != -1){
				this.boxTop.visible = false;
				this.testTroopArr[1].visible = false;
			}
		}
		public function onChangeCheckBoxSkill():void
		{
			TestStatistics.useDefaultSkills = this.checkBoxSkill.selected;
		}
		public function onChangeCheckBoxFate():void
		{
			//TestStatistics.useAllFate = this.checkBoxFate.selected;
			//重算战力
			this.updateAllData(0);
			this.updateAllData(1);
		}
		
		private function initMode():void
		{
			this.comboMode.off(Event.CHANGE, this, this.onChangeMode);
			this.comboMode.scrollBar.hide = true;
			var i:int;
			var len:int = ConfigFight.testModes.length;
			var str:String = '';
			var index:int;
			for (i = 0; i < len; i++)
			{
				str += ConfigFight.testModes[i][0];
				
				if (i < len - 1)
				{
					str += ',';
				}
				
				if (ConfigFight.testModes[i][1] == TestStatistics.useMode){
					index = i;
				}
			}
			this.comboMode.labels = str;
			this.comboMode.selectedIndex = index;
			this.comboMode.on(Event.CHANGE, this, this.onChangeMode);
		}
		public function onChangeMode():void
		{
			TestStatistics.useMode = ConfigFight.testModes[this.comboMode.selectedIndex][1];
			//重算战力
			this.updateAllData(0);
			this.updateAllData(1);
			
			this.testTable.onChangeOther();
		}
		
		
		public function onTable():void
		{
			TestStatistics.useTable = !TestStatistics.useTable;
			this.updateTable();
		}
		public function updateTable():void
		{
			this.testTable.visible = TestStatistics.useTable;
			this.boxTroop.visible = !TestStatistics.useTable;
		}
		
		public function getTestFightTroop(troopIndex:int):TestFightTroop
		{
			return this.testTroopArr[troopIndex] as TestFightTroop;
		}

		
		override public function initData():void
		{
			if(!TestStatistics.listData){
				TestStatistics.listData = [];
				var ui0:TestFightTroop = this.getTestFightTroop(0);
				var ui1:TestFightTroop = this.getTestFightTroop(1);
				
				var data:Object;
				var data0:Object;
				var data1:Object;
				
				data0 = ui0.getCurrData(true);
				data1 = ui1.getCurrData(true);
				data = {'data0': data0, 'data1': data1};
				TestStatistics.listData.push(data);
				var i:int;
				for (i = 0; i < ConfigFight.testLvArr.length; i++)
				{
					data0 = ui0.getStatisticsData(i);
					data1 = ui1.getStatisticsData(i);
					data = {'data0': data0, 'data1': data1};
					TestStatistics.listData.push(data);
				}
			}
			this.initMode();
			this.updateTitleSwitch();
			this.list.array = TestStatistics.listData;
		}
		
		///仅更新技能id显示
		public function updateTroopSkillId(troopIndex:int):void
		{
			var ui:TestFightTroop = this.testTroopArr[troopIndex];
			ui.updateTroopSkillList();
		}
		
		///改变属性，只影响当前数据
		public function updatePropData(troopIndex:int):void
		{
			var ui:TestFightTroop = this.getTestFightTroop(troopIndex);
			var listData0:Object = listData[0];
			var currData:*= ui.getCurrData(true);
			listData0['data' + troopIndex] = currData;
			delete listData0.fight0;
			delete listData0.fight1;
			delete listData0.round;
			delete listData0.hpPer0;
			delete listData0.hpPer1;
			this.list.array = listData;
			
			ui.updateProps();
		}
		
		///改变英雄、技能，都会影响所有档次数据
		public function updateAllData(troopIndex:int):void
		{
			this.updatePropData(troopIndex);
			var listDataOne:Object;
			var ui:TestFightTroop = this.getTestFightTroop(troopIndex);
			var i:int;
			for (i = 0; i < ConfigFight.testLvArr.length; i++)
			{
				listDataOne = listData[i + 1];
				listDataOne['data' + troopIndex] = ui.getStatisticsData(i);
				delete listDataOne.fight0;
				delete listDataOne.fight1;
				delete listDataOne.round;
				delete listDataOne.hpPer0;
				delete listDataOne.hpPer1;
			}
			this.list.array = listData;
		}
		
		public function updateTitleSwitch():void
		{
			if (TestStatistics.showSwitch){
				//显示属性
				this.tT0.text = '左攻击';
				this.tT1.text = '左防御';
				this.tT2.text = '左兵力';
				this.tT3.text = '右攻击';
				this.tT4.text = '右防御';
				this.tT5.text = '右兵力';
			}
			else{
				this.tT0.text = '左胜率';
				this.tT1.text = '左攻';
				this.tT2.text = '左守';
				this.tT3.text = '回合数';
				this.tT4.text = '左余';
				this.tT5.text = '右余';
			}
			//EffectManager.bindMouseTips(this.tT0, 'ha\nhaha\nhahaha\nhahahaha\n只是试试');
		}
		
		///更新显示模式
		public function updateShowSwitch():void
		{
			this.updateTitleSwitch();

			this.updateTroopSkillId(0);
			this.updateTroopSkillId(1);
			this.list.array = listData;
		}
		
		static public function getWinPerColor(per:Number):String
		{
			var value:int = Math.round(per * 1000);
			if (value >= 900)
			{
				return '#00CCFF';
			}
			else if (value >= 750)
			{
				return '#00FF66';
			}
			else if (value >= 600)
			{
				return '#88FF00';
			}
			else if (value >= 400)
			{
				return '#DDDD00';
			}
			else if (value >= 250)
			{
				return '#E89900';
			}
			else if (value >= 100)
			{
				return '#FF5500';
			}
			else
			{
				return '#DD0000';
			}
		}
		
		private function listRender(cell:Box, index:int):void
		{
			var tLv:Label = cell.getChildByName('tLv') as Label;
			var tPower0:Label = cell.getChildByName('tPower0') as Label;
			var tPower1:Label = cell.getChildByName('tPower1') as Label;
			var t0:Label = cell.getChildByName('t0') as Label;
			var t1:Label = cell.getChildByName('t1') as Label;
			var t2:Label = cell.getChildByName('t2') as Label;
			var t3:Label = cell.getChildByName('t3') as Label;
			var t4:Label = cell.getChildByName('t4') as Label;
			var t5:Label = cell.getChildByName('t5') as Label;
			
			
			
			var data:Object = this.list.array[index];
			
			if (index == 0)
			{
				tLv.text = '当前';
			}
			else
			{
				var lvStr:String = 'LV ' + (data.data0.lv ? data.data0.lv : 1);
				//tLv.text = 'LV ' + (data.data0.lv ? data.data0.lv : 1);
				tLv.color = '#EEEEEE';
				Tools.textFitFontSize(tLv, lvStr, 35);
			}
			
			tPower0.text = data.data0.power;
			tPower1.text = data.data1.power;
			if (data.data0.power > data.data1.power)
			{
				tPower0.color = '#FFEE33';
				tPower1.color = '#AAAAAA';
			}
			else if (data.data0.power < data.data1.power)
			{
				tPower1.color = '#FFDD66';
				tPower0.color = '#AAAAAA';
			}
			else
			{
				tPower0.color = '#EEEEEE';
				tPower1.color = '#EEEEEE';
			}
			
			t0.alpha = t1.alpha = t2.alpha = t3.alpha = t4.alpha = t5.alpha = 1;
			t0.fontSize = t1.fontSize = t2.fontSize = t3.fontSize = t4.fontSize = t5.fontSize = 36;
			t0.bold = t1.bold = t2.bold = t3.bold = t4.bold = t5.bold = false;
			t0.color = t1.color = t2.color = t3.color = t4.color = t5.color = '#EEEEEE';
			
			if (TestStatistics.showSwitch){
				//显示属性
				//t0.fontSize = t1.fontSize = t2.fontSize = t3.fontSize = t4.fontSize = t5.fontSize = 11;
				
				t0.text = data.data0.army[0].atk + ',' + data.data0.army[1].atk;
				t1.text = data.data0.army[0].def + ',' + data.data0.army[1].def;
				t2.text = data.data0.army[0].hpm + ',' + data.data0.army[1].hpm;
				
				t3.text = data.data1.army[0].atk + ',' + data.data1.army[1].atk;
				t4.text = data.data1.army[0].def + ',' + data.data1.army[1].def;
				t5.text = data.data1.army[0].hpm + ',' + data.data1.army[1].hpm;
				
				Tools.textFitFontSize(t0, null, 56, 10, false);
				Tools.textFitFontSize(t1, null, 56, 10, false);
				Tools.textFitFontSize(t2, null, 56, 10, false);
				Tools.textFitFontSize(t3, null, 56, 10, false);
				Tools.textFitFontSize(t4, null, 56, 10, false);
				Tools.textFitFontSize(t5, null, 56, 10, false);
				
				t0.color = t3.color = '#FFAA66';
				t1.color = t4.color = '#66AAFF';
			}
			else{
				if (data.hasOwnProperty('round'))
				{
					var per:Number;
					per = data.fight0;
					t1.text = Tools.percentFormat(per, 1);
					//tFight0.color = this.getWinPerColor(per);
					per = 1 - data.fight1;
					t2.text = Tools.percentFormat(per, 1);
					//tFight1.color = this.getWinPerColor(per);
					
					per = (per + data.fight0) / 2;
					t0.text = Tools.percentFormat(per, 1);
					t0.color = TestStatistics.getWinPerColor(per);
					t0.fontSize = 40;
					t0.bold = true;
					
					t3.text = data.round.toFixed(2);
					
					per = data.hpPer0;
					t4.text = Tools.percentFormat(per, 1);
					t4.color = TestStatistics.getWinPerColor(per);
					
					per = data.hpPer1;
					t5.text = Tools.percentFormat(per, 1);
					t5.color = TestStatistics.getWinPerColor(per);
				}
				else
				{
					if (t0.text.indexOf(',') >-1){
						t0.alpha = t1.alpha = t2.alpha = t3.alpha = t4.alpha = t5.alpha = 0;
					}
					else{
						t0.alpha = t1.alpha = t2.alpha = t3.alpha = t4.alpha = t5.alpha = 0.3;
					}
				}
			}
		}
		
		/**
		 * 得到全英雄参战
		 */
		static public function getUserLogs():Object
		{
			if (!TestStatistics.userLogs){
				TestStatistics.userLogs = {};
				TestStatistics.allAttends = {};
				var i:int;
				for (i = 0; i < ConfigFight.testHids.length; i++) 
				{
					var key:String =  ConfigFight.testHids[i];
					var heroCfg:Object = ConfigServer.hero[key];
					if(heroCfg && heroCfg.state>0){
						TestStatistics.allAttends[key] = 1;
					}
				}
				TestStatistics.userLogs['1'] = {attends:TestStatistics.allAttends};
				TestStatistics.userLogs['2'] = {attends:TestStatistics.allAttends};
				for (i = 0; i < TestTable.NUM; i++){
					TestStatistics.userLogs[(1000+i).toString()] = {attends:TestStatistics.allAttends};
				}
			}
			return TestStatistics.userLogs;
		}
		
		
		/**
		 * 得到当前调整数据生成的战斗
		 */
		public function getCurrFightData():Object
		{
			var data:Object = {'mode': TestStatistics.useMode, 'rnd': Math.floor(Math.random() * 10000)};
			var ui0:TestFightTroop = this.testTroopArr[0];
			var ui1:TestFightTroop = this.testTroopArr[1];
			if(data.mode==0)
			{
				data.city = 0;
				data.country = 0;
				data.fireCountry = 1;
				data.country_logs = {};
				data.country_logs[data.country] = {buff:[0, 0], milepost:5};
				data.country_logs[data.fireCountry] = {buff:[0, 0], milepost:5};
			}
			
			data.user_logs = TestStatistics.getUserLogs();
			data.team = [
				{'troop': [ui0.getCurrData(true)]}, 
				{'troop': [ui1.getCurrData(true)]}
			]
			return data;
		}
		
		/**
		 * 模拟当前战斗，统计数据
		 */
		public function statisticsCurrFight():void
		{
			var ui0:TestFightTroop = this.getTestFightTroop(0);
			var ui1:TestFightTroop = this.getTestFightTroop(1);
			
			var troop0:Object = ui0.getCurrData(true);
			var troop1:Object = ui1.getCurrData(true);
			
			var listData0:Object = listData[0];
			
			var rslt0:Object = TestStatistics.statisticsOneFight(troop0, troop1);
			var rslt1:Object = TestStatistics.statisticsOneFight(troop1, troop0);
			
			listData0['fight0'] = rslt0.winPer;
			listData0['fight1'] = rslt1.winPer;
			listData0['round'] = (rslt0.round + rslt1.round) / 2;
			listData0['hpPer0'] = (rslt0.hpPer0 + rslt1.hpPer1) / 2;
			listData0['hpPer1'] = (rslt0.hpPer1 + rslt1.hpPer0) / 2;
			this.list.array = listData;
		}
		/**
		 * 模拟所有战斗，统计数据
		 */
		public function statisticsAllFight():void
		{
			if (this.testTable.visible){
				this.testTable.statisticsAllFight();
				return;
			}
			
			this.statisticsCurrFight();
			var ui0:TestFightTroop = this.getTestFightTroop(0);
			var ui1:TestFightTroop = this.getTestFightTroop(1);
			var listDataOne:Object;
			
			var i:int;
			for (i = 0; i < ConfigFight.testLvArr.length; i++)
			{
				listDataOne = listData[i + 1];
				
				var troop0:Object = ui0.getStatisticsData(i);
				var troop1:Object = ui1.getStatisticsData(i);
				var rslt0:Object = TestStatistics.statisticsOneFight(troop0, troop1);
				var rslt1:Object = TestStatistics.statisticsOneFight(troop1, troop0);
				
				listDataOne['fight0'] = rslt0.winPer;
				listDataOne['fight1'] = rslt1.winPer;
				listDataOne['round'] = (rslt0.round + rslt1.round) / 2;
				listDataOne['hpPer0'] = (rslt0.hpPer0 + rslt1.hpPer1) / 2;
				listDataOne['hpPer1'] = (rslt0.hpPer1 + rslt1.hpPer0) / 2;
			}
			this.list.array = listData;
		}
		
		/**
		 * 改变随机数，模拟N 场当前战斗，返回结果对象
		 */
		static public function statisticsOneFight(troop0:Object, troop1:Object, isFlip:Boolean = false, num:int = -1):Object
		{
			var troopDatas:Array;
			if (!isFlip){
				troopDatas = [troop0, troop1];
			}
			else{
				troopDatas = [troop1, troop0];
			}
			TestFightData.testFightPrint = 0;
			
			var records:Object;
			var winPer:Number = 0;
			var time:Number = 0;
			var round:Number = 0;
			var hpPer0:Number = 0;
			var hpPer1:Number = 0;
			var allHpMax0:Number = troop0.army[0].hpm + troop0.army[1].hpm;
			var allHpMax1:Number = troop1.army[0].hpm + troop1.army[1].hpm;
			//var hpPerM0:Number = 0;
			//var hpPerM1:Number = 0;
			var fight:FightLogic;
			var len:int = num < 0?ConfigFight.testStatisticsNum / 2:num;
			var rnd:int = Math.ceil(Math.random() * 100000 + 55555);
			var temp:Number;
			var userLogs:Object = TestStatistics.getUserLogs();

			for (var i:int = 0; i < len; i++) 
			{
				fight = FightInterface.doFightTest({mode:TestStatistics.useMode ,statist:1, troop:troopDatas, rnd:rnd + i * 9999, user_logs:userLogs});
				round += fight.round;
				records = fight.getRecord();
				time += records.time;
				temp = records.winnerHp[0] + records.winnerHp[1];
				if (records.winner == 0){
					hpPer0 += temp;
					winPer += 1;
					//if (temp >= hpPerM0){
						//hpPerM0 = temp;
					//}
				}
				else{
					hpPer1 += temp;
					//if (temp >= hpPerM1){
						//hpPerM1 = temp;
					//}
				}
			}
			winPer /= len;
			time /= len;
			round /= len;
			hpPer0 /= len * allHpMax0;
			hpPer1 /= len * allHpMax1;
			var obj:Object = {winPer:winPer, time:time, round:round, hpPer0:hpPer0, hpPer1:hpPer1};
			return obj;
		}

		
	}

}