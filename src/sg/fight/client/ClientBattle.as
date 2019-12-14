package sg.fight.client
{
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientFight;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.spr.FSpeak;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTeam;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightEvent;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightScene;
	import sg.fight.logic.BattleLogic;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.TeamLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestCopyright;
	import sg.fight.test.TestFightData;
	import sg.guide.model.ModelGuide;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.utils.TestUtils;
	import sg.model.ModelItem;
	import sg.scene.constant.EventConstant;
	import sg.utils.MusicManager;
	import sg.utils.Tools;
	import ui.bag.bagItemUI;
	
	/**
	 * 战场Battle Fight
	 * @author zhuda
	 */
	public class ClientBattle extends BattleLogic
	{
		public var fightMain:FightMain;
		public var fightLoad:FightLoad;
		public var isInit:Boolean;
		public var isShow:Boolean;
		
		//public var clientRecord:Object;
		///从服务器获得的累计战报，对下一场战斗的校验信息
		private var _fightRecords:Array;
		public var countryBattleWinner:int;
		///上一场战斗的胜方
		//private var _lastWinner:int;
		//private var _isReadyNext:Boolean;
		
		///决定了多波战斗的下一场可跳过时间点（秒）
		public var canSkipTime:Number;
		///擂台战，可播放战斗结束的时间点（秒）
		public var canEndTime:Number;
		///擂台战的当期擂台编号0123
		public var arena_index:int;
		///擂台战的日志编号
		public var log_index:int;

		public var is_mine:Boolean;
		
		
		//private var _event:EventDispatcher;
		
		public function getClientTeam(teamIndex:int):ClientTeam
		{
			return this.teams[teamIndex] as ClientTeam;
		}
		
		public function getClientFight():ClientFight
		{
			return this.fightLogic as ClientFight;
		}
		
		/**
		 * 国战之最更新
		 */
		override public function checkTeamBest(teamIndex:int, uid:int):Boolean
		{
			if (super.checkTeamBest(teamIndex, uid))
			{
				//通知视图变化
				//var userObj:Object = this.teamUsers[teamIndex][uid.toString()];
				fightMain.ui.updateCountryTeamBest(teamIndex);
			}
			return true;
		}
		
		/**
		 * 得到某玩家在本战斗中参战的所有队伍
		 */
		public function getUserTroops(teamIndex:int, uid:int):Array
		{
			var arr:Array = [];
			var clientTroop:ClientTroop;
			if (this.fightLogic != null)
			{
				clientTroop = this.getClientFight().getClientTroop(teamIndex);
				if (clientTroop.uid == uid)
				{
					arr.push(clientTroop);
				}
			}
			
			var team:TeamLogic = this.getTeam(teamIndex);
			var len:int = team.troops.length;
			for (var i:int = 0; i < len; i++)
			{
				clientTroop = team.troops[i];
				if (clientTroop.uid == uid)
				{
					arr.push(clientTroop);
				}
			}
			return arr;
		}
		
		/**
		 * 得到是否在播放战报
		 */
		public function get isFighting():Boolean
		{
			if (!this.isInit)
				return false;
			if (this.fightLogic == null)
				return false;
			return this.fightLogic.playbacks != null;
		}
		
		/**
		 * 得到某队伍的有效显示长度，含正在作战的
		 */
		public function getTeamShowLength(teamIndex:int):int
		{
			return Math.min(ConfigFightView.TROOP_SHOW_MAX, this.getTeamLength(teamIndex));
		}
		
		public function ClientBattle(fightMain:FightMain, data:*)
		{
			this.fightMain = fightMain;
			this.countryBattleWinner = -1;
			this._fightRecords = [];
			if (ConfigApp.testFightType != 0)
			{
				data.zone = null;//'h1_1'
			}
			else if(!data.zone){
				data.zone = ModelManager.instance.modelUser.currZone;
			}
			super(data);
			
			if (this.record && this.record.records)
			{
				this._fightRecords = this.record.records;
			}
			//FightUtils.traceStr('准备战斗');
		}
		
		override public function setData(data:*):void
		{
			this.data = data;
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = FightUtils.clone(data[key]);
				}
			}
			var serverRecord:Object = data.last_battle_result;
			if (serverRecord){
				this._fightRecords.push(serverRecord);
				var troopArr:Array = serverRecord.initJS.troop;
				var teamArr:Array = data.team;
				var troopArr0:Array = teamArr[0].troop;
				var troopArr1:Array = teamArr[1].troop;
				troopArr0.unshift(troopArr[0]);
				troopArr1.unshift(troopArr[1]);
				if (serverRecord.timeScale){
					this.timeScale = serverRecord.timeScale;
				}
			}
			
			this.setDataNext(data);
		}
		
		override public function setDataComplete():void
		{
			this.updateCameraRange();
			this.fightMain.scene.initDrag();
		}
		
		public function initLoad():void
		{
			this.fightLoad = new FightLoad(this);
			this.isInit = true;
			this.fightLoad.initLoad();
		}
		
		public function loadComplete():void
		{
			if (!this.isInit)
				return;
			
			//this.readyComplete();
			this.getClientTeam(0).updateTroopShow();
			this.getClientTeam(1).updateTroopShow();

			this.isShow = true;
			this.readyFight();
			//TestFight.traceStr('数据准备完毕，开始战斗！！！');
		}
		
		public function loadPlaybacksComplete():void
		{
			if (!this.isInit)
				return;
			
			var lastWinner:int;
			//有上一场战斗
			if (this.lastFightLogic != null)
			{
				lastWinner = this.lastFightLogic.winner;
			}
			else
			{
				lastWinner = Math.random() > 0.5 ? 0 : 1;
			}
			var clientFight:ClientFight = this.getClientFight();
			
			//替补者说话
			var speakTroop:ClientTroop = clientFight.getClientTroop(1 - lastWinner);
			var otherTroop:ClientTroop = clientFight.getClientTroop(lastWinner);
			if (otherTroop.speak && !speakTroop.speak){
				var temp:ClientTroop = speakTroop;
				speakTroop = otherTroop;
				otherTroop = temp;
			}
			
			this.newStartSpeakInfo(speakTroop, otherTroop);
			clientFight.startPlaybacks();
		}
		
		/**
		 * 准备战斗
		 */
		public function readyFight():void
		{
			if (this.readyTime > 0)
			{
				if (!this.isCleared)
				{
					this.fightMain.ui.updateReady();
					this.readyTime -= 1000;
					
					Laya.timer.once(1000, this, this.readyFight);
				}
			}
			else
			{
				this.startFight();
			}
		}
		
		/**
		 * 判断逻辑战斗是否应追述或进行下一场
		 */
		override public function checkSkipTime():Boolean
		{
			return true;
		}
		
		override public function startFight():void
		{
			if (this.isWavePVE || this.isArena)
			{
				this.canSkipTime = ConfigServer.getServerTimer() / 1000;
			}

			this.fightMain.ui.updateReady();
			super.startFight();
		}
		/**
		 * 收到了战报，催促当前战斗（必定为国战）
		 */
		public function urgeFight():void
		{
			this.readyTime = 0;
			var fight:ClientFight = this.getClientFight();
			if (fight){
				//收到新的战报，加速当前战斗
				FightTime.setTimeScale(ConfigFight.fightMaxSpeed);
				//如果当前战报堆积太多，可跳过战斗
				var waitFightNum:int = this._fightRecords?this._fightRecords.length:0;
				if (waitFightNum > ConfigFight.fightSkipNum){
					fight.skip();
				}
				//trace('serverFinishFight跳过当前战斗');
				
			}else if(!this.lastFightLogic && this.isShow){
				//trace('serverFinishFight开始首场战斗');
				this.nextFight();
			}else{
				//trace('serverFinishFight空档期，未跳过');
				//FightTime.setTimeScale(ConfigFight.fightMaxSpeed);
			}
		}
		
		/**
		 * 此时无战斗，执行下一战斗
		 */
		override public function nextFight():void
		{
			//var needWait:Boolean = false;
			if(FightTime.timer)
				FightTime.timer.clear(this, this.nextFight);
				
			if (this.fightLogic)
			{
				return;
			}
			if (this.isCountry)
			{
				//国战不偷跑战斗，本场战斗必须收到战斗结果，才能开战，否则死等
				var waitFightNum:int = this._fightRecords.length;
				if (waitFightNum == 0)
				{
					if (this.countryBattleWinner >= 0)
					{
						//trace('国战结束啦啦啦');
						//var winnerTroop:ClientTroop = this.getNextFightTroop(this.countryBattleWinner);
						//if(winnerTroop)
							//FightTime.delayTo(500, winnerTroop, winnerTroop.winCheer);
						this.battleEnd();
						return;
					}
					else if (ConfigApp.testFightType){
						//测试战斗
					}
					else{
						//国战未结束，但新的战报未出现，死等
						//needWait = true;
						FightTime.delayTo(300, this, this.nextFight);
						return;
					}
				}
				else{
					//有上一场战斗的完整数据，此时做包装
					this.updateCountryBattle();
				}
			}
			super.nextFight();
			
			if (this.fightLogic){
				if (this.isWavePVE)
				{
					this.canSkipTime += this.fightLogic.getRecordTime();
				}
				else if (this.isArena){
					//擂台，可跳过时间为距离结束时间和可预期的战斗次数
					if (this.record){
						var currTime:Number = ConfigServer.getServerTimer() / 1000;
						var toEndTime:Number = this.canEndTime - currTime;
						if(toEndTime > 0){
							//剩余场均时间(秒)
							var sec:Number = toEndTime / (this.record.records.length - this.fightCount + 1);
							//trace(sec + ' / ' + toEndTime+'秒剩余，当前场次：' + this.fightCount + ' / ' + this.record.records.length);
							this.canSkipTime = currTime + sec;
						}
						//trace('距离可跳过秒：' + (this.canSkipTime - currTime));
					}
				}
			}
		}
		
		//override public function getRecord():Object
		//{
			//if (this.clientRecord == null)
			//{
				//this.clientRecord = super.getRecord();
			//}
			//return this.clientRecord;
		//}
		
		override public function battleEnd():void
		{
			//超出的倍速恢复
			FightTime.resetTimeScale();
			
			this.fightMain.ui.checkFinish();
			
			//var clientRecord:Object = this.getRecord();
			//
			if (ConfigApp.testFightType)
			{
				var clientRecord:Object = this.getRecord();
				if (this.record){
					var b:Boolean = FightUtils.compareObj(clientRecord, this.record);
					FightPrint.showFightRecordCompare(b, clientRecord, this.record);
				}
				//if (!this.record || this.isArena){
					//trace('\n客户端全战报：\n', clientRecord);
				//}
			}
			//else
			//{
			//if (!this.isCountry)
			//{
			//var serverRecord:Object = this.record;
			//var b:Boolean = FightUtils.compareObj(clientRecord, serverRecord);
			//FightPrint.showFightRecordCompare(b, clientRecord, serverRecord);
			//}
			//}
		}
		
		override public function newTeam(data:*, teamIndex:int):TeamLogic
		{
			var team:TeamLogic = new ClientTeam(data, this, teamIndex);
			return team;
		}
		
		override public function newFight():FightLogic
		{
			var fight:ClientFight = new ClientFight(this.fightMain, this.getNextFightInitJS());

			if (this.isCountry){
				if (this.speedUp > 0){
					//战鼓跳过战斗时锁定快速度
					this.speedUp--;
				}
				
				var timeScale:Number = this.getCurrentTimeScale();

				FightTime.setTimeScale(timeScale);
				var troop0:TroopLogic = fight.getTroop(0);
				var troop1:TroopLogic = fight.getTroop(1);
				this.fightMain.ui.countryUI.setBuffs(
					troop0.getCountryBuffValue(true),
					troop0.getCountryBuffValue(false),
					troop1.getCountryBuffValue(true),
					troop1.getCountryBuffValue(false)
				);
				
				if (this.isXYZ){
					//襄阳主城战，每场更新UI是否显示工具
					this.fightMain.ui.updateLowerTools();
				}
			}
			return fight;
		}
		public function getCurrentTimeScale():Number
		{
			var temp:Number;
			if(this.isCountry){
				if (this._fightRecords.length > 1){
					//有堆积的战报，极速播放
					temp = ConfigFight.fightMaxSpeed;
				}
				else if (this.speedUp > 0 || this.timeScale > ConfigFight.maxPoint){
					temp = ConfigServer.world.countryFightSpeedUpTimeScale;
					//temp = 1;
				}
				else
				{
					temp = Math.min(ConfigFight.fightMaxSpeed, this.timeScale * ConfigFight.fightHighSpeed);
				}
			}
			else{
				temp = Math.min(ConfigFight.fightHighSpeed, FightTime.timer.scale);
			}
			return temp;
		}
		
		
		override public function getNextFightInitJS():Object
		{
			var initJS:Object = super.getNextFightInitJS();
			if (initJS && this.isCountry){
				var waitFightNum:int = this._fightRecords?this._fightRecords.length:0;
				if (ConfigApp.testFightType){
					initJS.npc_reward = {'gold':Math.floor(Math.random()*888),'coin':11,'item714':4};
				}
				else{
					//正式战斗，一定有npc_reward字段
					if (waitFightNum){
						var fightRecord:Object = this._fightRecords[0];
						if(fightRecord.initJS){
							initJS.npc_reward = fightRecord.initJS.npc_reward;
						}
					}		
				}
				
				if (!initJS.speedUp){
					//如果当前战报堆积太多，可跳过战斗
					if (waitFightNum > ConfigFight.fightSkipNum+1){
						initJS.speedUp = 1;
					}
				}
			}
			return initJS;
		}
		
		public function clearTeams():void
		{
			for (var i:int = this.teams.length - 1; i >= 0; i--)
			{
				var team:ClientTeam = this.teams[i];
				team.clear();
			}
			//this.scene.clearBox();
		}
		
		/**
		 * 追加部队，读取相关素材后显示      如果有偷跑的战斗，插入N-1
		 */
		override public function addTroop(troopData:Object, teamIndex:int, troopIndex:int = -1, forgeFight:Boolean = false):TroopLogic
		{
			//在服务器战报到来前，偷跑了战斗
			if (ConfigApp.testFightType == 0 && this.isCountry)
			{
				var fight:ClientFight = this.getClientFight();
				if (fight && !fight.hasCheckRecord)
				{
					forgeFight = true;
				}
			}
			
			var clientTroop:ClientTroop = super.addTroop(troopData, teamIndex, troopIndex, forgeFight) as ClientTroop;
			var clientTeam:ClientTeam = clientTroop.getClientTeam();
			clientTeam.allTroopMoveTo(this.fightMain.scene.centerCameraOffset, clientTroop);
			if (troopIndex <= ConfigFightView.TROOP_SHOW_MAX)
				this.updateCameraRange();
			this.fightLoad.addTroopLoad(troopData, clientTroop);
			if (this.isCountry)
			{
				this.updateCountryUINum();
				if (clientTroop.uid.toString() == ModelManager.instance.modelUser.mUID)
				{
					this.fightMain.ui.updateLowerPanel();
				}
			}
			
			return clientTroop;
		}
		
		/**
		 * 通过后台接口返回位置，插入新部队
		 */
		public function addTroopBySocket(troopData:Object, teamIndex:int, front:Array, index:int = -1):void
		{
			var troopIndex:int = 0;
			if (front){
				var troop:TroopLogic = this.findTroop(teamIndex, front[1], front[0]);
				if (troop){
					troopIndex = troop.troopIndex + 1;
				}
			}
			this.addTroop(troopData, teamIndex, troopIndex);
		}
		/**
		 * 通过后台接口返回，移除已有部队
		 */
		public function removeTroopBySocket(uid:int, hid:String, teamIndex:int=-1):void
		{
			var clientTroop:ClientTroop = this.findTroop( teamIndex, hid, uid) as ClientTroop;
			if (clientTroop){
				if(clientTroop.troopIndex >= 0){
					var team:ClientTeam = this.getClientTeam(clientTroop.teamIndex);
					team.removeTroop(clientTroop.troopIndex);
				}
				else{
					//
					console.error('突进或撤军的部队正在战斗中，战斗结束后退出');
				}
			}
		}
		
		
		/**
		 * 移除部队
		 */
		override public function removeTroop(troopLogic:TroopLogic):Boolean
		{
			var bool:Boolean = super.removeTroop(troopLogic);
			if (bool)
			{
				var clientTroop:ClientTroop = troopLogic as ClientTroop;
				if (ConfigApp.testFightType == 2)
				{
					clientTroop.clear();
				}
				else
				{
					clientTroop.back(true);
				}
			}
			
			return bool;
		}
		
		public function updateCountryUINum():void
		{
			if (this.fightMain.ui.countryUI)
			{
				this.fightMain.ui.countryUI.updateNum(this.getTeamLength(0), this.getTeamLength(1));
			}
		}
		
		public function updateCountryUIFightCount():void
		{
			if (this.fightMain.ui.countryUI)
			{
				this.fightMain.ui.countryUI.updateFightCount(this.fightCount);
			}
		}
		
		/**
		 * 战斗逻辑和记录都结算完毕，视图开始，刷新部队和UI
		 */
		override protected function fightStartUpdate():void
		{
			var team0:ClientTeam = this.getClientTeam(0);
			var team1:ClientTeam = this.getClientTeam(1);
			
			//有上一场战斗
			if (this.lastFightLogic != null)
			{
				//if (this.mode == ConfigFight.MODE_WHEEL)
				//{
				////推进1身位
				//this.fightMain.scene.centerCameraOffset += ConfigFightView.TROOP_INTERVAL * (this.lastFightLogic.winner == 0 ? 1 : -1);
				//}
				FightTime.delayTo(1500, team0, team0.updateTroopShow);
				FightTime.delayTo(1500, team1, team1.updateTroopShow);
			}
			else
			{
				team0.updateTroopShow();
				team1.updateTroopShow();
			}

			this.updateCameraRange();
			this.updateCountryUIFightCount();
			this.fightMain.ui.showStart();
			
			//逻辑执行完毕，对比战报
			this.checkRecord();
			//if (ConfigApp.testFightType == 0 && this.isCountry)
			//{
				//this.checkRecord();
			//}
			
			if (ConfigApp.testFightType == 2)
			{
				//特殊测试
				FightMain.instance.ui.updateLowerPanel();
			}
			else if (this.isCountry)
			{
				//国战
				FightMain.instance.ui.updateLowerPanel();
			}
		}
		
		/**
		 * 战斗回放结束，结束回放，败者英雄副将阵亡UI消失，胜者小欢呼/撤回准备下一战
		 */
		public function playbackEnd():void
		{
			//var b:Boolean = this.checkRecord();
			//真实国战，如果不能完成校验，不能完结战斗
			//if (this.isCountry && !b)
			//{
				//Laya.timer.once(1000, this, this.playbackEnd);
				//return;
			//}
			
			//else{
			//trace('\n客户端战报：\n', this.getClientFight().getRecord());
			//}
			
			//战败者退场
			var lastFight:ClientFight = this.getClientFight();
			lastFight.fightPlayback = null;
			var centerX:Number;
			var scene:FightScene = this.fightMain.scene;
			var winnerTeam:ClientTeam = this.teams[lastFight.winner];
			var winnerTroop:ClientTroop = lastFight.getClientTroop(lastFight.winner);
			var loserTeam:ClientTeam = this.teams[lastFight.loser];
			var loserTroop:ClientTroop = lastFight.getClientTroop(lastFight.loser);
			loserTroop.lose();
			
			var winnerHero:ClientHero = winnerTroop.getClientHero();
			var winnerLossHpPer:Number = 1 - winnerTroop.getHpPer() / winnerTroop.getInitHpPer();
			var winnerType:int = -1;
			
			loserTroop.fightTroopInfo.updateFirst(false);
			winnerTroop.fightTroopInfo.updateFirst(false);
			loserTroop.fightTroopInfo.updateAdept(false);
			winnerTroop.fightTroopInfo.updateAdept(false);
			loserTroop.fightTroopInfo.clearBeastNum();
			winnerTroop.fightTroopInfo.clearBeastNum();
			
			//结算一场战斗，此后战斗为空
			this.endFight();
			
			var rewardArr:Array;
			var bagCom:bagItemUI;
			var len:int;
			var i:int;
			var key:String;
			var aimX:int;
			var aimY:int;
			var dropX:int;
			
			//特殊测试，掉落银币
			if (ConfigApp.testFightType == 2)
			{
				if (lastFight.winner == 0)
				{
					var gold:int = loserTroop.data.gold ? loserTroop.data.gold : (Math.pow(loserTroop.data.lv, 2) * 50 + 200);
					TestCopyright.sendGainGold(gold);
				}
			}
			else if (this.isCountry)
			{
				winnerTroop.fightTroopInfo.updateProud(winnerTroop.proud);
				winnerType = winnerTroop.teamIndex;
				if (FightMain.instance.ui)
					FightMain.instance.ui.updateLowerPanel();
				
					
				//留下本场战斗NPC掉落的奖励
				var npc_reward:Object = lastFight.npc_reward;
				if (npc_reward){
					dropX = ConfigFightView.ROUND_OFFSET[Math.min(lastFight.playbackRound,ConfigFightView.ROUND_OFFSET.length-1)] -ConfigFightView.ROUND_OFFSET[0] + ConfigFightView.DROP_X;
					var uid:int = FightMain.getCurrUid();
					len = FightUtils.getObjectLength(npc_reward);
					i = 0;
					for (key in npc_reward)
					{
						//rewardArr = allRewardArr[i];
						bagCom = new bagItemUI();
						bagCom.setData(key, npc_reward[key], -1);
						bagCom.x = 90 * (i - (len - 1) / 2) + dropX;
						bagCom.y = Laya.stage.height * 0.5;
						bagCom.scale(0.6, 0.6);
						aimX = Laya.stage.width - dropX;
						i++;
						if (loserTroop.teamIndex == 1){
							//输的人是守方，在守方掉落到攻方
							bagCom.x = Laya.stage.width - bagCom.x;
							aimX = dropX;
						}

						if (winnerTroop.uid == uid)
						{
							//飞到自家仓库
							EffectManager.itemFlight(bagCom, Laya.stage.width / 2 + 80, Laya.stage.height - 50, FightMain.instance.ui.infoLayer, true);
						}
						else{
							//飞到友军身上
							EffectManager.itemFlight(bagCom, aimX, Laya.stage.height * 0.5, FightMain.instance.ui.infoLayer, false);
						}
					}
				}
				FightEvent.ED.event(EventConstant.FIGHT_NEXT);
			}
			else if (this.isTired)
			{
				winnerTroop.fightTroopInfo.updateProud(winnerTroop.proud);
			}
			else if (this.isWavePVE)
			{
				//改变波数，掉落物资
				if (lastFight.winner == 0)
				{
					var waveKill:int = this.getWaveKill(true);
					var waveReward:* = this.getWaveReward(waveKill - 1);
					var delay:int = 1000;
					aimX = 60;
					aimY = Laya.stage.height - 75;
					if (waveReward)
					{
						dropX = Laya.stage.width - (ConfigFightView.ROUND_OFFSET[Math.min(lastFight.playbackRound,ConfigFightView.ROUND_OFFSET.length-1)] -ConfigFightView.ROUND_OFFSET[0] + ConfigFightView.DROP_X);
						if (waveReward is Array){
							rewardArr = waveReward as Array;
							bagCom = new bagItemUI();
							bagCom.setData(rewardArr[0], rewardArr[1], -1);
							bagCom.x = dropX;
							bagCom.y = Laya.stage.height * 0.5;
							bagCom.scale(0.6, 0.6);
							delay = Math.max(delay,EffectManager.itemFlight(bagCom, aimX, aimY, FightMain.instance.ui.infoLayer, false));
						}
						else{
							len = FightUtils.getObjectLength(waveReward);
							i = 0;
							for (key in waveReward)
							{
								//rewardArr = allRewardArr[i];
								bagCom = new bagItemUI();
								bagCom.setData(key, waveReward[key], -1);
								bagCom.x = 90 * (i - (len - 1) / 2) + dropX;
								bagCom.y = Laya.stage.height * 0.5;
								bagCom.scale(0.6, 0.6);
								i++;
								delay = Math.max(delay,EffectManager.itemFlight(bagCom, aimX, aimY, FightMain.instance.ui.infoLayer, false));
							}
						}
					}
					Laya.timer.once(delay, this, function(num:int):void
					{
						if (FightMain.instance.ui)
							FightMain.instance.ui.updateLowerPanel(num);
					}, [waveKill]);
				}
			}
			
			this.updateCountryUINum();
			
			if (this.hasNextFight())
			{
				//有下一战
				var nextTime:Number;
				
				if (this.isWheel)
				{
					//推进1身位
					centerX = scene.centerCameraOffset + ConfigFightView.TROOP_INTERVAL * (lastFight.winner == 0 ? 1 : -1);
					scene.centerCameraOffset = centerX;
					
					if (winnerTroop.troopIndex == 0)
					{
						//胜者连战，短暂欢呼，胜者方候补前进1个身位，胜者只补齐到一个身位
						FightTime.delayTo(500, winnerTroop, winnerTroop.winCheer);
						FightTime.delayTo(1500, winnerTeam, winnerTeam.allTroopMoveTo, [centerX]);
						this.newEndSpeakInfo(winnerHero, 'combo', winnerLossHpPer, winnerType);
						nextTime = 2000;
					}
					else
					{
						//胜者短暂欢呼，退场，胜者方候补前进2个身位
						FightTime.delayTo(500, winnerTroop, winnerTroop.winBack);
						FightTime.delayTo(1500, winnerTeam, winnerTeam.allTroopMoveTo, [centerX, winnerTroop]);
						this.newEndSpeakInfo(winnerHero, 'back', winnerLossHpPer, winnerType);
						nextTime = 2500;
					}
				}
				else if (this.isMatch)
				{
					//胜者短暂欢呼，退场，双方候补前进1个身位
					centerX = scene.centerCameraOffset;
					FightTime.delayTo(500, winnerTroop, winnerTroop.winBack);
					FightTime.delayTo(1500, winnerTeam, winnerTeam.allTroopMoveTo, [centerX, winnerTroop]);
					FightTime.delayTo(1500, loserTeam, loserTeam.allTroopMoveTo, [centerX]);
					this.newEndSpeakInfo(winnerHero, 'easy', winnerLossHpPer, winnerType);
					nextTime = 2000;
				}
				
				var tweenTime:int = (this.speedUp > 0 || this.timeScale > ConfigFight.maxPoint)?900:1500;
				
				
				FightTime.delayTo(nextTime, scene, scene.tweenToCenter,[tweenTime]);
				FightTime.delayTo(nextTime + 1000, this, this.nextFight);
			}
			else
			{
				if (this.isCountry && ConfigApp.testFightType == 0)
				{
					//可能在等待结束
					this.nextFight();
				}
				else
				{
					//无下一战，长欢呼
					FightTime.delayTo(500, winnerTroop, winnerTroop.winCheer);
					//this.newEndSpeakInfo(winnerHero, 'win', winnerLossHpPer, winnerType);
					this.battleEnd();
				}
			}
		}
		
		/**
		 * 战斗开始生成英雄说话
		 */
		public function newStartSpeakInfo(speakTroop:ClientTroop, otherTroop:ClientTroop):void
		{
			if (ConfigServer.effect.fightSpeakTime <= 0)
				return;

			var info:String;
			var clientHero:ClientHero = speakTroop.getClientHero();
			
			if (speakTroop.speak){
				info = Tools.getMsgById(speakTroop.speak,null,false);
			}
			else{
				//如果战力远小于对手，且兵力小于对手，则漏出胆怯
				var infoKey:String = 'start';
				if (speakTroop.power / otherTroop.power < 0.5)
				{
					if (speakTroop.getAllHp() < otherTroop.getAllHp())
					{
						infoKey = 'weak';
					}
				}
				
				info = this.getHeroSpeakInfo(clientHero.id, infoKey);
			}
			if (info)
			{
				new FSpeak(clientHero, info);
			}
		}
		
		/**
		 * 战斗结束生成英雄说话
		 */
		public function newEndSpeakInfo(clientHero:ClientHero, infoKey:String, lossHpPer:Number, winnerType:int = -1):void
		{
			if (ConfigServer.effect.fightSpeakTime <= 0)
				return;
			
			var info:String;
			var tempKey:String;
			//if (infoKey == 'win'){
			//
			//}
			if (winnerType >= 0 && Math.random() > 0.7)
			{
				//国战攻防
				infoKey = winnerType == 1 ? 'def' : 'atk';
			}
			else if (lossHpPer >= 0.5 && Math.random() < lossHpPer + 0.2)
			{
				//苦战
				infoKey = 'hard';
			}
			else if (lossHpPer <= 0.15 && Math.random() > 0.7)
			{
				//轻松战
				infoKey = 'easy';
			}
			
			info = this.getHeroSpeakInfo(clientHero.id, infoKey);
			if (info)
			{
				new FSpeak(clientHero, info);
			}
		}
		
		/**
		 * 获得指定英雄的指定类型战斗说话，自动向下适配
		 */
		public function getHeroSpeakInfo(hid:String, infoKey:String):String
		{
			var fightSpeakCfg:Object = ConfigServer.effect.fightSpeak;
			if (!fightSpeakCfg)
				return null;
			var infoArr:Array;
			var heroCfg:Object = ConfigServer.hero[hid];
			var obj:Object;
			var key:String;
			obj = fightSpeakCfg[hid];
			if (obj && obj[infoKey])
			{
				infoArr = obj[infoKey];
			}
			else
			{
				var heroChar:String = hid.charAt(4);
				if (heroChar == '7')
				{
					key = 'type' + heroCfg.type + 'sex' + heroCfg.sex;
				}
				else
				{
					key = 'type' + heroCfg.type;
				}
				obj = fightSpeakCfg[key];
				if (obj && obj[infoKey])
				{
					infoArr = obj[infoKey];
				}
				else
				{
					obj = fightSpeakCfg['default'];
					infoArr = obj[infoKey];
				}
			}
			if (!infoArr)
				return null;
			//修改默认英雄和辅助技能
			var info:String = infoArr[Math.floor(Math.random() * infoArr.length)];
			if (info)
				info = Tools.getMsgById(info);
			return info;
		}
		
		/**
		 * 判断是否应跳过战斗回放过程
		 */
		public function checkSkip():Boolean
		{
			//if (ConfigApp.testFightType == 0 && this.isCountry)
			//{
			////真实国战，有战斗结果，直接跳过
			//if (this._fightRecords.length > 0)
			//{
			//return true;
			//}
			//}
			return false;
		}
		
		/**
		 * 更新摄像机可以拖动的范围
		 */
		public function updateCameraRange():void
		{
			var centerCameraOffset:Number = this.fightMain.scene.centerCameraOffset;
			this.fightMain.scene.maxCameraOffset = centerCameraOffset + (this.getTeamShowLength(1) + 0.5) * ConfigFightView.TROOP_INTERVAL;
			this.fightMain.scene.minCameraOffset = centerCameraOffset - (this.getTeamShowLength(0) + 0.5) * ConfigFightView.TROOP_INTERVAL;
		}
		
		/**
		 * 重播战斗回放
		 */
		public function replay():void
		{
			var fight:ClientFight = this.getClientFight();
			if (fight != null)
			{
				fight.replay();
			}
		}
		
		/**
		 * 跳过一场战斗回放
		 */
		public function skip(isForce:Boolean = false):void
		{
			if (!isForce && !this.canSkip())
				return;
			
			if (ConfigApp.testFightType == 1)
			{
				if (this.readyTime > 0)
				{
					this.readyTime = 0;
					return;
				}
			}
			var fight:ClientFight = this.getClientFight();
			if (fight != null)
			{
				//trace('skipskipskip!!!!!');
				fight.skip();
			}
		}
		
		public function canSkip():Boolean
		{
			//if (ConfigApp.testFightType == 1)
			//{
				//return true;
			//}
			//if (this.limitButton){
			////强制引导中禁止跳过
			//return false;
			//}
			
			var fight:ClientFight = this.getClientFight();
			if (fight != null)
			{
				if (!fight.fightPlayback)
				{
					return false;
				}
				if (this.canSkipTime)
				{
					return this.canSkipTime <= ConfigServer.getServerTimer() / 1000;
				}
				else
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 以上一场收到的国战数据，更新当前战斗
		 */
		public function updateCountryBattle():void
		{
			if (!this._fightRecords || this._fightRecords.length == 0)
				return;
			var serverRecord:Object = this._fightRecords[0];
			
			var serverInitJS:Object = serverRecord.initJS;
			if (serverInitJS){
				//包含完整的js初始化信息，开始对比，如果必要则重置部队显示
				if (TestUtils.isTestShow){
					var clientInitJS:Object = this.getNextFightInitJS();
					if(clientInitJS){
						if (clientInitJS.rnd != serverInitJS.rnd){
							clientInitJS.rnd = serverInitJS.rnd;
						}
						var b:Boolean = FightUtils.compareObj(clientInitJS, serverInitJS);
						FightPrint.showFightInitJSCompare(b, clientInitJS, serverInitJS);
					}
				}
				this.seedBase = this.seedCurr = serverInitJS.rnd;
				//this.random.initSeed(serverInitJS.rnd);
				if (serverInitJS.timeScale){
					this.timeScale = serverInitJS.timeScale;
				}
				
				this.fight_count = serverInitJS.fight_count;
				//如果部队中数据包含door，覆盖country_logs中的本国数据
				var log:Object;
				//以后端为准，重置对应部队的数据和显示
				var troop0:ClientTroop = this.getNextFightTroop(0) as ClientTroop;
				if(troop0){
					troop0.resetDataAndLogic(serverInitJS.troop[0]);
					log = this.country_logs[troop0.country];
					if (log){
						log.door = troop0.getDoorValue();
					}
				}
				var troop1:ClientTroop = this.getNextFightTroop(1) as ClientTroop;
				if(troop1){
					troop1.resetDataAndLogic(serverInitJS.troop[1]);
					log = this.country_logs[troop1.country];
					if (log){
						log.door = troop1.getDoorValue();
					}
				}
			}
			
		}
		/**
		 * 收到国战数据，跳过国战当前战斗
		 */
		public function serverFinishFight(serverRecord:Object):void
		{
			this._fightRecords.push(serverRecord);
			//var serverInitJS:Object = serverRecord.initJS;
			//if (serverInitJS){
				////包含完整的js初始化信息，开始对比，如果必要则重置部队显示
				//if (TestUtils.isTestShow){
					//var clientInitJS:Object = this.getNextFightInitJS();
					//if (clientInitJS.rnd != serverInitJS.rnd){
						//clientInitJS.rnd = serverInitJS.rnd;
					//}
					//var b:Boolean = FightUtils.compareObj(clientInitJS, serverInitJS);
					//FightPrint.showFightInitJSCompare(b, clientInitJS, serverInitJS);
				//}
				////this.random.initSeed(serverInitJS.rnd);
				////以后端为准，重置对应部队的数据和显示
				//var troop0:ClientTroop = this.getNextFightTroop(0) as ClientTroop;
				//troop0.resetDataAndLogic(serverInitJS.troop[0]);
				//var troop1:ClientTroop = this.getNextFightTroop(1) as ClientTroop;
				//troop1.resetDataAndLogic(serverInitJS.troop[1]);
			//}
			
			this.urgeFight();
		}
		
		/**
		 * 收到国战完整结束
		 */
		public function serverEndBattle(country:int):void
		{
			this.countryBattleWinner = (this.fireCountry == country) ? 0 : 1;
		}
		
		/**
		 * 单场战斗结束时，对当前战斗进行战报结果校验，返回是否可校验
		 */
		public function checkRecord():Boolean
		{
			var fight:ClientFight = this.getClientFight();
			if (fight)
			{
				if (fight.hasCheckRecord)
				{
					return true;
				}
				else
				{
					var serverRecord:Object;
					if (this.isCountry)
					{
						if (this._fightRecords.length > 0)
						{
							serverRecord = this._fightRecords.shift();
							fight.checkRecord(serverRecord.result);
							return true;
						}
						else if (ConfigApp.testFightType)
						{
							return true;
						}
					}
					else
					{
						//其他模式不弹出战报，只对应取出当前位置战报对比
						if (this._fightRecords.length >= this.fightCount)
						{
							serverRecord = this._fightRecords[this.fightCount - 1];
							fight.checkRecord(serverRecord);
							return true;
						}
					}
					
				}
			}
			//无战斗，不应有此现象
			return false;
		}
		
		/**
		 * 得到当前玩家所代表的队伍 0攻方 1守方 -1未参加
		 */
		public function getSelfTeam():int
		{
			for (var i:int = 0; i < 2; i++) 
			{
				var team:ClientTeam = this.getClientTeam(i);
				if (team.uid && team.uid == FightMain.getCurrUid()){
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * 播放对应的背景音乐
		 */
		public function playBGM():void
		{
			var cfg:Object = ConfigServer.effect.fightBGM;
			var url:String = cfg[this.mode.toString()];
			
			if (!url)
			{
				url = cfg['default'];
			}
			MusicManager.playMusic(url);
		
		}
		
		override public function clear():void
		{
			Laya.timer.clear(this, this.readyFight);
			FightTime.timer.clear(this, this.nextFight);
			//Laya.timer.clear(this, this.playbackEnd);
			super.clear();
			if(this.fightLoad){
				this.fightLoad.clear();
				this.fightLoad = null;
			}
			this.isInit = false;
			this._fightRecords = null;
		}
	
	}

}