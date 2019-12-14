package sg.fight.test
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.webgl.canvas.BlendMode;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigColor;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.ViewFightBannerSkill;
	import sg.fight.client.view.ViewFightFate;
	import sg.fight.client.spr.FSpeak;
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.TeamLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightInterface;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.manager.ViewManager;
	import sg.model.ModelFormation;
	import sg.model.ModelHero;
	import sg.model.ModelPrepare;
	import sg.model.ModelSkill;
	import sg.utils.Tools;
	import sg.view.map.ViewHeroInfo;
	import ui.battle.fightTestTroopUI;
	import ui.battle.fightTestUI;
	import ui.com.country_flag1UI;
	import ui.com.country_flag2UI;
	import ui.com.country_flag3UI;
	import ui.com.hero_icon1UI;
	//import ui.test.testAniUI;
	
	/**
	 * ...
	 * @author zhuda
	 */
	public class TestFight extends fightTestUI
	{
		//hasOwnProperty
		//public static var isInit:Boolean;
				
		///调试战斗数组
		public static var lastTestStatistics:TestStatistics;
		public var testStatistics:TestStatistics;
		private var effectLayer:Sprite;
		private var heroImg:Image;
		private var _battle:BattleLogic;
		private var _index:int;
		
		public function TestFight(effectLayer:Sprite)
		{
			this.effectLayer = effectLayer;
			this.effectLayer.mouseEnabled = true;
			this.effectLayer.mouseThrough = true;
			
			//if (!TestFight.isInit){
				//TestFight.isInit = true;
				//TestFightData.testPartStr = ConfigFight.testBlessPart[0][1];
			//}
			
			if (TestFightData.canTestStatistics){
				if (TestFight.lastTestStatistics){
					TestFight.lastTestStatistics.destroy();	
				}
				this.testStatistics = new TestStatistics(this);
				//this.testStatistics.width = 640;
				this.addChild(this.testStatistics);
				
				TestFight.lastTestStatistics = this.testStatistics;
			}else{
				//TestPrint.visible = true;
			}
			
			this.init();
		}
		
		override public function onAddedBase():void
		{
			this.stage.on(Event.RESIZE, this, this.onResize);
			this.stage.on(Event.KEY_PRESS, this, this.keyPress);
			this.onResize();
			this.initUI();
		}


		public function keyPress(e:Event):void
		{
			var str:String;
			var data:Object;
			var clientObj:Object;
			var serverObj:Object;
			var b:Boolean;
			trace('TestFight键盘事件 keyCode=' + e.keyCode);

			if (e.keyCode == Keyboard.ENTER)
			{
				//this.lookBtn();
			}
			else if (e.keyCode == Keyboard.SPACE)
			{
				//暂停
				this.onPause();
			}
			else if (e.keyCode == Keyboard.Q || e.keyCode-32 == Keyboard.Q)
			{
				if(TestFightData.testMode == -1 && this.testStatistics){
					FightMain.instance.startChangeFight(this.testStatistics.getCurrFightData());
				}
				else{
					FightMain.instance.client.skip(true);
				}
			}
			else if (e.keyCode == Keyboard.W || e.keyCode-32 == Keyboard.W)
			{
				//尝试按特定初始化数据初始战斗
				if (TestFightData.testInitBattleData){
					FightMain.instance.ui.showTipsTxt('特定数据初始战役', 2);
					trace('\n特定数据初始战役：');
					
					data = TestFightData.testInitBattleData;
					data = FightUtils.clone(TestFightData.testInitBattleData);
					
					//data.team[0].troop = [data.team[0].troop[0]];
					
					serverObj = FightInterface.doBattle(data);
					data.record = serverObj;
					FightMain.instance.startChangeFight(data);
				}
			}
			else if (e.keyCode == Keyboard.E || e.keyCode-32 == Keyboard.E)
			{
				//尝试按特定初始化数据初始战斗
				if (TestFightData.testInitFightData){
					FightMain.instance.ui.showTipsTxt('特定数据初始战斗',1);
					data = FightUtils.clone(TestFightData.testInitFightData);
					data.team = [
						{'troop': [data.troop[0]]}, 
						{'troop': [data.troop[1]]}
					]
					delete data.troop;
					FightMain.instance.startChangeFight(data);
					
					//data = FightUtils.clone(TestFightData.testInitFightData);
					var fightLogic:FightLogic = new FightLogic(TestFightData.testInitFightData);
					fightLogic.start();
					trace('模拟服务器战斗：', fightLogic.getRecord());
					
				}
			}
			else if (e.keyCode == Keyboard.P || e.keyCode-32 == Keyboard.P)
			{
				//尝试清理
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army10'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army10s'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army11s'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army20'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army30'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army01'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army03'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('hero701'));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('hero701s'));
				//Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('army00'));
				//Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas('hero701'));
				
				
				//str = 'hero701';
				////delete AssetsManager.loadedAnimations[str];
				//Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(str));
				//
				//str = 'army00';
				////delete AssetsManager.loadedAnimations[str];
				//var temp:String = AssetsManager.getUrlAtlas(str);
				//Laya.loader.clearTextureRes(temp);
				////Laya.scaleTimer.frameOnce(10, Laya.loader, Laya.loader.clearTextureRes, [temp],false);
				////Laya.scaleTimer.frameOnce(20, Laya.loader, Laya.loader.clearTextureRes, [temp],false);
				////Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(str));
				//
				//str = 'army10s';
				////delete AssetsManager.loadedAnimations[str];
				//Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(str));
			}
			else if (e.keyCode == 42)
			{
				///小键盘*  开关显示
				this.onChangeShowTest();
			}
			else if (e.keyCode == Keyboard.R || e.keyCode-32 == Keyboard.R)
			{
				//重置
				this.onNewFight();
			}
			else if (e.keyCode == Keyboard.A || e.keyCode-32 == Keyboard.A)
			{
				if(TestFightData.testMode == -1){
					this.startStatisticsFight();
				}
			}
			else if (e.keyCode == Keyboard.S || e.keyCode-32 == Keyboard.S)
			{
				if(TestFightData.testMode == -1){
					this.statisticsAllFight();
				}
			}
			else if (e.keyCode == Keyboard.D || e.keyCode-32 == Keyboard.D)
			{
				TestFightData.testUseStatistics = 1 - TestFightData.testUseStatistics;
				FightMain.instance.ui.showTipsTxt('切换使用模拟数据：'+TestFightData.testUseStatistics,1);
			}
			else if (e.keyCode == Keyboard.Z || e.keyCode-32 == Keyboard.Z)
			{
				if(TestFightData.canTestStatistics){
					this.onChangeStatistics();
				}
			}
			else if (e.keyCode == Keyboard.X || e.keyCode-32 == Keyboard.X)
			{
				this.changeShowTestPrint();
			}
			else if (e.keyCode == Keyboard.C || e.keyCode-32 == Keyboard.C)
			{
				this.showSwitch();
			}
			else if (e.keyCode == Keyboard.V || e.keyCode-32 == Keyboard.V)
			{
				if(TestFightData.canTestStatistics){
					this.onChangeTable();
				}
			}
			else if (e.keyCode == Keyboard.B || e.keyCode-32 == Keyboard.B)
			{
				if(TestFightData.canTestStatistics){
					this.onClearLocal();
				}
			}
			
			if (TestFightData.testMode == 0){
				//国战特殊
				if (e.keyCode == Keyboard.T || e.keyCode-32 == Keyboard.T)
				{
					FightMain.instance.ui.showTipsTxt('国战推送',1);
					this.serverFinishFight();
				}
				else if (e.keyCode == Keyboard.Y || e.keyCode-32 == Keyboard.Y)
				{
					FightMain.instance.ui.showTipsTxt('国战矫正推送',1);
					this.serverFinishFight(true);
				}
				else if (e.keyCode == Keyboard.U || e.keyCode-32 == Keyboard.U)
				{
					FightMain.instance.ui.showTipsTxt('模拟襄阳战下场推送',1);
					this.serverFinishFightXYZMain();
				}
				else if (e.keyCode == Keyboard.F || e.keyCode-32 == Keyboard.F)
				{
					FightMain.instance.ui.showTipsTxt('国战左侧加人',1);
					this.serverJoinFight(0);
				}
				else if (e.keyCode == Keyboard.G || e.keyCode-32 == Keyboard.G)
				{
					FightMain.instance.ui.showTipsTxt('国战右侧加人',1);
					this.serverJoinFight(1);
				}
				else if (e.keyCode == Keyboard.V || e.keyCode-32 == Keyboard.V)
				{
					FightMain.instance.ui.showTipsTxt('国战左侧减人',1);
					this.serverExitFight(0);
				}
				else if (e.keyCode == Keyboard.B || e.keyCode-32 == Keyboard.B)
				{
					FightMain.instance.ui.showTipsTxt('国战右侧减人',1);
					this.serverExitFight(1);
				}
			}
			//else if (e.keyCode == Keyboard.UP)
			//{
				//this.showSwitch();
			//}
			
			else if (e.keyCode == 43)
			{
				FightMain.instance.ui.changeSpeed(0.5);
				//+
				//var ui:TestFightTroopSkill;
				//ui = new TestFightTroopSkill(1.5, null);
				////ui.list.array = [ModelSkill.getModel('skill201'), ModelSkill.getModel('skill202'), ModelSkill.getModel('skill203')];
				//this.addChild(ui);
				//
				//var ii:ViewHeroInfo = new ViewHeroInfo();
				//ii.currArg = new ModelPrepare({hid:'hero701'}).data;
				//ii.once(Event.ADDED, ii,ii.onAdded);
				//this.addChild(ii);
				
			}
			else if (e.keyCode == 45)
			{
				//-
				FightMain.instance.ui.changeSpeed(-0.5);
				//this.changeShowTestPrint();
			}
			
			
			if(str)
				trace(str);
		}
		public function changeShowTestPrint():void
		{
			var b:Boolean = !TestPrint.instance.isShow();
			TestPrint.visible = b;
			TestPrint.instance.showAll(b);
		}
		public function showSwitch():void
		{
			TestStatistics.showSwitch = !TestStatistics.showSwitch;
			if(this.testStatistics){
				//TestStatistics.showSwitch = !TestStatistics.showSwitch;
				this.testStatistics.updateShowSwitch();
			}
		}
		//public function showProp():void
		//{
			//TestStatistics.showProp = !TestStatistics.showProp;
			////testStatistics.updateTroopSkillId(0);
			////testStatistics.updateTroopSkillId(1);
		//}
		
		override public function onRemovedBase():void
		{
			Laya.stage.off('resize', this, this.onResize);
		}
		
		private function onResize():void
		{
			this.width = Laya.stage.width;
			this.height = Laya.stage.height - ConfigApp.topVal;
		}
		
		public function initUI():void
		{
			this.mouseThrough = true;
			this.mouseEnabled = true;
			this.btnShow.label = '显示 *';
			this.btnReset.label = '重置 R';
			this.btnShow.on(Event.CLICK, this, this.onChangeShowTest);
			this.btnReset.on(Event.CLICK, this, this.onNewFight);
			
			this.btnHidePrint.visible = this.btnSkillId.visible = this.btnTroop.visible = false;

			if (TestFightData.testMode < -1){
				this.btnAddTroop0.on(Event.CLICK, this, this.onAddTroop, [0]);
				this.btnAddTroop1.on(Event.CLICK, this, this.onAddTroop, [1]);
			
				this.btnEffect1.on(Event.CLICK, this, this.onEffect1);
				this.btnEffect2.on(Event.CLICK, this, this.onEffect2);
				this.btnEffect3.on(Event.CLICK, this, this.onEffect3);
				this.btnEffect4.on(Event.CLICK, this, this.onEffect4);
				this.btnEffect5.on(Event.CLICK, this, this.onEffect5);
				this.btnEffect6.on(Event.CLICK, this, this.onEffect6);
				this.btnEffect7.on(Event.CLICK, this, this.onEffect7);
				this.btnEffect8.on(Event.CLICK, this, this.onEffect8);
				this.btnEffect9.on(Event.CLICK, this, this.onEffect9);
				
				this.btnEffect2.label = '检兵种';
				this.btnEffect7.label = '检英雄';
				
				this.btnEffect2.labelColors = '#FFFF00';
				this.btnEffect7.labelColors = '#FFFF00';
				
				//this.btnEffect8.disabled = true;
				//this.btnEffect9.disabled = true;
				
				this.btnEffectClear.on(Event.CLICK, this, this.onEffectClear);
				
				this.btnPause.on(Event.CLICK, this, this.onPause);
			}
			else{
				this.btnAddTroop0.visible = false;
				this.btnAddTroop1.visible = false;
				this.btnEffect1.visible = false;
				this.btnEffect2.visible = false;
				this.btnEffect3.visible = false;
				this.btnEffect4.visible = false;
				this.btnEffect5.visible = false;
				this.btnEffect6.visible = false;
				this.btnEffect7.visible = false;
				this.btnEffect8.visible = false;
				this.btnEffect9.visible = false;
				this.btnEffectClear.visible = false;
				this.btnPause.visible = false;
				
				if (TestFightData.canTestStatistics){
					this.btnHidePrint.visible = this.btnSkillId.visible = this.btnTroop.visible = true;
					this.btnHidePrint.on(Event.CLICK, this, this.changeShowTestPrint);
					this.btnTroop.on(Event.CLICK, this, this.onChangeStatistics);
					this.btnSkillId.on(Event.CLICK, this, this.showSwitch);
				}
			}
			//this.btnTimeScale.on(Event.CLICK, this, this.onTimeScale);
			//this.btnRun.on(Event.CLICK, this, this.onMove, [1, 0]);
			//this.onEffect();
			this.initMode();
			this.updateShowTest();
			
			TestStatistics.getUserLogs();
			
			this.testLoadProgress(false);
		
		}
		
		/**
		 * 测试加载条
		 */
		private function testLoadProgress(b:Boolean):void
		{
			this.hs1.visible = this.hs2.visible = b;
			if (b){
				this.hs1.tick = this.hs2.tick = 0.0001;
				//this.hs1.on(Event.CHANGE, this, this.onChangeArmyLv);
				Laya.timer.frameLoop(1, this, this.onFrameLoop);
				//Laya.timer.clear(this, this.onFrameLoop);
			}
		}
		/**
		 * 调整真实加载条
		 */
		//private function onChangeProgress():void
		//{
			//var v:Number = this.hs1.value / 100;
			//v = this.hs2.visible = b;
			//if(v<=0){
				//this.hs2.;
			//}
		//}
		///当前进度条参数[最大速度惯性，允许超前前进进度（越接近满时越无法超前）]
		private var PROGRESS_ARGU_ARR:Array = [0.03,0.1];
		///当前速度，恒正
		private var currSpeed:Number = 0.05;
				///当前速度，恒正
		//private var speedProgress:Number = 0;
		/**
		 * 每帧自动调整显示加载条
		 */
		private function onFrameLoop():void
		{
			//var realProgress:Number = this.hs1.value / 100;
			//var lastProgress:Number = this.hs2.value / 100;
			//var currProgress:Number = lastProgress;
			//var aim:Number;
			//var temp:Number;
			//var temp2:Number;
			//var tempSpeed:Number;
			//if (0 == realProgress){
				////this.lastSpeed = 0;
				//currProgress = 0;
			//}
			//else{
				//tempSpeed = PROGRESS_ARGU_ARR[0];
				////显示已超前值
				//temp = lastProgress - realProgress;
				//
				//if (temp > PROGRESS_ARGU_ARR[1]){
					////超前太多，不动了
					//tempSpeed = 0;
				//}
				//else if (temp >= 0){
					////超前了，减速
					//temp2 = PROGRESS_ARGU_ARR[1] * (1.01 - realProgress);
					//tempSpeed *= Math.max(0,(temp2 - temp)) / temp2;
				//}
				//else
				//{
					////落后了
					//tempSpeed *= Math.max(0.1,1 - lastProgress);
				//}
				//temp = (1 + lastProgress) / 2;
				//currSpeed = Math.min(tempSpeed,tempSpeed * temp + currSpeed * (1-temp));
				//currProgress = Math.min(1,lastProgress + currSpeed);
				////trace(this.lastSpeed);
			//}
			var realProgress:Number = this.hs1.value / 100;
			var lastProgress:Number = this.hs2.value / 100;
			var currProgress:Number = lastProgress;
			var temp:Number = realProgress - lastProgress;
			//var tempSpeed:Number = 0.03;
			if (0 == realProgress){
				////this.lastSpeed = 0;
				currProgress = 0;
			}
			else{
				//平滑速度
				if (temp >= 0.0001){
					temp = Math.max(0.0001,Math.min(0.03,0.1 * temp));
				}
				currProgress += temp;
			}
			this.hs2.value = currProgress * 100;
		}
		
		private function onReset():void
		{
			FightMain.instance.reRandomData();
		}
		
		
		/**
		 * 襄阳战输入了下一场战斗
		 */
		private function serverFinishFightXYZMain():void
		{
			//var clientBattle:ClientBattle = FightMain.instance.client;
			//var result:Object = {};
			//result.initJS = clientBattle.getNextFightInitJS(true);
			//if (result.initJS)
			//{
				////clientBattle.city = '-1';
				////result.initJS.timeScale = 3;
				////result.initJS.troop[0].hid = 'hero826';
				//result.initJS.troop[0].hid = 'hero714';
				//result.initJS.troop[1].hid = 'hero716';
				//
				//result.initJS.troop[0].others.door = Math.ceil(Math.random()*300)*0.1;
				//result.initJS.troop[1].others.door = 0.25;
				//
				//var re:Object = FightInterface.doFight(result.initJS);
				//result.result = re;
				//clientBattle.serverFinishFight(result);
			//}
			//else{
				//FightTime.setTimeScale(ConfigFight.fightMaxSpeed);
			//}
		}
		/**
		 * 国战输入了下一场战斗，立即跳过当前并对比修改下一场状态
		 */
		private function serverFinishFight(isChange:Boolean = false):void
		{
			var clientBattle:ClientBattle = FightMain.instance.client;
			var result:Object = {};
			if (this._battle.fightLogic){
				//this._battle.fightStartUpdate();
			}
			
			if (this._battle.nextFight()){
				var re:Object = this._battle.fightRecords[this._battle.fightRecords.length - 1];
				result.initJS = re.init;
				
				
				//delete re.init;
				if(isChange){
					result.initJS.troop[0].hid = TestFightData.getRandomHeroId();
					result.initJS.troop[0].army[0].type = 1;
					result.initJS.troop[0].army[1].type = 3;
					result.initJS.troop[0].formation = [4, {}];
					result.initJS.troop[1].uid = FightMain.getCurrUid();
					result.initJS.troop[1].hid = TestFightData.getRandomHeroId();
					result.initJS.troop[1].army[0].type = 1;
					result.initJS.troop[1].army[1].type = 3;
					result.initJS.troop[1].formation = [6, {}];
					//result.initJS.timeScale = 3;
					//result.initJS.troop[1].uid = -1;
				}
				result.result = re;
				clientBattle.serverFinishFight(result);
				
				//trace('R输入服务器战报!!!', this._battle.fightRecords);
				//var vsStr:String = result.initJS.troop[0].uid + '|' +result.initJS.troop[0].hid;
				//vsStr += ' vs ' + result.initJS.troop[1].uid + '|' +result.initJS.troop[1].hid;
				//trace('【R】输入服务器第 '+ (result.initJS.fight_count+1) + ' 战报!!! '+vsStr+' ,胜出者：' + re.winner);
				//var serverKeyIds0:Array = this._battle.getTeam(0).getTroopKeyIds();
				//var clientSKeyIds0:Array = clientBattle.getTeam(0).getTroopKeyIds(true);
				//var clientCKeyIds0:Array = clientBattle.getTeam(0).getTroopKeyIds(false,true);
				//var serverKeyIds1:Array = this._battle.getTeam(1).getTroopKeyIds();
				//var clientSKeyIds1:Array = clientBattle.getTeam(1).getTroopKeyIds(true);
				//var clientCKeyIds1:Array = clientBattle.getTeam(1).getTroopKeyIds(false,true);
				//
				//trace('0方 server:', JSON.stringify(serverKeyIds0));
				//trace('0方 clientS/clientC:', JSON.stringify(clientSKeyIds0), JSON.stringify(clientCKeyIds0));
				//trace('0方 insertIdArr:', JSON.stringify(clientBattle.getClientTeam(0).insertIdArr));
				//trace('1方 server:', JSON.stringify(serverKeyIds1));
				//trace('1方 clientS/clientC:', JSON.stringify(clientSKeyIds1), JSON.stringify(clientCKeyIds1));
				//trace('1方 insertIdArr:', JSON.stringify(clientBattle.getClientTeam(1).insertIdArr));
				//
				//var b:Boolean;
				//b = FightUtils.compareObj(serverKeyIds0, clientSKeyIds0, '');
				//if (!b){
					//console.error('R输入 0方结果不一致！！！');
				//}
				//b = FightUtils.compareObj(serverKeyIds1, clientSKeyIds1, '');
				//if (!b){
					//console.error('R输入 1方结果不一致！！！');
				//}
			}
			else{
				var winner:int = this._battle.lastFightLogic?this._battle.lastFightLogic.winner:0;
				FightMain.instance.ui.showTipsTxt('无法模拟下一战了,胜方：'+winner, 1);
				clientBattle.serverEndBattle(winner);
				//FightTime.setTimeScale(ConfigFight.fightMaxSpeed);
			}
		}
		/**
		 * 国战插入部队isFront:Boolean
		 */
		private function serverJoinFight(teamIndex:int):void
		{
			var clientBattle:ClientBattle = FightMain.instance.client;
			var initJS:Object = clientBattle.getNextFightInitJS();
			if (initJS){
				var data:Object = initJS.troop[teamIndex];
				data.hid = TestFightData.getRandomHeroId();
				this._index++;
				data.uid = this._index;
				if(Math.random()>0.5)
					data.uid = -1;
				var troop:TroopLogic = this._battle.addTroop(data, teamIndex);
				trace('【FG】'+teamIndex + '方 server插入部队:'+troop.getKeyId());
				//
				//clientBattle.addTroopBySocket(data, teamIndex);
//
				//var serverKeyIds:Array = this._battle.getTeam(teamIndex).getTroopKeyIds();
				//var clientSKeyIds:Array = clientBattle.getTeam(teamIndex).getTroopKeyIds(true);
				//var clientCKeyIds:Array = clientBattle.getTeam(teamIndex).getTroopKeyIds(false,true);
				//
				//trace(teamIndex + 'server:', JSON.stringify(serverKeyIds));
				//trace(teamIndex + 'clientS/clientC:', JSON.stringify(clientSKeyIds), JSON.stringify(clientCKeyIds));
				//trace(teamIndex + 'insertIdArr:', JSON.stringify(clientBattle.getClientTeam(teamIndex).insertIdArr));
				//
				//
				//var b:Boolean = FightUtils.compareObj(serverKeyIds, clientSKeyIds, '');
				//if (!b){
					//console.error('插入部队结果不一致！！！');
				//}
			}
		}
		/**
		 * 国战撤退部队
		 */
		private function serverExitFight(teamIndex:int):void
		{
			var clientBattle:ClientBattle = FightMain.instance.client;
			//var team:ClientTeam = clientBattle.getClientTeam(teamIndex);
			
			var team:TeamLogic = this._battle.getTeam(teamIndex);
			//var initJS:Object = this._battle.getNextFightInitJS();
			if (team.troops.length > 1){
				var troop:TroopLogic = team.troops[0];
				//var data:Object = initJS.troop[teamIndex];
				//var troop:TroopLogic = this._battle.findTroop(teamIndex, data.hid, data.uid);
				if (troop){
				//if (troop && troop.uid>=0){
					trace('【VB】'+teamIndex + '方 server移除部队:'+troop.getKeyId());
					this._battle.removeTroop(troop);
					clientBattle.removeTroopBySocket(troop.uid, troop.hid, teamIndex);
					
					//var serverKeyIds:Array = this._battle.getTeam(teamIndex).getTroopKeyIds();
					//var clientSKeyIds:Array = clientBattle.getTeam(teamIndex).getTroopKeyIds(true);
					//var clientCKeyIds:Array = clientBattle.getTeam(teamIndex).getTroopKeyIds(false,true);
					//trace(teamIndex + 'server:', JSON.stringify(serverKeyIds));
					//trace(teamIndex + 'clientS/clientC:', JSON.stringify(clientSKeyIds), JSON.stringify(clientCKeyIds));
					//trace(teamIndex + 'insertIdArr:', JSON.stringify(clientBattle.getClientTeam(teamIndex).insertIdArr));
				}
			}
		}
		
		/**
		 * 打开或关闭调试部队
		 */
		private function onChangeStatistics():void
		{
			if(this.testStatistics){
				TestStatistics.visible = this.testStatistics.visible = !this.testStatistics.visible;
			}
		}
		/**
		 * 打开或关闭切磋阵列
		 */
		private function onChangeTable():void
		{
			if (this.testStatistics){
				this.testStatistics.onTable();
			}
		}
		/**
		 * 清空当前纪录对象
		 */
		public function onClearLocal():void
		{
			if (this.testStatistics){
				if (TestStatistics.useTable){
					TestTable.clearLocal();
				}
				else{
					TestFightTroop.clearLocal();
				}
			}
		}
		/**
		 * 启动-1统计调整战斗
		 */
		public function startStatisticsFight():void
		{
			if(this.testStatistics){
				FightMain.instance.startChangeFight(this.testStatistics.getCurrFightData());
				FightMain.instance.ui.testUI.testStatistics.statisticsCurrFight();
			}
			//this.testStatistics.statisticsCurrFight();
		}
		/**
		 * 模拟所有战斗
		 */
		public function statisticsAllFight():void
		{
			if(this.testStatistics)
				this.testStatistics.statisticsAllFight();
		}
		
		private function onNewFight():void
		{
			//trace('onNewFight开始1');
			FightMain.instance.scene.clearItems();
			//trace('onNewFight开始2');
			//FightMain.instance.scene.initItems();
			//trace('onNewFight开始3');
			this.onReset();
			//trace('onNewFight开始4');
		}
		
		private function onReplay():void
		{
			FightMain.instance.client.replay();
		}
		
		private function onSkip():void
		{
			FightMain.instance.client.skip();
		}
		
		private function onAddTroop(teamIndex:int):void
		{
			FightMain.instance.client.addTroop(TestFightData.getRandomTroopData(), teamIndex);
		}
		
		private function onMode(e):void
		{
			var str:String = this.comboMode.selectedLabel;
			TestFightData.testMode = parseInt(str.split(':')[0]);
			this.onNewFight();
		}
		
		private function initMode():void
		{
			var i:int;
			var len:int = TestFightData.testModeArr.length;
			var str:String = '';
			for (i = 0; i < len; i++) 
			{
				var mode:int = TestFightData.testModeArr[i];
				str += mode + ':' + Tools.getMsgById('battle_mode_' + mode);
				if (i < len - 1){
					str += ',';
				}
			}
			this.comboMode.labels = str;
			i = TestFightData.testModeArr.indexOf(TestFightData.testMode);
			if (i < 0) i = 0;
			this.comboMode.selectedIndex = i;
			this.comboMode.on(Event.CHANGE, this, this.onMode);
			
			//this.btnMode.text.text = '模式' + TestFightData.testMode.toString();
			
			//国战
			if (TestFightData.testMode == 0){
				ConfigFight.testPlaybackMode = 0;
				FightMain.instance.ui.showTipsTxt('国战：T结算 Y矫正 U襄阳 F左加 G右加 V左减 B右减 Q跳过', 3);
				var data:* = FightUtils.clone(FightMain.instance.client.data);
				this._battle = new BattleLogic(data);
				this._index = 0;
			}
			
			if (TestFightData.testMode == 104){
				//福将挑战
				this.initMode104();
			}
			else{
				this.comboPart.visible = false;
			}
		}
		private function initMode104():void
		{
			var i:int;
			var len:int = ConfigFight.testBlessPart.length;
			var str:String = '';
			for (i = 0; i < len; i++) 
			{
				var partStr:String = ConfigFight.testBlessPart[i][0] +' | ' + ConfigFight.testBlessPart[i][1];
				if (ConfigFight.testBlessPart[i][2]){
					partStr += '  ★顶战' + ConfigFight.testBlessPart[i][2]/10000 +'万';
				}
				str += partStr;
				if (i < len - 1){
					str += ',';
				}
			}
			this.comboPart.labels = str;
			for (i = 0; i < len; i++) 
			{
				if (ConfigFight.testBlessPart[i]==TestFightData.testPartArr){
					break;
				}
			}
			if (i == len) i = 0;
			this.comboPart.selectedIndex = i;
			TestFightData.testPartArr = ConfigFight.testBlessPart[this.comboPart.selectedIndex];
			
			this.comboPart.on(Event.CHANGE, this, this.onPart);

			this.comboPart.visible = true;
		}
		/**
		 * 修改关卡
		 */
		private function onPart():void
		{
			TestFightData.testPartArr = ConfigFight.testBlessPart[this.comboPart.selectedIndex];
			this.onReset();
		}
		
		
		/**
		 * 修改战斗速度
		 */
		private function onTimeScale():void
		{
			FightTime.changeTimeScale();
		}

		
		
		private function onEffect1():void
		{
			var i:int;
			var tempX:int;
			var tempY:int;
			var img:Image;
			for (i = 0; i < 17; i++)
			{
				tempX = Math.floor(i / 6) * 180;
				tempY = (i % 6) * 80;
				var countryFlag1:country_flag1UI = new country_flag1UI();
				countryFlag1.setCountryFlag(i);
				countryFlag1.x = 80 + tempX;
				countryFlag1.y = 120 + tempY;
				this.effectLayer.addChild(countryFlag1);
				
				var countryFlag2:country_flag2UI = new country_flag2UI();
				countryFlag2.setCountryFlag(i);
				countryFlag2.x = 120 + tempX;
				countryFlag2.y = 120 + tempY;
				this.effectLayer.addChild(countryFlag2);
				
				var countryFlag3:country_flag3UI = new country_flag3UI();
				countryFlag3.scale(0.4,0.4);
				countryFlag3.setCountryFlag(i);
				countryFlag3.x = 180 + tempX;
				countryFlag3.y = 120 + tempY;
				this.effectLayer.addChild(countryFlag3);
			}
			
			for (i = 0; i < 6; i++)
			{
				var txt:Text = new Text();
				txt.pos((i - 2) * 80 + 200, 550);
				txt.text = '诸葛亮';
				txt.font = 'Microsoft YaHei';
				//txt.bold = true;
				txt.fontSize = 20;
				txt.size(80, 30);
				txt.bgColor = '#000000';
				//txt.strokeColor = '#000000';
				//txt.stroke = 2;
				txt.color = EffectManager.getFontColor(i);
				this.effectLayer.addChild(txt);
				
				txt = new Text();
				txt.pos((i - 2) * 80 + 200, 580);
				txt.text = '司马懿';
				txt.font = 'Microsoft YaHei';
				txt.fontSize = 20;
				txt.size(80, 30);
				txt.strokeColor = EffectManager.getFontColor(i, ConfigColor.FONT_STROKE_COLORS);
				txt.stroke = 2;
				txt.color = '#FFFFFF';
				this.effectLayer.addChild(txt);
			}
			for (i = 0; i < 12; i++)
			{
				img = new Image(i % 2 == 0 ? 'ui/icon_66.png' : 'ui/icon_67.png');
				img.pos((i - 4) * 40 + 200, 610);
				EffectManager.changeSprColor(img, parseInt((i / 2).toString()));
				this.effectLayer.addChild(img);
			}
			for (i = 0; i < 8; i++)
			{
				img = new Image('ui/icon_' + (60 + i) + '.png');
				img.pos(i * 40 + 200, 650);
				this.effectLayer.addChild(img);
			}
			
			for (i = 0; i < 6; i++)
			{
				img = new Image('ui/bg_29.png');
				img.pos((i - 2) * 80 + 200, 700);
				EffectManager.changeSprColor(img, i);
				this.effectLayer.addChild(img);
			}
			for (i = 0; i < 4; i++)
			{
				img = new Image('ui/bg_' + (26 + i) + '.png');
				img.pos(i * 80 + 200, 800);
				this.effectLayer.addChild(img);
			}
			
			//return;
			
			//var tempY:Number = Math.random() * 500 + 200;
			//for (i = 0; i < 10; i++)
			//{
				//var ani:Animation;
				//
				//ani = EffectManager.loadAnimation('glow001');
				////ani = EffectManager.getAnimation('army00');
				//ani.pos(i * 40 + 100, tempY);
				//this.effectLayer.addChild(ani);
			//}
			
			for (i = 0; i < 3; i++)
			{
				img = new Image('ui/bar_10.png');
				img.pos(i * 100 + 40, 655);
				img.scale(0.5, 0.5);
				this.effectLayer.addChild(img);
				EffectManager.changeSprColor(img,i,true,ConfigColor.COLOR_MEDAL);
			}
		}
		
		private function onEffect2():void
		{
			this.onEffectClear();
			//EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_FOOD),Math.random()*stage.width,Math.random()*stage.height,Math.random()*stage.width,Math.random()*stage.height);
			//EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_WOOD),Math.random()*stage.width,Math.random()*stage.height,Math.random()*stage.width,Math.random()*stage.height,2,1);
			//EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), Math.random() * stage.width, Math.random() * stage.height, Math.random() * stage.width, Math.random() * stage.height);
			
			EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_FOOD), 170, 400, 100, 20, 1, 20, this.effectLayer);
			EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_WOOD), 270, 400, 500, stage.height - 50, 2, 1, this.effectLayer);
			EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN), 370, 400, 550, 20, 1, 80, this.effectLayer);
			EffectManager.createIconFlight(AssetsManager.getAssetsUI(AssetsManager.IMG_IRON), 470, 400, 300, 20, 1, 20, this.effectLayer);
			
			var i:int;
			var j:int;
			var ani:Animation;
			var spr:Sprite;
			var label:Label;
			var img:Image;
			
			img = new Image(AssetsManager.getAssetsUI('blueprogress.png'));
			img.width = 600;
			img.height = 700;
			img.x = 320;
			img.y = 550;
			img.anchorX = 0.5;
			img.anchorY = 0.5;
			img.alpha = 0.8;
			this.effectLayer.addChild(img);
			
			ani = EffectManager.loadAnimation('glow011', '', 1);
			ani.pos(300, 300);
			this.effectLayer.addChild(ani);
			
			ani = EffectManager.loadAnimation('building_aim', '', 0);
			ani.pos(200, 200);
			this.effectLayer.addChild(ani);
			
			for (i = 0; i < 4; i++)
			{
				for (j = 0; j < 6; j++)
				{
					var id:String = 'army' + i.toString() + j.toString();
					
					//ani = EffectManager.loadAnimation('building022');
					//ani.pos(i * 80 + 100, j * 120 + 400);
					//this.effectLayer.addChildAt(ani, 0);
					
					//ani = EffectManager.loadAnimation(id, 'cheer', 0);
					//ani.pos(i * 40 + 100, j * 60 + 200);
					//this.effectLayer.addChild(ani);
					//
					//ani = EffectManager.loadAnimation(id, 'attack|stand|run|stand', 0);
					//ani.pos(i * 40 + 100, j * 60 + 400);
					//this.effectLayer.addChild(ani);
					
					//ani = EffectManager.loadAnimation(id, 'attack|stand|run|stand', 1);
					//ani.pos(i * 40 + 100, j * 60 + 600);
					//this.effectLayer.addChild(ani);
					//
					//spr = EffectManager.loadArmysIcon(id);
					//spr.pos(i * 120 + 80, j * 120 + 600);
					//this.effectLayer.addChild(spr);
					//ani = EffectManager.loadAnimation(id, 'attack|stand|run|stand', 2);
					//ani.pos(i * 40 + 100, j * 60 + 800);
					//this.effectLayer.addChild(ani);
					
					//id = 'building002';
					
					//ani = EffectManager.loadAnimation(id, '');
					//ani.pos(i * 40 + 300, j * 60 + 200);
					//this.effectLayer.addChild(ani);
					
					var m:int;
					var n:int;
					spr = new Sprite();
					spr.pos(i * 150 + 75, j * 100 + 300);
					spr.scale(0.35, 0.35);
					this.effectLayer.addChild(spr);
						
					for (m = 0; m < 3; m++ ){
						for (n = 0; n < 3; n++ ){
							ani = EffectManager.loadAnimation(id + 's', 'up|up|up|down|down|down', -1);
							ani.pos((-0.6*n +0.6*m) * 50 -50, (0.3*n + 0.3*m ) * 50 -50);
							spr.addChild(ani);
						}
					}
					
					//if(Math.random()>0.5){
						//id='hero701s';
						//ani = EffectManager.loadAnimation(id, '');
						//ani.play(0, true, 'down');
					//}
					//else{
						//id = 'hero701';
						//ani = EffectManager.loadAnimation(id, '');
						//ani.play(0, true, 'run');
					//}
					//ani.play(0, true, 'down');
					ani = EffectManager.loadAnimation(id, 'cheer|stand|run|attack|injured1|injured2|dead1|dead2', -4);
					ani.name = id;
					//ani = EffectManager.loadAnimation(id, 'cheer|stand|run|dead1|dead2|attack|injured1|injured2', -1);
					//ani.pos(i * 40 + 300, j * 60 + 400);
					ani.pos(i * 150 + 125, j * 100 + 300);
					this.effectLayer.addChild(ani);
					
					label = new Label(id);
					label.pos(i * 150 + 100, j * 100 + 320);
					label['ani'] = ani;
					label.color = '#FFFF99';
					label.align = 'center';
					label.anchorX = 0.5;
					label.stroke = 1;
					this.effectLayer.addChild(label);
					Laya.scaleTimer.frameLoop(1,label,function (tempLabel:Label):void 
						{
							var tempAni:Animation = tempLabel['ani'] as Animation;
							if (tempAni){
								tempLabel.text = tempAni.name+'|'+tempAni.actionName;
							}
						}, [label], 
					false);
					
					//ani = EffectManager.loadAnimation(id, 'attack', 3);
					//ani.pos(i * 40 + 300, j * 60 + 600);
					//this.effectLayer.addChild(ani);
					
					//ani = EffectManager.loadAnimation(id, 'attack', 4);
					//ani.pos(i * 40 + 300, j * 60 + 800);
					//this.effectLayer.addChild(ani);
				}
				
			}
			ani = EffectManager.loadHeroAnimation('hero701',false);
			ani.pos(150, 250);
			this.effectLayer.addChild(ani);
			//
			//ani = EffectManager.loadAnimation('hero701', '');
			//ani.pos(170, 270);
			//ani.play(0,true,'run');
			//this.effectLayer.addChild(ani);
			//
			//ani = EffectManager.loadAnimation('army00', '');
			//ani.pos(190, 270);
			//ani.play(0,true,'run');
			//this.effectLayer.addChild(ani);
			
			//spr = EffectManager.loadArmysIcon('army25');
			//spr.pos(560, 600);
			//this.effectLayer.addChild(spr);
			//spr = EffectManager.loadArmysIcon('army26');
			//spr.pos(560, 720);
			//this.effectLayer.addChild(spr);
		}
		
		private function onEffect3():void
		{
			//开始画面
			//var spr:Sprite = EffectManager.loadWelcomeScreen();
			//this.effectLayer.addChild(spr);
			
			//加载testAni
			//var t:testAniUI = new testAniUI();
			//t.pos(50, 200);
			//this.effectLayer.addChild(t);
			
			//var hid:String = TestFightData.getRandomHeroId();
			//t.img1.skin = AssetsManager.getAssetsHero(hid, false);
			////t.img2.skin = AssetsManager.getAssetsHero(TestFightData.getRandomHeroId(), false);
			////t.img3.skin = AssetsManager.getAssetsHero(TestFightData.getRandomHeroId(), false);
			//
			//t.ui1.setHeroIcon(hid);
			//t.ui2.setHeroIcon(hid);
			//EffectManager.changeSprBrightness(t.ui2, 10, true);
			//t.ani1.play();
			
			for (var k:int = 0; k < 25; k++) 
			{
				var img:Image;
				//色相 0~1.25
				img = new Image(AssetsManager.getAssetLater('beastTypeA' + AssetsManager.PNG_EXT));
				img.pos(8 + k * 25, 240);
				EffectManager.changeSprHue(img, 0.05 * k);
				img.size(25, 25);
				this.effectLayer.addChild(img);
				//饱和度 0~1.25
				img = new Image(AssetsManager.getAssetLater('beastTypeB' + AssetsManager.PNG_EXT));
				img.pos(8 + k * 25, 280);
				EffectManager.changeSprSaturation(img, 0.05 * k);
				img.size(25, 25);
				this.effectLayer.addChild(img);
				//亮度 0~1.25
				img = new Image(AssetsManager.getAssetLater('beastTypeC' + AssetsManager.PNG_EXT));
				img.pos(8 + k * 25, 320);
				EffectManager.changeSprBrightness(img, 0.05 * k);
				img.size(25, 25);
				this.effectLayer.addChild(img);
				
				//色相 饱和度 亮度 0~1.25
				img = new Image(AssetsManager.getAssetLater('beastTypeD' + AssetsManager.PNG_EXT));
				img.pos(8 + k * 25, 360);
				EffectManager.changeSprColorTrans(img, 0.05 * k, 0.05 * k, 0.05 * k);
				img.size(25, 25);
				this.effectLayer.addChild(img);
				
				//色相 饱和度 亮度 0~1.25
				if(ConfigColor.COLOR_FILTER_TRANS[k]){
					img = new Image(AssetsManager.getAssetLater('beastTypeE' + AssetsManager.PNG_EXT));
					img.pos(8 + k * 25, 400);
					var transArr:Array = ConfigColor.COLOR_FILTER_TRANS[k];
					EffectManager.changeSprColorTrans(img, transArr[0], transArr[1], transArr[2]);
					img.size(25, 25);
					this.effectLayer.addChild(img);
				}
			}
			
			//得到锋矢阵各个等级和品质的描述
			for (var j:int = 0; j < 7; j++) 
			{
				var mf:ModelFormation = ModelFormation.getModel(j);
				var tempName:String = mf.getName();
				var i:int;
				for (i = 0; i < 60; i++) 
				{
					trace('激活'+i+'级'+tempName+'：'+mf.getLvInfo(i,true));
					trace('被动'+i+'级'+tempName+'：'+mf.getLvInfo(i,false));
				}
				for (i = 0; i < 6; i++) 
				{
					trace(i+'品质'+tempName+'：'+mf.getStarInfo(i));
				}
				trace('---------------------------');
			}

		}
		
		private function onEffect4():void
		{
			//英雄升星
			var heroId:String = TestFightData.getRandomHeroId();
			var starType:int = Math.floor(Math.random() * 4 + 2);
			var spr:Sprite = EffectManager.loadHeroStarUp(heroId, starType);
			//var spr:Sprite = EffectManager.loadHeroStarUp(heroId,starType,this,this.onEffect4);
			this.effectLayer.addChild(spr);
		}
		
		private function onEffect5():void
		{
			//英雄技
			//var view:ViewFightBannerSkill = new ViewFightBannerSkill(TestFightData.getRandomHeroId(), '哇哦', Math.random() > 0.5, Math.floor(Math.random() * 6), Math.random() > 0.5);
			//this.effectLayer.addChild(view);
			
			var clientFight:ClientFight = FightMain.instance.client.getClientFight();
			if (clientFight)
			{
				var clientTroop:ClientTroop = clientFight.getClientTroop(Math.random() > 0.5?0:1);
				//英雄说话
				var fSpeak:FSpeak = new FSpeak(clientTroop.getClientHero(), '好汉饶命');
			}
		}
		
		private function onEffect6():void
		{
			//合击技
			//var num:int = Math.floor(Math.random() * Math.random() * 10) +2;
			var num:int = Math.floor(Math.random() * 3) + 2;
			var arr:Array = [];
			for (var i:int = 0; i < num; i++)
			{
				arr.push(TestFightData.getRandomHeroId());
			}
			var view:ViewFightFate = new ViewFightFate(arr, '天下无双', Math.random() > 0.5);
			this.effectLayer.addChild(view);
		}
		
		private function onEffect7():void
		{
			this.onEffectClear();
			//英雄头像
			var i:int;
			var len:int = TestFightData.heroIdArr.length;
			for (i = 0; i < len; i++)
			{
				var spr:Sprite = new Sprite();
				spr.pos(i % 8 * 79 + 5, Math.floor(i / 8) * 79 + 95);
				this.effectLayer.addChild(spr);
				
				var hid:String = TestFightData.heroIdArr[i];
				var ui:hero_icon1UI = new hero_icon1UI();
				ui.setHeroIcon(hid);
				ui.scale(0.88,0.88);
				ui.on(Event.CLICK, this, this.changeHeroImg, [hid]);
				ui.pos(0, 0);
				spr.addChild(ui);
				
				//var img:Image = new Image('ui/bg_005.png');
				//img.width = 50;
				//img.height = 50;
				//img.pos(20,20);
				//spr.addChild(img);
				
				var ani:Animation = EffectManager.loadHeroAnimation(hid);
				ani.scale(0.4,0.4);
				//ani.play(0, true, 'up');
				//ani.alpha = 2;
				ani.pos(15, 70);
				//EffectManager.tweenLoop(ani, {alpha:0}, 500, Ease.sineInOut, null, 1000, -1, 3000, 1000);
				spr.addChild(ani);
				this.effectLayer.on('aniPlay2', ani, ani.play);
				//ani.stop();

				ani = EffectManager.loadHeroAnimation(hid, false);
				//ani = EffectManager.loadHeroAnimation(hid, false, 'cheer|stand|run|attack|injured1|injured2|dead1|dead2', -4);
				ani.scale(0.5, 0.5);
				ani.pos(60, 70);
				spr.addChild(ani);
				this.effectLayer.on('aniPlay', ani, ani.play);
				
				//var label:Label = new Label(id);
				//label.pos(50, 50);
				//label['ani'] = ani;
				//label.color = '#FFFF99';
				//label.align = 'center';
				//label.anchorX = 0.5;
				//label.stroke = 1;
				//spr.addChild(label);
				//Laya.scaleTimer.frameLoop(1,label,function (tempLabel:Label):void 
					//{
						//var tempAni:Animation = tempLabel['ani'] as tempAni;
						//if (tempAni){
							//tempLabel.text = tempAni.actionName;
						//}
					//}, [label], 
				//false);
				
				
				var txt:Label = new Label(hid);
				txt.color = '#FFFF00';
				txt.stroke = 1;
				txt.pos(3, 3);
				spr.addChild(txt);
				
				//EffectManager.changeSprSaturation(this.effectLayer, 0);
			}
			var btn:Button;
			var aniArr:Array = ['stand', 'attack', 'cheer', 'dead1', 'run'];
			len = aniArr.length;
			for (i = 0; i < len; i++)
			{
				btn = new Button('ui/btn_36.png' , aniArr[i]);
				btn.pos(i * 79 + 205, 60);
				btn.height = 35;
				btn.width = 79;
				btn.labelColors = '#FFFFFF';
				btn.clickHandler = new Handler(this.effectLayer, this.effectLayer.event, ['aniPlay', [0, true, aniArr[i]]]);
				this.effectLayer.addChild(btn);
			}
			
			aniArr = ['up', 'down'];
			len = aniArr.length;
			for (i = 0; i < len; i++)
			{
				btn = new Button('ui/btn_36.png' , aniArr[i]);
				btn.pos(i * 79 + 5, 60);
				btn.height = 35;
				btn.width = 79;
				btn.labelColors = '#FFFF00';
				btn.clickHandler = new Handler(this.effectLayer, this.effectLayer.event, ['aniPlay2', [0, true, aniArr[i]]]);
				this.effectLayer.addChild(btn);
			}
			
		}
		
		private function onEffect8():void
		{
			//for (var key:String in Animation.framesMap){
			//trace(key);
			//}
			var box:Box;
			var spr:Sprite;
			box = new Box();
			box.cacheAs = 'bitmap';
			
			spr = new Sprite();
			spr.graphics.drawCircle(230, 400, 150, '#FF2222', '#FFFF22');
			box.addChild(spr);
			
			spr = new Sprite();
			spr.graphics.drawCircle(240, 400, 50, '#FF2222');
			box.addChild(spr);
			spr.blendMode = BlendMode.DESTINATIONOUT;
			
			spr = new Sprite();
			spr.graphics.drawPie(140, 400, 190, 20, 80,'#442244');
			box.addChild(spr);
			spr.blendMode = BlendMode.MULTIPLY;
			box.alpha = 0.3;
			
			this.effectLayer.addChild(box);
			
			var i:int;
			var len:int = 5;
			for (i = 0; i < len; i++)
			{
				var label:Label = new Label();
				var scale:Number = 0.8 + i * 0.1;
				label.text = '+-123 4567890' + i;
				label.font = AssetsManager.FIGHT_FONT;
				label.scale(scale,scale);
				EffectManager.changeSprColor(label, i, true, ConfigColor.DAMAGE_COLOR_FILTER_MATRIX);
				label.pos(80,i*60+300);
				this.effectLayer.addChild(label);
			}

			this.effectLayer.addChild(EffectManager.loadAnimation('fire201').pos(400,300));
			//var particle2D:Particle2D = EffectManager.loadParticle('p001');
			//particle2D.emitter.emissionRate = 1;
			//particle2D.pos(222, 444);
			//this.effectLayer.addChild(particle2D);
		}
		
		private function onEffect9():void
		{
			var i:int;
			var len:int = 6;
			var id:String;
			var arr:Array = [];
			for (i = 0; i < len; i++)
			{
				id = 'army2' + i.toString();
				var spr:Sprite = EffectManager.loadArmysIcon(id);
				spr.pos(Laya.stage.width * 0.5, Laya.stage.height * 0.3 + i *100);
				arr.push(spr);
				//this.effectLayer.addChild(spr);
			}
			arr.push(0);
			FightMain.instance.ui.popViews(arr);
		}
		
		private function changeHeroImg(hid:String):void
		{
			if (!this.heroImg)
			{
				this.heroImg = new Image();
				this.heroImg.scale(0.5, 0.5);
				this.heroImg.pos(350,Laya.stage.height - 300);
			}
			this.heroImg.skin = AssetsManager.getAssetsHero(hid, false);
			this.effectLayer.addChild(this.heroImg);
		}
		private function onEffectClear():void
		{
			this.effectLayer.clearEvents();
			this.effectLayer.destroyChildren();
			this.heroImg = null;
			
			//清理兵种和英雄动画，清理所有英雄头像
			return;
			var i:int;
			var j:int;
			var id:String;
			var imgURL:String;
			for (i = 0; i < 4; i++)
			{
				for (j = 0; j < 6; j++)
				{
					id = 'army' + i.toString() + j.toString();
					Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(id));
					Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(id+'s'));
				}
			}
			var len:int = TestFightData.heroIdArr.length;
			for (i = 0; i < len; i++)
			{
				id = TestFightData.heroIdArr[i];
				imgURL = AssetsManager.getAssetsHero(id, true);
				Laya.loader.clearTextureRes(imgURL);
				imgURL = AssetsManager.getAssetsHero(id, false);
				Laya.loader.clearTextureRes(imgURL);
				
				id = ModelHero.getHeroRes(TestFightData.heroIdArr[i]);
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(id));
				Laya.loader.clearTextureRes(AssetsManager.getUrlAtlas(id+'s'));
			}
		}
		
		private function onPause():void
		{
			FightTime.timer.scale = -FightTime.timer.scale;
		}
		
		private function onChangeShowTest():void
		{
			ConfigFightView.showTest = !ConfigFightView.showTest;
			this.updateShowTest();
		}
		
		private function updateShowTest():void
		{
			this.mouseEnabled = ConfigFightView.touchTest;
			
			if (ConfigFightView.showTest)
			{
				if (Browser.window.conch == null)
				{
					Stat.show();
				}
				this.alpha = 1;
				if(TestPrint.visible)
					TestPrint.instance.showAll(true);
			}
			else
			{
				Stat.hide();
				this.alpha = 0;
				TestPrint.instance.showAll(false);
			}
			FightMain.instance.ui.updateTitle();
		}
		
		override public function clear():void {
			this.stage.off(Event.RESIZE, this, this.onResize);
			this.stage.off(Event.KEY_PRESS, this, this.keyPress);
			this.removeSelf();
			if (this.testStatistics){
				//TestFight.lastTestStatistics = this.testStatistics;
				//this.testStatistics.destroy();
				this.testStatistics.removeSelf();
				this.testStatistics = null;
			}
			Laya.timer.clear(this, this.onFrameLoop);
			Laya.timer.once(1000, this, this.destroy);
			//this.destroy();
		}
	}

}