package sg.fight.test
{
	import laya.events.Event;
	import laya.net.LocalStorage;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightInterface;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.EffectManager;
	import sg.model.ModelFormation;
	import sg.model.ModelHero;
	import sg.model.ModelPrepare;
	import sg.utils.Tools;
	import ui.battle.fightTestStatisticsUI;
	import ui.battle.fightTestTableItemUI;
	import ui.battle.fightTestTableRateItemUI;
	import ui.battle.fightTestTableUI;
	
	/**
	 * 测试模式-1，调整分析战斗胜率
	 * @author ...
	 */
	public class TestTable extends fightTestTableUI
	{
		private static var _instance:TestTable = null;
	
		public static function get instance():TestTable{
			return _instance;
		}
		
		private var testStatistics:TestStatistics;
		private var testTroopArr:Array;
		///当前设定的英雄index
		private var currIndex:int = 0;
		
		static public var isInit:Boolean;
		///阵列长度
		static public var NUM:int = 9;
		///当前英雄队列生效开关
		static public var heroesOpenArr:Array;
		///当前英雄队列Json文字
		static public var heroesJsonStrArr:Array;
		///当前英雄队列有效对象，经过modelPrepare转化的
		static public var heroesDataArr:Array;
		///当前英雄阵列的胜负概率，二维，内部有是否有效的状态
		static public var heroesRateArr:Array;
		
		///当前计算版本号
		//static public var version:int = 0;
		///当前英雄队列已重算战斗开关
		static public var heroesFightArr:Array;

		
		
		public function TestTable(testStatistics:TestStatistics)
		{
			TestTable._instance = this;
			this['noAlignByPC'] = 1;
			super();
			
			this.testStatistics = testStatistics;
			this.initUI();
			
			this.once(Event.ADDED, this, this.initData);
			//this.initData();
		}
		
		public function initUI():void
		{
			//this.checkBoxSkill.selected = TestStatistics.useDefaultSkills;
			////this.checkBoxFate.selected = TestStatistics.useAllFate;
			//this.checkBoxCountry.selected = TestStatistics.useModeCountry;
			//
			//this.btnCurr.on(Event.CLICK, this.testFight, this.testFight.startStatisticsFight);
			//this.btnAll.on(Event.CLICK, this, this.onAll);
			
			this.listX.renderHandler = new Handler(this, this.listXRender);
			this.listY.renderHandler = new Handler(this, this.listYRender);
			this.listRate.renderHandler = new Handler(this, this.listRateRender);
			
			this.listX.selectEnable = true;
			this.listX.selectHandler = new Handler(this, this.onlistXSelect);
			this.listX.mouseHandler = new Handler(this, this.onlistXMouse);


			
			this.inputPrepare.on(Event.INPUT, this, this.onChangeInputPrepare);
			this.inputPrepare.leading = 5;
		}

		public function onAll():void
		{

		}
		
		public function getTestFightTroop(troopIndex:int):TestFightTroop
		{
			return this.testTroopArr[troopIndex] as TestFightTroop;
		}
		
		/**
		 * 包装保存testTable数据
		 */
		static public function saveLocal():void
		{
			var obj:Object = {};
			var testTableArr:Array = [];
			var arr:Array;
			var i:int;
			for (i = 0; i < TestTable.NUM; i++) 
			{
				arr = [TestTable.heroesOpenArr[i],TestTable.heroesJsonStrArr[i]];
				testTableArr.push(arr);
			}
			obj.testTable = testTableArr;
			LocalStorage.setJSON('testTable', obj);
			//LocalStorage.setItem('testTable', str);
		}
		/**
		 * 清空testTable数据并使用后台数据重新初始化
		 */
		static public function clearLocal():void
		{
			LocalStorage.removeItem('testTable');
			TestTable.isInit = false;
			TestTable.instance.initData();
			FightMain.instance.ui.showTipsTxt('阵列模拟：清理json缓存');
		}
		
		override public function initData():void
		{
			if (!TestTable.isInit){
				TestTable.heroesOpenArr = [];
				TestTable.heroesJsonStrArr = [];
				TestTable.heroesDataArr = [];
				TestTable.heroesFightArr = [];
				TestTable.heroesRateArr = [];
				
				//如果之前本机有缓存，使用缓存数据，否则使用后台配置
				var testTableArr:Array;
				var temp:Object = LocalStorage.getJSON('testTable');
				if (temp){
					testTableArr = temp.testTable;
				}
				else{
					testTableArr = FightUtils.clone(ConfigFight.testTable);
				}

				var i:int;
				for (i = 0; i < TestTable.NUM; i++) 
				{
					var arr:Array = testTableArr[i];
					TestTable.heroesOpenArr.push(arr[0]);
					TestTable.heroesFightArr.push(0);
					TestTable.setJsonStr(arr[1], i);
				}
				var len:int = TestTable.NUM * (TestTable.NUM + 1);
				for (i = 0; i < len; i++) 
				{
					TestTable.heroesRateArr.push(null);
				}
				TestTable.isInit = true;
			}
			this.listX.array = TestTable.heroesDataArr;
			this.listY.array = TestTable.heroesDataArr;
			this.listRate.array = TestTable.heroesRateArr;
			
			this.listX.selectedIndex = this.currIndex;
		}
		/**
		 * 修改其他输入数据
		 */
		public function onChangeOther():void
		{			
			//TestTable.version++;
			for (var i:int = 0; i < TestTable.NUM; i++) 
			{
				TestTable.heroesFightArr[i] = 0;
			}
			if (this.visible){
				this.listRate.array = TestTable.heroesRateArr;
			}
		}
		
		/**
		 * 修改输入数据
		 */
		public function onChangeInputPrepare():void
		{
			if (TestTable.setJsonStr(this.inputPrepare.text, this.currIndex)){
				TestTable.heroesFightArr[this.currIndex] = 0;
				
				this.listX.array = TestTable.heroesDataArr;
				this.listY.array = TestTable.heroesDataArr;
				this.listRate.array = TestTable.heroesRateArr;
			}
		}
		/**
		 * 修改json数据到指定index
		 */
		static public function setJsonStr(text:String,index:int):Boolean
		{
			var obj:Object;
			var b:Boolean = false;
			try 
			{
				obj = JSON.parse(text);
				if (obj){
					if(!obj.hid || !ConfigServer.hero[obj.hid]){
						obj.hid = 'hero701';
					}
					//设定为玩家
					if(!obj.uid){
						obj.uid = 1000 + index;
					}
					if(!obj.hasOwnProperty('country')){
						obj.country = index;
					}
					TestFightTroop.packGoodOthers(obj);
				}
				//this.updateAllData();
				b = true;	
			}
			catch (err:Error)
			{
				trace(err);
			}
			if (b){
				TestTable.heroesJsonStrArr[index] = text;
				TestTable.heroesDataArr[index] = new ModelPrepare(obj, true).data;
				if(TestTable.isInit){
					TestTable.saveLocal();
				}
			}
			return b;
		}
		
		/**
		 * 右击中间的部分，跳转到对应战斗
		 */
		private function jumpPK(xx:int, yy:int):void
		{
			if (xx != yy && yy != TestTable.NUM){
				//trace('观看 ' + TestTable.heroesDataArr[xx] + ' vs ' + TestTable.heroesDataArr[yy]);
				//this.testStatistics.onTable();
				for (var i:int = 0; i < 2; i++) 
				{
					var testFightTroop:TestFightTroop = this.testStatistics.getTestFightTroop(i);
					testFightTroop.inputPrepare.text = TestTable.heroesJsonStrArr[i==0?xx:yy];
					testFightTroop.onChangeInputPrepare(true);
					testFightTroop.updateUseJson();
					TestFightTroop.useJsonArr[i] = true;
				}
				TestStatistics.visible = false;
				FightMain.instance.startChangeFight(this.testStatistics.getCurrFightData());
				//
				//this.testStatistics.onTable();
			}
		}
		
		private function listRateRender(cell:Box, index:int):void
		{
			var item:fightTestTableRateItemUI = cell.getChildByName('item') as fightTestTableRateItemUI;

			var xx:int = index % TestTable.NUM;
			var yy:int = Math.floor(index / TestTable.NUM);
			item.off(Event.RIGHT_CLICK, this, this.jumpPK);
			item.on(Event.RIGHT_CLICK, this, this.jumpPK, [xx, yy]);
			EffectManager.bindMouseTips(item, '');
			
			var data:Object;
			var per:Number;
			var self:int = yy > xx?0:1;
			var enemy:int = 1 - self;
			var tempArr:Array;
			var formationType0:int;
			var formationType1:int;
			var formationStar0:int;
			var formationStar1:int;
			
			if (yy == TestTable.NUM){
				item.tEnemyName.visible = false;
				if(TestTable.heroesOpenArr[xx]){
					//平均胜率
					var num:int = 0;
					var avgWin:Number = 0;
					var avgRound:Number = 0;
					var avgHpPerSelf:Number = 0;
					var avgHpPerEnemy:Number = 0;
					var heroName:String = "";
					//var version:int = 999999999;
					for (var i:int = 0; i < TestTable.NUM; i++) 
					{
						var ii:int = xx + i * TestTable.NUM;
						var xxx:int = ii % TestTable.NUM;
						var yyy:int = Math.floor(ii / TestTable.NUM);
						if (!TestTable.heroesOpenArr[xxx] || !TestTable.heroesOpenArr[yyy] || !TestTable.heroesFightArr[xxx] || !TestTable.heroesFightArr[yyy]){
							continue;
						}
						data = this.listRate.array[ii];
						self = yyy > xxx?0:1;
						enemy = 1-self;
						if (data){
							avgWin += (data['fight' + self] + 1 - data['fight' + enemy]) / 2;
							avgRound += data.round;
							avgHpPerSelf += data['hpPer' + self];
							avgHpPerEnemy += data['hpPer' + enemy];
							if(!heroName){
								heroName = data['heroName' + self];
								tempArr = ModelFormation.getFormationTypeAndStar(data['formation' + self]);
								formationType0 = tempArr[0];
								formationStar0 = tempArr[1];
							}
							//version = Math.min(version,data['version']);
							num++;
						}
					}
					
					if (num > 0){
						item.visible = true;
						item.alpha = 1;
						avgWin /= num;
						avgRound /= num;
						avgHpPerSelf /= num;
						avgHpPerEnemy /= num;
						item.tHeroName.text = heroName;
						
						item.tWin.text = Tools.percentFormat(avgWin, 0);
						item.tWin.color = TestStatistics.getWinPerColor(avgWin);
						item.tRound.text = avgRound.toFixed(2);
						item.tSelf.text = Tools.percentFormat(avgHpPerSelf, 1);
						item.tSelf.color =  TestStatistics.getWinPerColor(avgHpPerSelf);
						item.tEnemy.text = Tools.percentFormat(avgHpPerEnemy, 1);
						item.tEnemy.color =  TestStatistics.getWinPerColor(avgHpPerEnemy);
						
						item.fSelf.visible = true;
						item.fSelf.label.text = ModelFormation.getModel(formationType0).getName().charAt(0);
						item.fSelf.label.color = EffectManager.getFontColor(formationStar0);
						item.fSelf.img.visible = false;
						item.fEnemy.visible = false;
						
						//item.fSelf.label.text = data['heroName' + self];
					}
					else{
						item.visible = false;
					}
					item.gray = !TestTable.heroesFightArr[xx];
					
				}else{
					item.visible = false;
				}
			}
			else if (xx == yy || !TestTable.heroesOpenArr[xx] || !TestTable.heroesOpenArr[yy]){
				item.visible = false;
			}
			else{
				//中间格子
				item.visible = true;
				data = this.listRate.array[index];
				//item.tHeroName.scaleX = 0.5;
				if (data){
					item.alpha = 0.8;
					
					per = (data['fight' + self] + 1 - data['fight' + enemy]) / 2;
					item.tWin.text = Tools.percentFormat(per, 1);
					item.tWin.color = TestStatistics.getWinPerColor(per);
					
					item.tRound.text = data.round.toFixed(2);
					item.tHeroName.text = data['heroName' + self];
					item.tEnemyName.text = data['heroName' + enemy];
					EffectManager.bindMouseTips(item, '右键查看:'+item.tHeroName.text+' vs '+item.tEnemyName.text);
					
					per = data['hpPer' + self];
					item.tSelf.text = Tools.percentFormat(per, 1);
					item.tSelf.color =  TestStatistics.getWinPerColor(per);
					
					per = data['hpPer' + enemy];
					item.tEnemy.text = Tools.percentFormat(per, 1);
					item.tEnemy.color =  TestStatistics.getWinPerColor(per);
					item.gray = !TestTable.heroesFightArr[xx] || !TestTable.heroesFightArr[yy];
					item.tEnemyName.visible = true;
					
					tempArr = ModelFormation.getFormationTypeAndStar(data['formation' + self]);
					formationType0 = tempArr[0];
					formationStar0 = tempArr[1];
					tempArr = ModelFormation.getFormationTypeAndStar(data['formation' + enemy]);
					formationType1 = tempArr[0];
					formationStar1 = tempArr[1];
					item.fSelf.visible = true;
					item.fSelf.label.text = ModelFormation.getModel(formationType0).getName().charAt(0);
					item.fSelf.label.color = EffectManager.getFontColor(formationStar0);
					item.fSelf.img.visible = ModelFormation.checkAdept(formationType0, formationType1, formationStar0);
					item.fEnemy.visible = true;
					item.fEnemy.label.text = ModelFormation.getModel(formationType1).getName().charAt(0);
					item.fEnemy.label.color = EffectManager.getFontColor(formationStar1);
					item.fEnemy.img.visible = ModelFormation.checkAdept(formationType1, formationType0, formationStar1);
				}
				else{
					item.alpha = 0.1;
					item.gray = true;
					item.tEnemyName.visible = false;
				}
			}
			//this.listRender(cell, index);
		}
		
		private function onlistXSelect(index:int):void
		{
			var item:fightTestTableItemUI;
			for (var i:int = 0; i < TestTable.NUM; i++) 
			{
				item = this.listX.getCell(i).getChildByName('item') as fightTestTableItemUI;
				item.imgChoose.visible = i == index;
			}
			this.currIndex = index;
			this.inputPrepare.text = TestTable.heroesJsonStrArr[index];
			//this.listRender(cell, index, this.listX.array[index]);
		}
		private function onlistXMouse(index:int):void
		{
			//this.listRender(cell, index, this.listX.array[index]);
		}
		
		
		private function listXRender(cell:Box, index:int):void
		{
			this.listRender(cell, index, this.listX.array[index]);
		}
		private function listYRender(cell:Box, index:int):void
		{
			this.listRender(cell, index, this.listY.array[index]);
		}
		
		private function listRender(cell:Box, index:int, data:Object):void
		{
			var item:fightTestTableItemUI = cell.getChildByName('item') as fightTestTableItemUI;
			item.uiPower.setNum(data.power);
			item.tHeroName.text = ModelHero.getHeroName(data.hid, data.awaken);
			item.tUserName.text = data.uname?data.uname:"";
			
			item.checkBoxOpen.selected = TestTable.heroesOpenArr[index];
			if(!item.checkBoxOpen.clickHandler)
				item.checkBoxOpen.clickHandler = new Handler(this, this.onChangeCheckBoxOpen, [index]);
		}
		private function onChangeCheckBoxOpen(index:int):void
		{
			TestTable.heroesOpenArr[index] = !TestTable.heroesOpenArr[index];
			this.listRate.array = TestTable.heroesRateArr;
		}
		
		
		/**
		 * 模拟所有战斗，统计数据
		 */
		public function statisticsAllFight():void
		{
			var listDataOne:Object;
			//TestTable.version++;
			
			var i:int;
			var j:int;
			for (i = 0; i < TestTable.NUM-1; i++)
			{
				for (j = i+1; j < TestTable.NUM; j++)
				{
					if (!TestTable.heroesOpenArr[i] || !TestTable.heroesOpenArr[j]){
						continue;
					}
					var troop0:Object = FightUtils.clone(TestTable.heroesDataArr[i]);
					var troop1:Object = FightUtils.clone(TestTable.heroesDataArr[j]);
					var rslt0:Object = TestStatistics.statisticsOneFight(troop0, troop1, false, 10);
					var rslt1:Object = TestStatistics.statisticsOneFight(troop1, troop0, false, 10);
					
					listDataOne = {};
					listDataOne['fight0'] = rslt0.winPer;
					listDataOne['fight1'] = rslt1.winPer;
					listDataOne['round'] = (rslt0.round + rslt1.round) / 2;
					listDataOne['hpPer0'] = (rslt0.hpPer0 + rslt1.hpPer1) / 2;
					listDataOne['hpPer1'] = (rslt0.hpPer1 + rslt1.hpPer0) / 2;
					//listDataOne['version'] = TestTable.version;
					//英雄名
					listDataOne['heroName0'] = ModelHero.getHeroName(troop0.hid, troop0.awaken);
					listDataOne['heroName1'] = ModelHero.getHeroName(troop1.hid, troop1.awaken);
					
					//英雄阵法和优势关系
					listDataOne['formation0'] = troop0.formation;
					listDataOne['formation1'] = troop1.formation;
					
					TestTable.heroesRateArr[j * TestTable.NUM + i] = listDataOne;
					TestTable.heroesRateArr[i * TestTable.NUM + j] = listDataOne;
				}
			}
			//合计
			for (i = 0; i < TestTable.NUM; i++)
			{
				TestTable.heroesFightArr[i] = TestTable.heroesOpenArr[i]?1:0;
			}
			
			this.listRate.array = TestTable.heroesRateArr;
		}
		

		
	}

}