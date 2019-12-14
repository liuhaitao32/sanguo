package sg.fight.logic
{
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.unit.TeamLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightClimbUtils;
	import sg.fight.logic.utils.FightRandom;
	import sg.fight.logic.utils.FightUtils;
	import sg.model.ModelOfficial;
	import sg.model.ModelPrepare;
	
	/**
	 * 战场，可能包含多队等待，子类里再分国战等特殊战场
	 * @author zhuda
	 */
	public class BattleLogic extends LogicModeBase
	{
		///从服务器获得的所有战报信息
		public var record:Object;
		
		///战役中连续战斗，纪录的战报
		public var fightRecords:Array;
		///最初随机种子（PVP则与当前相同）
		public var seedBase:int;
		///当前随机种子（PVE自动变更）
		public var seedCurr:int;
		
		///区服ID
		public var zone:String;
		///战斗名称
		public var title:String;
		///战斗id,s_开头的都是个人战斗，其他直接为城市id
		public var city:String;
		///国战的守城方
		public var country:int;
		///国战的攻城方
		public var fireCountry:int;
		///准备战斗倒计时毫秒，为0时表示已真正开战
		public var readyTime:int;
		///本场战斗计划要快速跳过的场数
		public var speedUp:int;
		///当前的国战速率默认为1
		public var timeScale:Number;
		
		///过关斩将数据
		public var climb:Object;
		///战斗中的奖励（整体）
		public var gift:Object;
		///战斗中的奖励（按波分）
		public var reward:Object;
		///之前战斗中已击杀波数
		public var lastKillWave:int;
		///存储本战役，对应玩家id，出席过的英雄，供合击技使用(要放入fight)
		//public var attends:Object;
		///擂台战斗专用存储，战斗开始时守擂方的hpm
		public var arenaHpm:int;
		///擂台战斗的类型
		public var arena_group:int;
		///战役对双方的加减成效果
		public var battle_special:Object;
		
		///存储国战或野战发生的战斗次数
		public var fight_count:int;
		///存储国战中防守方的箭楼、石炮等级[2,2]
		public var tower:Array;
		///存储国战战役，各个队伍的最高纪录保持者{kill:[uid,value],power:[uid,value],official:[uid,value]}(杀敌，战力，官职。官职buff要放入fight)
		public var teamBest:Array;
		///存储战役，各个玩家id的登入信息实体{uid:{uname,head,official,country,power,kill,guild_id,guild_name,attends}}
		public var user_logs:Object;
		///存储国战战役，各个国家id的登入信息实体{countryId:{buff:[2221,221],milepost:2,door:0.75}}
		public var country_logs:Object;
		
		///快速跳过该秒数范围内的战斗，用于客户端追赶秒数
		public var skipTime:Number;


		///胜者傲气模式
		//public var proud:int;
		
		//以下属性不直接在data中
		
		///0为进攻方 1为防守方
		public var teams:Array;
		///当前正在进行的战斗，为空时战场未开始或已结束
		public var fightLogic:FightLogic;
		///记录上次进行的战斗，方便客户端完整清理
		public var lastFightLogic:FightLogic;
		
		///当前的过关斩将配置对象(取得对应服务器的过关斩将配置，服务器JS用，勿删)
		public var climbCfg:Object;
		
		///已经导出的战报
		protected var _record:Object;
		///是否自动进行下一战
		protected var _autoNextFight:Boolean;
		
		/**
		 * 是否是客户端版
		 */
		public function get isClient():Boolean
		{
			return false;
		}
		
		/**
		 * 襄阳主城战模式
		 */
		public function get isXYZMain():Boolean
		{
			return this.mode == 0 && this.city && this.city.toString() == '-1';
		}
		/**
		 * 襄阳战模式
		 */
		public function get isXYZ():Boolean
		{
			return this.mode == 0 && this.city && this.city.toString().indexOf('-') == 0;
		}
		/**
		 * 得到国战下，当前完全的伤害免伤加成显示值（来源于城池信仰、关城建筑、襄阳城门、国战buff）
		 */
		public function getCountryBuffValue(country:int, isDmg:Boolean):Number
		{
			var value:Number = 0;
			if (this.isCountry && this.country_logs){
				var log:Object = this.country_logs[country];
				if (log){
					if (log.buff){
						var buffArr:Array = log.buff;
						value += buffArr[isDmg?0:1];
					}
					if (log.door){
						value += log.door;
					}
				}
			}
			return value;
		}
		
		
		/**
		 * 获得某个玩家id出席过的英雄
		 */
		//public function getAttendHeroIds(uid:String):Object {
		//return this.attends[uid];
		//}
		/**
		 * 判别国战之最更替
		 */
		public function checkTeamBest(teamIndex:int, uid:int):Boolean
		{
			if (uid < 0)
				return false;
			var isChange:Boolean = false;
			var userObj:Object = this.user_logs[uid.toString()];
			if (userObj)
			{
				var bestObj:Object = this.teamBest[teamIndex];
				if (userObj.kill)
				{
					if (!bestObj.kill || bestObj.kill[1] < userObj.kill)
					{
						bestObj.kill = [uid, userObj.kill];
						isChange = true;
					}
				}
				if (!bestObj.power || bestObj.power[1] < userObj.power)
				{
					bestObj.power = [uid, userObj.power];
					isChange = true;
				}
				
				if (userObj.official != null && userObj.official >= 0)
				{
					var newOfficialId:String = userObj.official;
					
					if (!bestObj.official)
					{
						bestObj.official = [uid, newOfficialId];
						isChange = true;
					}
					else
					{
						var oldOfficialId:String = bestObj.official[1];
						var newOfficialConfig:Object = ModelOfficial.getOfficerCfg(newOfficialId);
						var oldOfficialConfig:Object = ModelOfficial.getOfficerCfg(oldOfficialId);
						if (newOfficialConfig.level > oldOfficialConfig.level)
						{
							bestObj.official = [uid, newOfficialId];
							isChange = true;
						}
					}
				}
			}
			return isChange;
		}
		
		/**
		 * 得到某队伍的有效长度，含正在作战的
		 */
		public function getTeamLength(teamIndex:int):int
		{
			var num:int = this.fightLogic == null ? 0 : 1;
			num += this.getTeam(teamIndex).troops.length;
			return num;
		}
		
		/**
		 ** 得到服务器记录中，当前战斗消耗的秒数，isLast上一场战斗
		 */
		public function getRecordFightTime(isLast:Boolean = false):Number
		{
			if (!this.record)
			{
				return -1;
			}
			var recordArr:Array = this.record.records;
			var fightCount:int = this.fightCount;
			if (isLast)
			{
				fightCount = fightCount - 1;
			}
			if (fightCount >= recordArr.length)
			{
				return -1;
			}
			return recordArr[fightCount].time;
		}
		
		/**
		 * 得到本波奖励
		 */
		public function getWaveReward(waveKill:int):Array
		{
			if (!reward)
				return null;
			return reward[waveKill.toString()];
		}
		
		/**
		 * 得到已击杀PVE敌方波数
		 */
		public function getWaveKill(containLast:Boolean = false):int
		{
			return this.getWaveTotal(containLast) - this.getTeamLength(1);
		}
		
		/**
		 * 得到PVE敌方总波数
		 */
		public function getWaveTotal(containLast:Boolean = false):int
		{
			var num:int = this.data.team[1].troop.length;
			if (containLast) num += this.lastKillWave;
			return num;
		}
		
		/**
		 * 从原始数据中找出对应英雄部队的数据
		 */
		public function findTroopData(teamIndex:int, hid:*):Object
		{
			var troops:Array = this.data.team[teamIndex].troop;
			var troopObj:Object;
			for (var i:int = troops.length - 1; i >= 0; i--)
			{
				troopObj = troops[i];
				if(hid is String){
					if (troopObj.hid == hid)
					{
						return troopObj;
					}
				}
				else{
					if (i == hid)
					{
						return troopObj;
					}
				}
			}
			return null;
		}
		
		public function findTroop(teamIndex:int, hid:String, uid:int = -1):TroopLogic
		{
			var troop:TroopLogic;
			if (teamIndex < 0)
			{
				troop = this.findTroop(0, hid, uid);
				if (!troop)
				{
					troop = this.findTroop(1, hid, uid);
				}
				return troop;
			}
			
			if (this.fightLogic != null)
			{
				troop = this.fightLogic.getTroop(teamIndex);
				if ((!hid || troop.hid == hid) && (uid < 0 || troop.uid == uid))
				{
					return troop;
				}
			}
			var team:TeamLogic = this.getTeam(teamIndex);
			for (var i:int = team.troops.length - 1; i >= 0; i--)
			{
				troop = team.troops[i];
				if ((!hid || troop.hid == hid) && (uid < 0 || troop.uid == uid))
				{
					return troop;
				}
			}
			return null;
		}
		
		/**
		 * 当前已战斗对决次数
		 */
		public function get fightCount():int
		{
			if (this.isCountry){
				return this.fight_count;
			}else{
				return this.fightRecords.length + this.fight_count;
			}
		}
		
		public function BattleLogic(data:*)
		{
			super(data);
		}
		
		/**
		 * 判断逻辑战斗是否应追述或进行下一场
		 */
		public function checkSkipTime():Boolean
		{
			if (this.skipTime)
			{
				var recordFightTime:Number = this.getRecordFightTime();
				if (recordFightTime < 0)
				{
					recordFightTime = ConfigServer.world.fieldFightTimeRange[0];
				}
				if (this.skipTime > recordFightTime)
				{
					return true;
				}
				return false;
			}
			return true;
		}
		
		/**
		 * 开始战斗
		 */
		public function startFight():void
		{
			if (!this.checkSkipTime())
			{
				return;
			}
			this.checkInitBattleData();
			this.nextFight();
		}
		/**
		 * 结束战役
		 */
		public function battleEnd():void
		{
		
		}
		
		/**
		 * 检查战役是否需要的备份初始化数据（擂台）
		 */
		public function checkInitBattleData():void
		{
			if (this.isArena){
				this.arenaHpm = 0;
				var team:TeamLogic = this.getTeam(1);
				var len:int = team.troops.length;
				for (var i:int = 0; i < len; i++) 
				{
					var troop:TroopLogic = team.troops[i];
					this.arenaHpm += troop.getAllHpMax();
				}
			}
			if(!this.battle_special)
				this.battle_special = ConfigFight.getBattleSpecial(this.mode);
		}
		
		public function hasNextFight():Boolean
		{
			if (this.teams[0].troops.length > 0 && this.teams[1].troops.length > 0)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 此时无战斗，执行下一战斗，返回是否有下一场战斗
		 */
		public function nextFight():void
		{
			var team0:TeamLogic = this.teams[0];
			var team1:TeamLogic = this.teams[1];
			if (team0.troops.length > 0 && team1.troops.length > 0)
			{
				this.fightLogic = this.newFight();
				team0.troops.shift();
				team1.troops.shift();
				//trace( this.fightLogic);
				this.fightLogic.start();
				//trace( this.fightLogic);
				team0.updateTroopIndex();
				team1.updateTroopIndex();
				this.fightRecords.push(this.fightLogic.getRecord());
				this.seedCurr = this.fightLogic.random.seed;
				
				if (this.isCountry){
					this.fight_count++;
				}
				this.fightStartUpdate();
			}
			else
			{
				this.battleEnd();
			}
		}
		
		/**
		 * 战斗逻辑和记录都结算完毕，视图开始，刷新部队和UI
		 */
		protected function fightStartUpdate():void
		{
			this.endFight();
			if (this.skipTime)
			{
				var lastFightTime:Number = this.getRecordFightTime(true);
				var nextFightTime:Number = this.getRecordFightTime();
				if (lastFightTime < 0)
				{
					lastFightTime = this.lastFightLogic.getRecordTime();
				}
				if (nextFightTime < 0)
				{
					nextFightTime = ConfigServer.world.fieldFightTimeRange[0];
				}
				this.skipTime -= lastFightTime;
				if (this.skipTime <= nextFightTime)
				{
					return;
				}
			}
			this.nextFight();
		}
		
		/**
		 * 结算一场战斗（只有客户端或客户端模拟的服务端战斗才有，下一场开始前调用，结束后fightLogic==null）
		 */
		public function endFight():void
		{
			if (this.fightLogic != null)
			{
				//有当前战斗，需要立即到达结算状态，败方退场
				if (this.lastFightLogic != null)
				{
					if (this.isWheel)
					{
						//清理上一场的败者
					}
					else
					{
						//清理上一场的胜败者
					}
				}
				this.lastFightLogic = this.fightLogic;
				
				var troop0:TroopLogic = this.fightLogic.getTroop(0);
				var troop1:TroopLogic = this.fightLogic.getTroop(1);
				var winnerTroop:TroopLogic = this.fightLogic.winner == 0 ? troop0 : troop1;
				var userLog:Object;
				
				troop0.resetEnd();
				troop1.resetEnd();
				
				if (this.isCountry)
				{
					//国战，纪录击杀, 胜者结算傲气
					winnerTroop.proud++;
					
					if (!troop0.isNpc || !troop1.isNpc)
					{
						var fightRecord:Object = this.fightRecords[this.fightRecords.length - 1];
						
						if (!troop0.isNpc)
						{
							userLog = this.user_logs[troop0.uid.toString()];
							if(userLog){
								userLog.kill += fightRecord.troop[1].dead;
								this.checkTeamBest(0, troop0.uid);
							}
						}
						if (!troop1.isNpc)
						{
							userLog = this.user_logs[troop1.uid.toString()];
							if(userLog){
								userLog.kill += fightRecord.troop[0].dead;
								this.checkTeamBest(1, troop1.uid);
							}
						}
					}
				}
				else if (this.isTired)
				{
					//胜者结算疲劳
					winnerTroop.proud--;
					//winnerTroop.proud -= 6;
				}
				
				if (this.isWheel || this.isSolo)
				{
					if (this.isClimbPVE)
					{
						//过关斩将，敌方失败则补充一波，仅服务端或纯逻辑执行
						this.addClimbTroop();
					}
					if (winnerTroop.isNpc)
					{
						if (winnerTroop.proud < ConfigServer.world.npcBackProud){
							//NPC排到队首继续作战
							this.troopStick(winnerTroop);
						}
						else{
							//NPC傲气已高，排到队尾
							this.troopBackEnd(winnerTroop);
						}
					}
					else
					{
						//玩家胜利后插入参数N。插入到max(连续玩家尾,min(队尾，N))
						this.troopBack(winnerTroop);
					}
				}
				
				this.fightLogic = null;
			}
		}
		
		public function getTeam(index:int):TeamLogic
		{
			return this.teams[index];
		}
		
		public function newTeam(data:*, teamIndex:int):TeamLogic
		{
			var team:TeamLogic = new TeamLogic(data, this, teamIndex);
			return team;
		}
		
		/**
		 * newFight之前包装战斗部队数据
		 */
		protected function packFightTroop(troop:TroopLogic):void
		{
			if (ConfigApp.hasDocument && ConfigApp.testFightType){
				//客户端测试环境自动包装
				troop.others = {};
				if (!troop.isNpc)
				{
					var userLog:Object = this.user_logs[troop.uid];
					if(userLog){
						troop.others.attends = userLog.attends;
					}
				}
				this.packTroopOthersSpirit(troop);
				
				if (this.isCountry)
				{
					troop.others.official = this.getCountryOfficial(troop.country);
					if (troop.teamIndex == 1 && this.tower)
					{
						troop.others.tower = this.tower;
					}
					
					var country_log:Object = this.country_logs[troop.country];
					if(country_log){
						troop.others.buff = country_log.buff;
						if (country_log.door){
							troop.others.door = country_log.door;
						}
						troop.others.milepost = country_log.milepost;
					}
				}
			}else{
				//正式环境，非国战才自动包装
				if (!this.isCountry){
					troop.others = {};
					if (!troop.isNpc)
					{
						troop.others.attends = this.user_logs[troop.uid].attends;
					}
					this.packTroopOthersSpirit(troop);
					
					//this.packBattleSpecial(troop);
				}
			}
		}

		/**
		 * 战前，包装所有参战激励将，提供属性加成
		 */
		protected function packTroopOthersSpirit(troop:TroopLogic):void
		{
			if (ConfigApp.hasDocument && ConfigApp.testFightType){
				//客户端测试环境自动包装
				var others:Object = troop.data.others;
				if (others && others.spirit){
					troop.others.spirit = others.spirit;
					return;
				}
			}
			var cfg:Object = ConfigFight.legendTalentFight;
			if (troop.isNpc){
				//是NPC，只考虑自身加成
				if (cfg[troop.hid]){
					troop.others.spirit = [[troop.hid,troop.heroLogic.hero_star]];
				}
			}
			else{
				var team:TeamLogic = this.getTeam(troop.teamIndex);
				var i:int;
				var len:int = team.troops.length;
				
				var arr:Array = [];
				for (i = 0; i < len; i++) 
				{
					var tempTroop:TroopLogic = team.troops[i];
					if (tempTroop.uid == troop.uid && cfg[tempTroop.hid]){
						//如果该英雄已经创造激励，则只取最优激励，仅PVE可能出现
						var jLen:int = arr.length;
						var merge:Boolean = false;
						for (var j:int = 0; j < jLen; j++) 
						{
							if (arr[j][0] == tempTroop.hid){
								//只取最优激励
								merge = true;
								arr[j][1] = Math.max(arr[j][1], tempTroop.heroLogic.hero_star);
							}
						}
						if(!merge)
							arr.push([tempTroop.hid, tempTroop.heroLogic.hero_star]);
					}
				}
				if (arr.length > 0){
					troop.others.spirit = arr;
				}
			}
		}
		
		
		/**
		 * 得到国家最高官职，为了获取光环效果，只按id较小评估即可
		 */
		protected function getCountryOfficial(country:int):int
		{
			var officialBest:int = -100;
			var official:int;
			var user_log:Object;
			for (var uid:String in this.user_logs)
			{
				user_log = this.user_logs[uid];
				if (user_log.country == country)
				{
					official = user_log.official;
					if (official >= 0)
					{
						if (officialBest < 0 || official < officialBest)
						{
							officialBest = official;
						}
					}
				}
			}
			return officialBest;
		}
		
		/**
		 * 客户端新建一场战斗，通过这种方式建立时，包括others：  attends,official(这里是国战最高官职光环效果)tower(国战箭楼1，炮塔2)
		 */
		public function newFight():FightLogic
		{
			var fight:FightLogic = new FightLogic(this.getNextFightInitJS());
			return fight;
		}
		
		/**
		 * 获取当前队伍的下一个出战部队(排头)
		 */
		public function getNextFightTroop(teamIndex:int):TroopLogic
		{
			var team:TeamLogic = this.teams[teamIndex];
			var troopLogic:TroopLogic;
			if (this.fightLogic){
				if (this.isWheel || this.isSolo)
				{
					if(this.fightLogic.winner == teamIndex){
						troopLogic = this.fightLogic.getTroopFighting(this.fightLogic.winner).troopLogic;
						if ((troopLogic.isNpc && troopLogic.proud<ConfigServer.world.npcBackProud) || team.troops.length==0)
						{
							//NPC胜利傲气低于5，或玩家胜利后续没有排队，才可继续作战
							return troopLogic;
						}
					}
				}
			}
			if (team.troops.length > 0){
				troopLogic = team.troops[0];
				return troopLogic;
			}
			return null;
		}
		
		/**
		 * 获取当前情况刷出下一场战斗的数据InitJS
		 */
		public function getNextFightInitJS():Object
		{
			var initJS:Object;
			var troop0:TroopLogic = this.getNextFightTroop(0);
			if (!troop0)
				return null;
			var troop1:TroopLogic = this.getNextFightTroop(1);
			if (!troop1)
				return null;

			this.packFightTroop(troop0);
			this.packFightTroop(troop1);
			
			initJS = {
				mode:this.mode,
				rnd:this.seedCurr,
				fight_count:this.fightCount,
				troop:[troop0.getCompData(),troop1.getCompData()]
			};
			if (this.city){
				initJS.cid = parseInt(this.city);
			}
			if (this.battle_special){
				initJS.battle_special = this.battle_special;
			}
			if (this.timeScale != 1){
				initJS.timeScale = this.timeScale;
				if (this.timeScale > ConfigFight.maxPoint){
					initJS.speedUp = 1;
				}
			}
			if (this.speedUp > 0){
				initJS.speedUp = this.speedUp;
			}
			
			return initJS;
		}
		
		/**
		 * 追加部队，读取相关素材后显示   如果有偷跑的战斗，插入N-1
		 */
		public function addTroop(troopData:Object, teamIndex:int, troopIndex:int = -1, forgeFight:Boolean = false):TroopLogic
		{
			var team:TeamLogic = this.getTeam(teamIndex);
			if (troopIndex == -1)
			{
				if (troopData.uid > 0)
				{
					//玩家
					troopIndex = team.getTroopInsertIndex(forgeFight);
				}
				else
				{
					//Npc
					troopIndex = team.troops.length;
				}
			}
			var troopLogic:TroopLogic = team.newTroop(troopData, troopIndex);
			team.addTroop(troopLogic);
			return troopLogic;
		}
		
		/**
		 * 过关斩将，敌方失败则补充一波，仅服务端或纯逻辑执行
		 */
		public function addClimbTroop():void
		{
			if (this.fightLogic && this.fightLogic.winner == 0)
			{
				var obj:Object = this.addClimbTroopData();
				if(obj){
					this.addTroop(obj, 1);
				}
			}
		}
		/**
		 * 生成过关斩将的新一波敌人部队数据
		 */
		public function addClimbTroopData(zone:String = ""):Object
		{
			if (this.climb)
			{
				var waveNum:int = this.getWaveTotal(true);
				if (waveNum >= this.climbCfg.configure.maxwave){
					//超出最大波数
					return null;
				}
				var random:FightRandom = new FightRandom((this.seedBase * (waveNum + FightRandom.NUM_3) + FightRandom.NUM_2) % FightRandom.NUM_1);
				var reObj:Object = FightClimbUtils.getRandomTroop(this.climb.worldLv, waveNum, this.climb.armyType0, this.climb.armyType1, random, this.climbCfg);
				this.data.team[1].troop.push(reObj);
				//trace('当前波数:' + waveNum + '，随机英雄：'+ reObj.hid);
				return reObj;
			}
			return null;
		}
		
		/**
		 * 移除一个排队中部队
		 */
		public function removeTroop(troopLogic:TroopLogic):Boolean
		{
			var troopIndex:int = troopLogic.troopIndex;
			if (troopIndex >= 0)
			{
				var team:TeamLogic = this.getTeam(troopLogic.teamIndex);
				if (team.troops.length > troopIndex && team.troops[troopIndex] == troopLogic)
				{
					team.troops.splice(troopIndex, 1);
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 部队回到队首继续作战
		 */
		public function troopStick(troopLogic:TroopLogic):void
		{
			var team:TeamLogic = this.getTeam(troopLogic.teamIndex);
			troopLogic.troopIndex = 0;
			team.addTroop(troopLogic);
		}
		
		/**
		 * 玩家胜利后插入参数N。插入到max(连续玩家尾,min(队尾，N))
		 */
		public function troopBack(troopLogic:TroopLogic):void
		{
			var team:TeamLogic = this.getTeam(troopLogic.teamIndex);
			troopLogic.troopIndex = team.getTroopInsertIndex();
			team.addTroop(troopLogic);
		}
		/**
		 * NPC胜利后傲气过高，排到队尾
		 */
		public function troopBackEnd(troopLogic:TroopLogic):void
		{
			var team:TeamLogic = this.getTeam(troopLogic.teamIndex);
			troopLogic.troopIndex = team.troops.length;
			team.addTroop(troopLogic);
		}
		
		
		/**
		 * 得到指定国家部队应进入的队伍
		 */
		public function getTeamIndexByCountry(country:int):int
		{
			if (country == this.country)
			{
				return 1;
			}
			return 0;
		}
		
		public function setDataComplete():void
		{
			this.startFight();
		}
		
		override public function setData(data:*):void
		{
			super.setData(data);
			this.setDataNext(data);
		}
		public function setDataNext(data:*):void
		{
			if (this.isClimbPVE){
				//取得对应服务器的过关斩将配置，服务器JS用，勿删
				if(this.zone && ConfigServer.zone[this.zone] && ConfigServer.zone[this.zone][8]){
					this.climbCfg = ConfigServer.config["climb_new"];
				}
				else{
					this.climbCfg = ConfigServer.config["climb"];
				}
			}
			this.seedBase = data.hasOwnProperty('rnd') ? data.rnd : 0;
			this.seedCurr = data.hasOwnProperty('seedCurr') ? data.seedCurr : this.seedBase;
			//var seed:int = data.hasOwnProperty('rnd') ? data.rnd : 0;
			//var seedBase:int = data.hasOwnProperty('rndBase') ? data.rndBase : -1;
			//var seedNum:int = data.hasOwnProperty('rndNum') ? data.rndNum : -1;
			
			//this.random = new FightRandom(seed,seedBase,seedNum);
			if(!this.fightRecords)
				this.fightRecords = [];
			this.teams = [];
			var i:int;
			var len:int;
			var teamData:Array = data.team;
			if (this.isClimbPVE)
			{
				//过关斩将
				if (teamData[1].troop.length == 0)
				{
					//补上默认个数的敌军
					for (i = 0, len = ConfigFight.troopInsertIndex; i < len; i++)
					{
						this.addClimbTroopData();
					}
				}
			}
			else if (this.isCountry)
			{
				//国战
				if (!this.teamBest)
					this.teamBest = [{}, {}];
				if (!this.country_logs)
					this.country_logs = {};
			}
			if (!this.user_logs)
				this.user_logs = {};
				
			if (!this.timeScale)
				this.timeScale = 1;
			
			for (i = 0, len = teamData.length; i < len; i++)
			{
				this.teams[i] = this.newTeam(teamData[i], i);
			}
			
			this.setDataComplete();
		}
		/**
		 * 返回当前数据副本(用于客户端中途加入战斗时，恢复到从某一场开始)
		 */
		public function getCurrData():*
		{
			var reData:Object = {};
			reData.mode = this.mode;
			if (this.isCountry)
			{
				reData.title = this.title;
				reData.city = this.city;
				reData.country = this.country;
				reData.fireCountry = this.fireCountry;
				reData.readyTime = this.readyTime;
			}
			else if (this.isWavePVE)
			{
				reData.reward = this.reward;
				reData.lastKillWave = this.getWaveKill(true);
				if (this.isClimbPVE)
				{
					reData.climb = this.climb;
				}
			}
			//reData.fight_count = this.fightCount;
			reData.record = this.record;
			reData.fightRecords = this.fightRecords;

			
			reData.user_logs = this.user_logs;
			reData.rnd = this.seedBase;
			reData.seedCurr = this.seedCurr;
			//reData.rndBase = this.random.seedBase;
			//reData.rndNum = this.random.seedNum;
			
			reData.team = [this.getTeam(0).getCurrData(), this.getTeam(1).getCurrData()];
			return reData;
		}
		
		/**
		 * 获取所有战斗的战报(只能最后调用)
		 */
		public function getRecord():Object
		{
			if (this._record){
				return this._record;
			}
			var obj:Object = {};
			var recordObj:Object;
			var troopObj0:Object;
			var troopObj1:Object;
			var i:int;
			var len:int;
			var j:int;
			var troopObj:Object;
			var troop:TroopLogic;
			//根据类型判别胜负，-1为平局
			if (this.isWheel)
			{
				//最后剩余人数的队伍胜
				if (this.getTeamLength(1) > 0)
				{
					obj.winner = 1;
				}
				else
				{
					obj.winner = 0;
				}
				
				if (this.isWavePVE)
				{
					//记录击杀波数
					//trace("记录击杀波数", this.data.team[1].troop.length, this.getTeamLength(1));
					obj.killWave = this.getWaveKill();
				}
				
			}
			else if (this.isMatch)
			{
				//胜出场次多的队伍胜(剩余有人数直接算胜)
				var teamWin:Array = [0, 0];
				var teamLen:Array = [0, 0];
				var unames:Array = ['', ''];

				//补足未开始的战斗战报
				for (i = 0; i < 2; i++)
				{
					var team:TeamLogic = this.getTeam(i);
					//teamWin[i] += team.troops.length;
					teamLen[i] = team.troops.length;
					unames[i] = team.uname;
				}
				len = Math.max(teamLen[0], teamLen[1]);
				for (i = 0; i < len; i++)
				{
					var troop0:TroopLogic = this.getTeam(0).troops[i];
					var troop1:TroopLogic = this.getTeam(1).troops[i];
					troopObj0 = troop0 ? troop0.getRecord() : null;
					troopObj1 = troop1 ? troop1.getRecord() : null;
					
					var fightRecord:Object = {};
					
					fightRecord.troop = [troopObj0, troopObj1];
					if (troopObj0 == null)
					{
						fightRecord.winner = 1;
					}
					else if (troopObj1 == null)
					{
						fightRecord.winner = 0;
					}
					else
					{
						fightRecord.winner = -1;
					}
					this.fightRecords.push(fightRecord);
				}
				//补足完毕
				
				//包装双方的总血量
				var hpAll:Array = [0, 0];
				var hpmAll:Array = [0, 0];
				
				len = this.fightRecords.length;
				for (i = 0; i < len; i++)
				{
					recordObj = this.fightRecords[i];
					if (recordObj.winner != -1)
					{
						teamWin[recordObj.winner]++;
					}
					for (j = 0; j < 2; j++)
					{
						troopObj = recordObj.troop[j];
						if (troopObj)
						{
							hpAll[j] += troopObj.hp;
							hpmAll[j] += troopObj.hpm;
						}
					}
				}
				
				if (teamWin[0] > teamWin[1])
				{
					obj.winner = 0;
				}
				else if (teamWin[0] < teamWin[1])
				{
					obj.winner = 1;
				}
				else
				{
					obj.winner = -1;
				}
				obj.teamWin = teamWin;
				obj.teamHpPer = [hpAll[0] / hpmAll[0], hpAll[1] / hpmAll[1]];
				obj.unames = unames;
			}
			else if (this.isSolo)
			{
				obj.winner = this.fightRecords[0].winner;
			}
			
			if (!this.isMatch || this.isKillHp)
			{
				var time:int = 0;
				var userKill:int = 0;
				var userDead:int = 0;
				var userTroop:Object = {};
				
				len = this.fightRecords.length;
				
				for (i = this.fightRecords.length - 1; i >= 0; i--)
				{
					recordObj = this.fightRecords[i];
					if (this.isDurationPVE)
					{
						time += recordObj.time;
					}
					troopObj0 = recordObj.troop[0];
					if (troopObj0)
					{
						if (this.isKillHp)
						{
							userDead += troopObj0.dead;
							troopObj1 = recordObj.troop[1];
							if (troopObj1)
								userKill += troopObj1.dead;
						}
						if (this.isWorldPVE)
						{
							//PVE世界部队，结算时要有损失数据（不支持比赛型）
							var hid:String = troopObj0.hid;
							if (!userTroop[hid])
							{
								troop = this.findTroop(0, hid);
								if (troop)
								{
									userTroop[hid] = [troop.getArmy(0).hp, troop.getArmy(1).hp];
								}
								else
								{
									userTroop[hid] = [0, 0];
								}
							}
						}
					}
				}
				if (this.isDurationPVE)
				{
					obj.time = time;
				}
				if (this.isKillHp)
				{
					obj.userKill = userKill;
					obj.userDead = userDead;
				}
				if (this.isWorldPVE)
				{
					obj.userTroop = userTroop;
				}
				
				
				//擂台战，需要处理攻擂者奖励，以及新擂主最终状态
				if (this.isArena)
				{
					var arenaKillPer:Number;
					if (this.arenaHpm <= 0){
						arenaKillPer = 1;
					}
					else if (obj.winner == 0){
						arenaKillPer = 1;
					}
					else{
						arenaKillPer = Math.max(0,Math.min(1,userKill/this.arenaHpm));
					}
					obj.arenaReward = FightUtils.getRankValue(arenaKillPer, ConfigFight.arenaReward,'v');
					
					var troopArr:Array;
					if (obj.winner == 0){
						//攻擂者胜出，清除所有疲劳和兵损，成为擂主
						troopArr = FightUtils.clone(this.data.team[0].troop);
						len = troopArr.length;
						//obj.winnerTroops = this.data.team[0].troop;
					}
					else{
						//守擂者胜出，清除所有疲劳，所有单个部队中前后军少于10%兵力的补充到10%兵力
						troopArr = FightUtils.clone(this.data.team[1].troop);
						len = troopArr.length;
						for (i = 0; i < len; i++ ){
							troopObj = troopArr[i];
							//trace(troopObj.hid+'剩余兵力：' + ModelPrepare.getHpAndHpm(troopObj));
							if (!troopObj.power){
								troopObj = new ModelPrepare(troopObj,true).data;
							}
							
							var armyHp:Array = [0, 0];
							troop = this.findTroop(1, troopObj.hid);
							if (troop)
							{
								armyHp = [troop.getArmy(0).hp, troop.getArmy(1).hp];
							}

							var armyArr:Array = troopObj.army;
							for (j = 0; j < 2; j++ ){
								var armyObj:Object = armyArr[j];
								if (armyHp[j] / armyObj.hpm < ConfigFight.arenaWinnerHpPer){
									armyHp[j] = Math.ceil(armyObj.hpm * ConfigFight.arenaWinnerHpPer);
								}
							}
							troopArr[i].armyHp = armyHp;
						}
					}
					//清除擂主临时包装的内部bless uid uname
					for (i = 0; i < len; i++ ){
						troopObj = troopArr[i];
						delete troopObj.bless;
						delete troopObj.uid;
						delete troopObj.uname;
					}
					obj.winnerTroops = troopArr;
				}
			}
			//if (this.isDuration){
			////PVE持续时间，记录每波时间，能够中途恢复，到达最终时间才能结算
			//}
			
			obj.records = this.fightRecords;
			if (ConfigApp.hasDocument){
				obj.isClient = 1;
			}
			
			this._record = obj;
			return obj;
		}
		
		override public function clear():void
		{
			super.clear();
			this.teams[0].clear();
			this.teams[1].clear();
			this.teams = null;
			this.fightRecords = null;
			this.user_logs = null;
			
			//this.random = null;
			if (this.fightLogic != null)
			{
				this.fightLogic.clear();
			}
			this.fightLogic = null;
			
			if (this.lastFightLogic != null)
			{
				this.lastFightLogic.clear();
			}
			this.lastFightLogic = null;
		
			this.zone = null;
			this.climbCfg = null;
		}
	}

}