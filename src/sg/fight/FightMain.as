package sg.fight
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigAssets;
	import sg.cfg.ConfigServer;
	import sg.fight.client.ClientBattle;
	import sg.fight.client.utils.FightEvent;
	import sg.fight.client.utils.FightSocket;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightScene;
	import sg.fight.client.view.ViewFightMain;
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	import sg.fight.test.TestPrint;
	import sg.guide.model.ModelGuide;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelGame;
	import sg.model.ModelUser;
	import sg.utils.MusicManager;
	import sg.utils.Tools;
	
	/**
	 * 战斗的总控器
	 * @author zhuda
	 */
	public class FightMain
	{
		private static var _instance:FightMain;
		
		public static function get instance():FightMain
		{
			return FightMain._instance ||= new FightMain();
		}
		
		/**
		 * 准备或正在战场中
		 */
		public static var inFight:Boolean;
		public var ui:ViewFightMain;
		public var scene:FightScene;
		public var client:ClientBattle;
		//public var event:EventDispatcher;
		public var fightLayer:Sprite;
		
		private var _data:*;
		private var _exitCaller:*;
		private var _exitFun:Function;
		private var _exitArgs:Array;
		
		
		/**
		 * 通过后台返回数据，战役生成（canSkip是可跳过的地图战斗）
		 */
		public static function startBattle(receiveData:Object, exitCaller:* = null, exitFun:Function = null, exitArgs:Array = null, canSkip:Boolean = false, skipRate:Number = -1):FightMain
		{
			if (ConfigServer.world.skip_all_fight){
				//所有战斗全部无条件跳过，只在外显示胜败
				var srcName:String = ConfigAssets.WorldWinAniName;
				if (receiveData.pk_result && receiveData.pk_result.winner != 0){
					srcName = ConfigAssets.WorldLoseAniName;
				}
				ViewManager.instance.showEffect(EffectManager.loadAnimation(srcName, '', 1));
				MusicManager.playSoundUI(srcName);
				//延迟调用结束方法
				if (exitFun)
				{
					ModelGame.isShowLoadingAni = false;
					ModelGame.stageLockOrUnlock('skipFight', true);
					Laya.stage.timer.once(1500, null, function():void{
						ModelGame.stageLockOrUnlock('skipFight', false);
						ModelGame.isShowLoadingAni = true;
						exitFun.apply(exitCaller, exitArgs);
					}, exitArgs);
				}
				return null;
			}
			if (canSkip){
				//如果战损极少，就跳过战斗，直接执行完成方法
				var soloRate:Number = FightUtils.getSoloRate(receiveData.pk_result);
				if (skipRate < 0) skipRate = ConfigServer.world.skip_solo_rate;
				if (soloRate <= skipRate && !ModelGuide.forceGuide())
				{
					//如果战损小于设定且不在引导，则跳过战斗
					ViewManager.instance.showEffect(EffectManager.loadAnimation(ConfigAssets.WorldWinAniName, '', 1));
					MusicManager.playSoundUI(ConfigAssets.WorldWinAniName);
					//ViewManager.instance.showRewardPanel(receiveData.gift_dict);
					//延迟调用结束方法
					if (exitFun)
					{
						ModelGame.isShowLoadingAni = false;
						ModelGame.stageLockOrUnlock('skipFight', true);
						Laya.stage.timer.once(1500, null, function():void{
							ModelGame.stageLockOrUnlock('skipFight', false);
							ModelGame.isShowLoadingAni = true;
							exitFun.apply(exitCaller, exitArgs);
						}, exitArgs);
						//exitFun.apply(exitCaller, exitArgs);
					}
					return null;
				}
			}
			var data:Object = receiveData.pk_data;
			if (data.done_time){
				data.canEndTime = Tools.getTimeStamp(data.done_time)/1000;
			}
			if(receiveData.pk_result){
				data.record = receiveData.pk_result;
			}
			if(receiveData.gift_dict){
				data.gift = receiveData.gift_dict;
			}
			return FightMain.startFight(data, exitCaller, exitFun, exitArgs);
		}
		
		/**
		 * 客户端使用的战役生成
		 */
		public static function startFight(data:* = null, exitCaller:* = null, exitFun:Function = null, exitArgs:Array = null):FightMain
		{
			FightMain.instance;
			FightMain._instance.init(data, exitCaller, exitFun, exitArgs);
			return FightMain._instance;
		}
		
		/**
		 * 得到当前正在观看的国战城池ID，如果观看的不是国战，则返回null
		 */
		public static function getCurrCityId():String
		{
			if (FightMain._instance && FightMain._instance.client && FightMain._instance.client.isCountry){
				return FightMain._instance.client.city;
			}
			return null;
		}
		
		/**
		 * 得到观察此战场的uid
		 */
		public static function getCurrUid():int
		{
			return ConfigApp.testFightType != 0?TestFightData.testUid:parseInt(ModelManager.instance.modelUser.mUID);
		}
		/**
		 * 得到观察此战场的uname
		 */
		public static function getCurrUname():String
		{
			return ConfigApp.testFightType != 0?TestFightData.testUname:ModelManager.instance.modelUser.uname;
		}
		/**
		 * 得到观察此战场的country
		 */
		public static function getCurrCountry():int
		{
			return ConfigApp.testFightType != 0?TestFightData.testCountry:ModelUser.getCountryID();
		}
		
		
		/**
		 * 是否在引导中限制按钮
		 */
		public function get isLimitButton():Boolean
		{
			if (ModelGuide.forceGuide() && this._data && this._data.mode >= 200)
				return true;
			return false;
		}
		
		/**
		 * 是否可以查看该战斗回放（比武大会、蓬莱寻宝中，战报早于设定时间的不可回放），date为时间对象
		 */
		public static function checkPlayback(date:Object):Boolean
		{
			if (!date || !ConfigFight.playbackChangeDate)
				return true;
			var fightMs:Number = Tools.getTimeStamp(date);
			var playbackMs:Number = ConfigFight.playbackMaxMinute*60000;
			var serverMs:Number = ConfigServer.getServerTimer();
			var changeMs:Number = Tools.getTimeStamp(ConfigFight.playbackChangeDate);
			var temp1:Number = serverMs - (fightMs + playbackMs);
			var temp2:Number = fightMs - changeMs;
			
			if (temp1 > 0){
				//超时
				return false;
			}
			if (temp2 < 0){
				//战斗配置改过
				return false;
			}
			return true;
		}
		
		
		private function init(data:* = null, exitCaller:* = null, exitFun:Function = null, exitArgs:Array = null):void
		{
			this.clear();
			FightMain.inFight = true;
			if (exitFun)
			{
				this._exitCaller = exitCaller;
				this._exitFun = exitFun;
				this._exitArgs = exitArgs;
			}
			this.fightLayer = new Sprite();
			
			if (data == null)
			{
				data = TestFightData.getFightData();
			}
			this.reset(data);
		}
		
		/**
		 * 初始化侦听
		 */
		//public function initListener():void
		//{
			//this.event.on('updatePos', this.client, this.client.updatePos);
		//}
		
		public function keyPress(e:Event):void
		{
			var str:String;
			var data:Object;
			var clientObj:Object;
			var serverObj:Object;
			var b:Boolean;
			trace('战斗键盘事件 keyCode=' + e.keyCode);
			
			//shift+反斜杠(|)   临时性重播，打印当前战斗
			if (e.keyCode == 124)
			{
				this.reset(null, 1);
			}
		}
		
		/**
		 * 重新一场随机战斗
		 */
		public function reRandomData():void
		{
			this.reset(TestFightData.getFightData());
		}
		/**
		 * 启动-1调整战斗战役，或者已知初始化数据的完整战役，需要有team
		 */
		public function startChangeFight(data:Object):void
		{
			this.reset(data);
		}
		
		/**
		 * 重置数据，重播战斗replay
		 */
		public function reset(data:Object = null, testFightPrint:int = 0):void
		{
			if (data){
				this._data = data;
			}
			this.clear();
			
			//shift+反斜杠(|)   临时性重播，打印当前战斗
			TestFightData.testFightPrint = testFightPrint;
			Laya.stage.on(Event.KEY_PRESS, this, this.keyPress);
			
			//this.init();
			EffectManager.hideMouseTips();
			//this.event = new EventDispatcher();
			
			this.ui = new ViewFightMain();
			this.fightLayer.addChild(this.ui);
			
			this.scene = new FightScene();
			this.fightLayer.addChildAt(this.scene, 0);
			
			//一次性修改战役数据，跳过战斗到当前战斗
			this.checkSkipWaves();
			
			this.client = new ClientBattle(this, this._data);
			
			this.ui.initEnd();
			
			this.client.initLoad();
			
			FightTime.init(this.client);
			if(this.client.isCountry){
				FightSocket.init();
			}
			
			if (ConfigApp.testFightType){
				this.client.playBGM();
			}
			
			//this.initListener();
			//this.scene.resetPos();
		}
		
		/**
		 * 一次性修改战役数据，跳过战斗到当前战斗
		 */
		public function checkSkipWaves():void
		{
			var battle:BattleLogic;
			var tempData:Object;
			if (this._data.mode == 1 || this._data.mode == 5)
			{
				if (this._data.skipTime > 0)
				{
					//仅快速跳过有限持续时间内的战斗
					battle = new BattleLogic(this._data);
					tempData = battle.getCurrData();
					
					//trace('\n成功跳过了 ' + battle.fightCount + ' 场战斗，累计击杀波数 ' + tempData.lastKillWave);
					//trace('\n原战斗\n',this._data);
					//trace('\n新战斗\n',tempData);
					
					this._data = tempData;
				}
			}
			else if ((this._data.mode >= 100 && this._data.mode < 200) || this._data.mode == 10){
				//比赛类战斗或擂台战，后台没给结果的，直接跑出结果
				if(!this._data.record){
					battle = new BattleLogic(this._data);
					tempData = battle.getRecord();
					this._data.record = tempData;
					
					if(TestUtils.isTestShow){
						if (this._data.hasOwnProperty('winner')){
							if (this._data.winner != tempData.winner){
								ViewManager.instance.showAlert('战斗winner不一致，前端：' + tempData.winner + '，后端：' + this._data.winner, null, null, '', true);
							}
							else{
								//console.error('战斗winner不一致，前端：' + tempData.winner + '，后端：' + this._data.winner, 3);
								//ViewManager.instance.showAlert('战斗winner前后端一致：' + this._data.winner, null, null, '', true);
								//throw new Error('战斗winner前后端一致：' + this._data.winner);
								trace('战斗winner前后端一致：' + this._data.winner);
							}
						}
					}
				}
			}
		}
		
		/**
		 * 退出战斗
		 */
		public function exit():void
		{
			this.clear();
			if (this._exitFun)
			{
				this._exitFun.apply(this._exitCaller, this._exitArgs);
			}
			this._exitCaller = null;
			this._exitFun = null;
			this._exitArgs = null;
			ViewManager.instance.closeFightScenes();
			
			this.fightLayer = null;
		}
		
		public function clear():void
		{
			if (this.ui == null)
				return;
			
			FightMain.inFight = false;
			FightEvent.ED.offAll();
			//this.event = null;
			
			if(this.ui){
				this.ui.clear();
			}
			if(this.scene){
				this.scene.destroy();
			}
			if(this.fightLayer){
				this.fightLayer.removeChildren();
			}
			this.ui = null;
			this.scene = null;
			
			if(this.client){
				this.client.clear();
				this.client = null;
			}
			
			TestPrint.instance.clear();
			FightTime.clearAll(true);
			
			Laya.stage.off(Event.KEY_PRESS, this, this.keyPress);
		}
	
	}

}