package sg.fight.logic
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigApp;
	import sg.cfg.ConfigServer;
	import sg.fight.logic.action.ActionBase;
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.ArmyFighting;
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightRandom;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	import sg.model.ModelBeast;
	import sg.model.ModelPrepare;
	import sg.utils.Tools;
	
	/**
	 * 战斗，每个战场最多只有一个正在执行的战斗
	 * @author zhuda
	 */
	public class FightLogic extends LogicModeBase
	{
		public static var _testInitTime:Number = 0;
		public static var _testFightTime:Number = 0;
		
		///当前回合数
		public var round:int;
		public var winner:int;
		public var fightCount:int;
		public var speedUp:int;
		public var timeScale:Number;
		///战斗中的随机数生成器
		public var random:FightRandom;
		
		public function get loser():int
		{
			if (this.winner >= 0)
			{
				return 1 - this.winner;
			}
			return -1;
		}
		public function get initJS():Object
		{
			return this.data;
		}
		
		///正在作战的双方  0为进攻方 1为防守方 内部为TroopFighting
		public var troops:Array;
		
		///当前正在行动的单位
		protected var currUnitFighting:UnitFighting;
		///当前准备执行的行动
		protected var actions:Array;
		///当前已生成的回放数据
		public var playbacks:Array;
		///已经导出的战报
		protected var _record:Object;
		///初始化战斗种子
		//public var initSeed:int;
		///本战的先手
		public var priorityIndex:int = -1;
		
		///战役对双方的加减成效果
		public var battle_special:Object;
		
		///玩家间对抗，或者锁定对抗模式。此属性决定是否使用弱势补助、伤害幕府衰减
		public var isPVP:Boolean;
		///已经调用过逻辑结算
		public var isEndFight:Boolean;
		
		/**
		 * 是否是客户端版
		 */
		public function get isClient():Boolean
		{
			return false;
		}
		
		/**
		 * 得到正在作战的部队，0左1右
		 */
		public function getTroopFighting(teamIndex:int):TroopFighting
		{
			return this.troops[teamIndex];
		}
		
		/**
		 * 得到正在作战的部队，0左1右
		 */
		public function getTroop(teamIndex:int):TroopLogic
		{
			return this.getTroopFighting(teamIndex).troopLogic as TroopLogic;
		}
		
		public function FightLogic(data:Object)
		{
			//TestPrint.instance.timeStart('初始化fight');
			super(data);

			this.mode = data.mode;
			this.battle_special = data.battle_special;
			this.random = new FightRandom(data.rnd);
			//this.initSeed = this.random.seed;
			this.fightCount = data.fight_count;
			this.timeScale = data.timeScale?data.timeScale:1;
			if (this.timeScale > ConfigFight.maxPoint){
				this.speedUp = 1;
			}
			else{
				this.speedUp = data.speedUp?data.speedUp:0;
			}
			
			//this.setData(data);
			
			if (ConfigApp.testTimeRate)
			{
				var startTime:int = new Date().getTime();
			}
			
			var troopLogicArr:Array = this.initTroopLogicArr();
			this.initTroopFightings(troopLogicArr[0], troopLogicArr[1]);
			
			var troopFighting0:TroopFighting = this.troops[0];
			var troopFighting1:TroopFighting = this.troops[1];

			//双方初始化完毕，检查兽灵附加的特性和技能加成
			this.checkBeast();
			//双方初始化完毕，检查修正特性，战前最终合并（limit判定不过，技能不入战斗），战斗开始后再无special（special可能附加出act）
			this.checkSpecial();
			this.checkPKAid();
			
			//判定并设定英雄先后手
			this.priorityIndex = troopFighting0.troopLogic.getPriority() > troopFighting1.troopLogic.getPriority()?0:1;
			troopFighting0.setPriority(this.priorityIndex == 0);
			troopFighting1.setPriority(this.priorityIndex == 1);

			
			//双方最终合并action（含普攻），战斗初始化完毕  （遍历所有skill数据，将其分配到对应的unit action中，最终遍历unit各类action 优先级排序）
			troopFighting0.checkUnitAction();
			troopFighting1.checkUnitAction();
			//测试打印
			if(!data.statist){
				this.testPrint(troopFighting0, 0);
				this.testPrint(troopFighting1, 1);
			}

			
			
			this.currUnitFighting = null;
			this.actions = [];
			this.playbacks = [];
			this.round = -1;
			this.winner = -1;
			
			//TestPrint.instance.timeEnd('初始化fight');
			//进入战斗瞬间，再排查是否有收到羁绊、国家职位光环影响，存入fight对象
			//客户端要加载资源，不能直接开始
			//this.start();
			
			if (ConfigApp.testTimeRate)
			{
				FightLogic._testInitTime += (new Date().getTime() - startTime);
			}
		}
		
		public function initTroopLogicArr():Array
		{
			var troop0:TroopLogic = new TroopLogic(this.data.troop[0], 0, 0);
			var troop1:TroopLogic = new TroopLogic(this.data.troop[1], 1, 0);
			return [troop0, troop1];
		}
		
		public function initTroopFightings(troop0:TroopLogic,troop1:TroopLogic):void
		{
			this.isPVP = !troop0.isNpc && !troop1.isNpc;
			
			var troopFighting0:TroopFighting = this.newTroopFighting(troop0);
			var troopFighting1:TroopFighting = this.newTroopFighting(troop1);
			this.troops = [troopFighting0, troopFighting1];
		}
		
		/**
		 * 双方初始化完毕后，检查兽灵附加的特性和技能加成，其内部不需要优先级
		 */
		public function checkBeast():void
		{
			var troopFighting:TroopFighting;
			var troopLogic:TroopLogic;
			var beastSuperObject:Object;
			var beastObj:Object;
			var specialObj:Object;
			var key:String;
			var path:String;
			var i:int;
			var j:int;
			var len:int;
			for (i = 0; i < 2; i++)
			{
				troopFighting = this.troops[i];
				troopLogic = troopFighting.troopLogic;
				if(troopLogic.beast){
					beastSuperObject = ModelBeast.getAllSuperObject(troopLogic.beast);
					beastObj = {};
					for (key in beastSuperObject){
						FightUtils.mergeObj(beastObj, ModelBeast.getSuperBeastObj(key, beastSuperObject[key]));
					}
					if (beastObj.beast){
						troopFighting.beastObj = beastObj.beast;
					}
					if (beastObj.skill){
						for (path in beastObj.skill)
						{
							FightUtils.changeObjByPath(troopFighting.skills, path, beastObj.skill[path]);
						}
					}
				}
			}
		}
		
		/**
		 * 双方初始化完毕后，统一按优先级处理Special，检查修正特性，战前最终合并，战斗开始后再无special（special可能附加出act）
		 */
		public function checkSpecial():void
		{
			var troopFighting:TroopFighting;
			var specialArr:Array;
			var specialObj:Object;
			var specialAllArr:Array = [];
			var i:int;
			var j:int;
			var len:int;
			for (i = 0; i < 2; i++)
			{
				troopFighting = this.troops[i];
				specialArr = troopFighting.troopLogic.special;
				if (specialArr && specialArr.length > 0)
				{
					len = specialArr.length;
					for (j = 0; j < len; j++)
					{
						specialObj = FightUtils.clone(specialArr[j]);
						if (!specialObj.hasOwnProperty('priority'))
						{
							specialObj.priority = 0;
						}
						//守方的Special优先半格判定，防止随机数乱序
						if (i > 0){
							specialObj.priority += 0.5;
						}
						specialObj.index = i;
						specialAllArr.push(specialObj);
					}
				}
			}
			len = specialAllArr.length;
			if (len > 1){
				//增加检查重复优先级
				if (TestFightData.testFightPrint){
					var sameObj:Object = FightUtils.checkSameValue(specialAllArr, 'priority');
					if (sameObj)
					{
						FightPrint.print('战斗加入special优先级重复:', sameObj, '#9900FF');
						//trace('战斗加入special优先级重复:',sameObj);
					}
				}
				
				FightUtils.sortPriority(specialAllArr);
			}	
			for (i = 0; i < len; i++)
			{
				specialObj = specialAllArr[i];
				troopFighting = this.troops[specialObj.index];
				troopFighting.checkSpecialOne(specialObj);
			}
		}
		

		
		/**
		 * 双方Special初始化完毕后，如果是玩家间PK，对弱势方补助
		 */
		public function checkPKAid():void
		{
			if (ConfigFight.pkAid){
				var troopFighting:TroopFighting;
				var troopFighting0:TroopFighting = this.troops[0];
				var troopFighting1:TroopFighting = this.troops[1];
				if (this.isPVP){
					var power:int = troopFighting0.troopLogic.power - troopFighting1.troopLogic.power;
					if (power > 0){
						troopFighting = troopFighting1;
					}
					else if (power < 0){
						troopFighting = troopFighting0;
						power = -power;
					}
					else{
						return;
					}
					
					var rankArr:Array = FightUtils.getRankArr(power, ConfigFight.pkAid);
					var i:int;
					for (i = 0; i < 2; i++)
					{
						var armyLogic:ArmyLogic = troopFighting.getArmyFighting(i).getArmyLogic();
						ModelPrepare.transformToArmyFloor(armyLogic, rankArr[1], power - rankArr[0]);
					}
				}
			}
		}

		
		/**
		 * 战斗逻辑开始，并结束
		 */
		public function start():void
		{
			if (canPrint)
				print('\n\n开始战斗');
			//trace('开始战斗');
			//TestPrint.instance.timeStart('fight');
			
			this.addPlayback({key: 'start', time: ConfigFight.fightStartTime});
			
			//激励加成
			this.checkSpirit();
			//幕府加成
			this.checkShogun();
			
			if (ConfigApp.testTimeRate)
			{
				var startTime:int = new Date().getTime();
			}
			
			this.nextRound();
			
			if (ConfigApp.testTimeRate)
			{
				FightLogic._testFightTime += (new Date().getTime() - startTime);
			}
			this.end();
			//TestPrint.instance.timeEnd('fight');
		}
		
		/**
		 * 战斗逻辑结束
		 */
		public function end():void
		{
			//this.getTroopFighting(0).clear();
			//this.getTroopFighting(1).clear();
		}
		
		/**
		 * 激励加成
		 */
		private function checkSpirit():void
		{
			var b:Boolean = false;
			var arr:Array = [null,null];
			for (var i:int = 0; i < 2; i++)
			{
				var troop:TroopLogic = this.getTroop(i);
				var spiritData:* = troop.getSpiritData();
				
				if (spiritData){
					var spiritArr:Array = troop.others.spirit;
					if (spiritArr.length > 0)
					{
						b = true;
						arr[i] = {arr:spiritArr, data:spiritData};
					}
				}
			}
			if (b)
			{
				this.addPlayback({key: 'spirit', time: ConfigFight.fightSpiritTime, value: arr});
			}
		}
		
		/**
		 * 幕府加成
		 */
		private function checkShogun():void
		{
			var b:Boolean = false;
			var arr:Array = [];
			var battleSpecialRate:Number = 1;
			if (this.battle_special && this.battle_special.shogunPoint){
				//战役对双方的幕府加减成效果
				battleSpecialRate *= FightUtils.pointToRate(this.battle_special.shogunPoint);
			}
			
			for (var i:int = 0; i < 2; i++)
			{
				var troop:TroopLogic = this.getTroop(i);
				//var troopFighting:TroopFighting = this.getTroopFighting(i);
				var shogunArr:Array = FightUtils.clone(troop.shogun);
				arr.push(shogunArr);
				if (shogunArr)
				{
					shogunArr[0] *= battleSpecialRate;
					shogunArr[1] *= battleSpecialRate;
					shogunArr[2] *= battleSpecialRate;
					if (shogunArr[0])
					{
						b = true;
					}
					if (shogunArr[1])
					{
						b = true;
					}
					if (shogunArr[2])
					{
						b = true;
					}
				}
			}
			if (b)
			{
				this.addPlayback({key: 'shogun', time: ConfigFight.fightShogunTime, value: arr});
			}
		}
		
		/**
		 * 箭楼石炮攻击
		 */
		private function checkTower():void
		{
			var troop1:TroopLogic = this.getTroop(1);
			if (troop1.others && troop1.others.tower)
			{
				var troop0:TroopLogic = this.getTroop(0);
				var towerArr:Array = troop1.others.tower;
				var fire:Boolean = false;
				var skillCfg:Object = ConfigServer.skill;
				var troopFighting1:TroopFighting = this.getTroopFighting(1);
				var attackAction:AttackAction;
				var actData:Object;
				var towerLv:int;
				
				towerLv = towerArr[1];
				if (towerLv > 0)
				{
					//拥有石炮
					actData = ConfigFight.towerAct1;
					var cd:int = actData.cd;
					if (this.fightCount % cd == (cd-1)){
						actData = FightUtils.clone(actData);
						//升级并修改描述
						actData.lv = Math.floor(towerLv * 2 + 5);
						actData.dmgRealRate += actData.up * (towerLv-1);
						actData.info[0] = actData.info[0] + ' ' + Tools.getMsgById('fight_lv', [towerLv]);
						
						attackAction = new AttackAction(troopFighting1.heroFighting, actData);
						attackAction.doAction();
					}
				}
				towerLv = towerArr[0];
				if (!fire && towerLv > 0)
				{
					//拥有箭楼，暂时可以双发
					actData = ConfigFight.towerAct0;
					var proudArr:Array = actData.proudArr;
					var point:int = Math.min(proudArr[2], proudArr[0] * (troop0.proud - proudArr[1]));
					if(this.random.determine(point)){
						actData = FightUtils.clone(actData);
						//升级并修改描述
						actData.lv = Math.floor(towerLv*1.1);
						actData.dmgRealRate += actData.up * (towerLv-1);
						actData.info[0] = actData.info[0] + ' ' + Tools.getMsgById('fight_lv', [towerLv]);
						
						attackAction = new AttackAction(troopFighting1.heroFighting, actData);
						attackAction.doAction();
					}
				}
			}
		
			//this.nextRound();
		}
		
		/**
		 * 下一回合
		 */
		private function nextRound():void
		{
			this.round++;
			if (this.round == 4 && this.isShortFight)
			{
				//如果战斗超过4回合，强制结束，算攻方负
				this.winner = 1;
				if (canPrint)
					print('★ 攻方4回合内未能攻破防守 ' + this.winner);
				return;
			}
			var r:int = this.round;
			//TestPrint.instance.timeStart('round' + r);
			this.addPlayback({key: 'round', time: ConfigFight.fightRoundTime, value: this.round});
			if (canPrint)
				print('   ------------------------- 回合 ' + this.round + ' -------------------------');
			
			if (this.round == 0 && this.isCountry)
			{
				//国战，塔攻击
				this.checkTower();
			}
			var i:int;
			var j:int;
			var len:int;
			var troopFighting:TroopFighting;
			var unitFighting:UnitFighting;
			for (i = 0; i < 2; i++)
			{
				troopFighting = this.troops[i];
				for (j = 0, len = troopFighting.units.length; j < len; j++)
				{
					unitFighting = troopFighting.units[j];
					if(unitFighting)
						unitFighting.resetRound();
				}
			}
			
			//FightUtils.traceStr('新的回合 ' + this.round);
			this.nextCheck();
		
			//TestPrint.instance.timeEnd('round' + r);
		}
		
		/**
		 * 判定战斗是否结束，如果没有，自动执行下一步
		 */
		public function nextCheck():void
		{
			//FightUtils.traceStr('nextCheck');
			//return true;
			//某个部队完全阵亡，判定胜负
			if (this.checkEnd())
			{
				return;
			}
			this.nextAction();
		}
		
		/**
		 * 连续执行完所有行动，不再考虑更多
		 */
		private function doEndActions():void
		{
			var loserTroopFighting:TroopFighting = this.troops[this.loser];
			var winnerTroopFighting:TroopFighting = this.troops[this.winner];
			this.addActions(loserTroopFighting.getLossActions(winnerTroopFighting.troopLogic));
			
			this.addActions(loserTroopFighting.getEndActions(false));
			this.addActions(winnerTroopFighting.getEndActions(true));


			while(this.actions.length > 0)
			{
				var action:ActionBase = this.actions.shift();
				action.doAction();
			}
		}
		
		/**
		 * 执行下一个Action
		 */
		private function nextAction():void
		{
			//FightUtils.traceStr('nextAction');
			if (this.actions.length > 0)
			{
				var action:ActionBase = this.actions.shift();
				//FightUtils.traceStr('执行nextAction');
				//如果对方有无懈，在此内部使用
				action.doAction();
				if (action.isEnd){
					//混乱或内讧，下一步直接执行行动后结算状态
					if(this.currUnitFighting){
						this.currUnitFighting.activeStep = ConfigFight.ACT_ACTIVE_ARRAY.length - 1;
					}
					//this.currUnitFighting = null;
				}
				//如果是大回合重置阶段的最后一个动作，加入短暂等待
				if (action.data.type == ConfigFight.ACT_ROUND){
					if (this.actions.length == 0){
						this.addPlayback({key: 'wait', time: ConfigFight.fightResetRoundTime});
					}
					this.nextAction();
				}
				else{
					this.nextCheck();
				}
			}
			else
			{
				this.findAction();
			}
		}
		
		/**
		 * 查找下一个有效Action
		 */
		private function findAction():void
		{
			//FightUtils.traceStr('findAction');
			if (this.currUnitFighting != null)
			{
				var action:ActionBase = this.currUnitFighting.nextAction();
				if (action == null)
				{
					this.currUnitFighting = null;
					this.nextUnit();
				}
				else
				{
					this.addAction(action);
					this.nextAction();
				}
			}
			else
			{
				//查找下一个单位，不行的话下一回合
				this.nextUnit();
			}
		}
		
		/**
		 * 得到本回合尚未行动的单位中最快的那个，设为当前行动者
		 */
		private function nextUnit():void
		{
			//FightUtils.traceStr('nextUnit');
			var units:Array = [];
			var i:int;
			var j:int;
			var len:int;
			var troopFighting:TroopFighting;
			var unitFighting:UnitFighting;
			this.currUnitFighting = null;
			for (i = 0; i < 2; i++)
			{
				troopFighting = this.troops[i];
				for (j = 0, len = troopFighting.units.length; j < len; j++)
				{
					unitFighting = troopFighting.units[j];
					if (unitFighting && unitFighting.active)
						units.push(unitFighting);
				}
			}
			if (units.length > 0)
			{
				units.sort(MathUtil.sortByKey('speed', true));
				this.currUnitFighting = units[0];
				this.currUnitFighting.startRound();
				this.findAction();
			}
			else
			{
				this.nextRound();
			}
		}
		
		/**
		 * 加入一个Action
		 */
		public function addAction(action:ActionBase):void
		{
			this.actions.push(action);
		}
		/**
		 * 加入Actions
		 */
		public function addActions(arr:Array):void
		{
			if (!arr)
				return;
			var i:int;
			var len:int = arr.length;
			for (i = 0; i < len; i++) 
			{
				this.actions.push(arr[i]);
			}
		}
		
		/**
		 * 加入一条回放数据Playback
		 */
		public function addPlayback(data:Object):void
		{
			this.playbacks.push(data);
		}
		
		//public function insertAction():void{
		//this.actions.unshift(1);
		//}
		//public function addAction():void{
		//this.actions.push(1);
		//}
		
		/**
		 * 某个部队完全阵亡，判定胜负
		 */
		public function checkEnd():Boolean
		{
			var isEnd:Boolean = false;
			var troopFighting:TroopFighting;
			for (var i:int = 0; i < 2; i++)
			{
				troopFighting = this.troops[i];
				if (!troopFighting.alive)
				{
					this.winner = 1 - i;
					if (canPrint)
						print('★ 胜方是 ' + this.winner);
					
					isEnd = true;
					//return true;
				}
			}
			if (this.round >= ConfigFight.roundMax)
			{
				if (canPrint)
					print('★ 超过最大战斗回合数，双方怼光剩余兵力，仍生存者胜（相同时守方胜）');
				var troopFighting0:TroopFighting = this.troops[0];
				var troopFighting1:TroopFighting = this.troops[1];
				var hp0:int = troopFighting0.troopLogic.getAllHp();
				var hp1:int = troopFighting1.troopLogic.getAllHp();
				if (hp0 > hp1)
				{
					this.winner = 0;
					troopFighting0.troopLogic.cutHp(hp1);
					troopFighting1.troopLogic.cutHp(hp0, true);
				}
				else
				{
					this.winner = 1;
					troopFighting0.troopLogic.cutHp(hp1, true);
					troopFighting1.troopLogic.cutHp(hp0);
				}
				this.addPlayback({key: 'cut', time: ConfigFight.fightShogunTime});
				
				isEnd = true;
				//return true;
			}
			
			if (isEnd){
				//结束时，添加胜败双方的终结行动
				this.doEndActions();
			}
			return isEnd;
		}
		
		public function newTroopFighting(troop:TroopLogic):TroopFighting
		{
			return new TroopFighting(this, troop);
		}
		
		override public function setData(data:*):void
		{
			//if (!data && this.isTestTrace){
				//data = {};
				//data.fight_count = this.fightCount;
				//data.rnd = this.initSeed;
				//data.troop = [null, null];
				//for (var i:int = 0; i < 2; i++) 
				//{
					//var troop:TroopLogic = this.getTroop(i);
					//var troopData:Object = FightUtils.clone(troop.data);
					//delete troopData.uname;
					//troopData.proud = troop.proud;
					//troopData.army[0].hp = troop.getArmy(0).hp;
					//troopData.army[1].hp = troop.getArmy(1).hp;
					//data.troop[i] = troopData;
				//}
			//}
			this.data = data;
		}
		
		override public function getData():*
		{
			return null;
		}
		
		/**
		 * 获取战报，每次战斗只一次
		 */
		public function getRecord():Object
		{
			if (this._record){
				return this._record;
			}
			var obj:Object = {};
			var i:int;
			var troops:Array = [this.getTroop(0), this.getTroop(1)];
			obj.winner = this.winner;
			var troop:TroopLogic;
			
			obj.troop = [];
			for (i = 0; i < 2; i++)
			{
				troop = troops[i];
				obj.troop.push(troop.getRecord());
			}
			if (this.isWheel)
			{
				var time:Number = this.getRecordTime();
				if (time)
					obj.time = time;
				
				if (this.isCountry || TestFightData.testMode == -1)
				{
					//国战模式，才记录损血并返回随机数
					troop = troops[this.winner];
					obj.winnerHp = [troop.getArmy(0).hp, troop.getArmy(1).hp];
					obj.rnd = this.random.seed;
				}
			}
			if (this.isTestTrace){
				//强制测试模式下，打印所有初始化信息，以及过程战报
				obj.init = this.data;
				if (ConfigApp.hasDocument && !this.isClient){
					obj.init = FightUtils.clone(obj.init);
				}
				obj.playback = this.playbacks;
				obj.rnd = this.random.seed;
			}
			this._record = obj;
			return obj;
		}
		/**
		 * 获取战报时间（秒）
		 */
		public function getRecordTime():Number
		{
			if (this.isDurationPVE || this.isCountry)
			{
				if (this._record){
					return this._record.time;
				}
				
				var time:Number = 0;
				if (this.speedUp){
					//战鼓强制快速战斗
					return ConfigServer.world.countryFightSpeedUpSec;
				}
				
				for (var i:int = this.playbacks.length - 1; i >= 0; i--)
				{
					var temp:Object = this.playbacks[i];
					if(temp.time)
						time += temp.time;
				}
				//正在进行加速战斗
				time /= this.timeScale;
				
				if (ConfigApp.hasDocument && ConfigApp.testFightType){
					return time / 1000;
				}
				else
				{
					var timeRange:Array;
					if (this.isCountry)
					{
						time /= ConfigServer.world.countryFightTimeRate;
						timeRange = ConfigServer.world.countryFightTimeRange;
					}
					else{
						time /= ConfigServer.world.fieldFightTimeRate;
						timeRange = ConfigServer.world.fieldFightTimeRange;
					}
					return Math.max(Math.min(time / 1000, timeRange[1]), timeRange[0]);
				}
			}
			return 0;
		}

		
		/**
		 * 打印(纯客户端使用)
		 */
		public static function print(str:String, data:Object = null, color:String = null):void
		{
			FightPrint.print(str, data, color);
		}
		
		public static function get canPrint():Boolean
		{
			if(!ConfigApp.hasDocument)
				return false;
			return TestFightData.testFightPrint || FightPrint.check('FightLogic');
		}
		
		/**
		 * 测试显示初始化数据打印(纯客户端使用)
		 */
		public function testPrint(troopFighting:TroopFighting, index:int):void
		{
		
		}
		
		override public function clear():void
		{
			if (this.isCleared)
				return;
			super.clear();
			this.troops[0].clear();
			this.troops[1].clear();
			this.troops = null;
			
			this.random = null;
			
			this.currUnitFighting = null;
			
			this.actions = null;
			this.playbacks = null;
		}
	}

}