package sg.fight.logic.action
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.unit.AdjutantLogic;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.Tools;
	
	/**
	 * 所有单步行动的基类
	 * @author zhuda
	 */
	public class ActionBase
	{
		//type 0起始 1主 2攻前 3攻后 4防前 5防后 6状态 7对方英雄技 8战胜 9战败 10急救净化 11施加debuff 12对方触发型辅助技能 13大回合重置  -1每回合buffManager检查阶段
		
		///源数据
		public var data:Object;
		///源对象
		public var unitFighting:UnitFighting;
		
		/**
		 * 获取我方的部队
		 */
		public function getTroopFighting():TroopFighting
		{
			return this.unitFighting.troopFighting;
		}
		
		/**
		 * 获取敌对的部队
		 */
		public function getEnemyTroopFighting():TroopFighting
		{
			return this.unitFighting.getEnemyTroopFighting();
		}
		
		public function getFight():FightLogic
		{
			return this.unitFighting.getFight();
		}
		
		/**
		 * 将自身加入到战斗中
		 */
		public function addToFight():void
		{
			this.getFight().addAction(this);
		}
		/**
		 * 判断并额外加入的行动，如果是受击时响应有hitData
		 */
		public function addExtraAction(hitData:Object = null):void
		{
			//this.toExpend();
			this.addToFight();
		}
		
		///可释放回合的数据
		public var round:Object;
		///可释放条件的数组
		public var cond:Array;
		///必须跟随特定行动触发
		public var follow:String;
		
		///特效ID
		public var eff:String;
		///每回合最多使用次数，无此字段时默认为1
		public var times:int;
		///回合内额外发动1次的几率，无此字段时默认为0
		public var timesRnd:int;
		///每场对决最多使用次数，无此字段时默认为-1
		public var allTimes:int;
		
		//以下为特殊整理
		
		///当前回合剩余检查次数
		private var currTimes:int;
		
		
		
		/**
		 * 刷新本回合使用次数
		 */
		public function refresh(times:int):void
		{
			this.currTimes += times;
		}
		/**
		 * 是否活跃，主动行动每检测一次消耗一次，攻受前/攻受后行动每用一次消耗一次
		 */
		public function set active(value:Boolean):void
		{
			if (value)
			{
				if (this.allTimes < 0)
				{
					this.currTimes = this.times;
				}
				else if (this.allTimes == 0)
				{
					this.currTimes = 0;
				}
				else if (this.times < 0){
					this.currTimes = this.allTimes;
				}
				else
				{
					this.currTimes = Math.min(this.allTimes, this.times);
				}

				
				
				//如果触发了随机额外连发，则本回合突破allTimes限制
				if (this.currTimes>0 && this.timesRnd)
				{
					if (this.getFight().random.determine(this.timesRnd)){
						this.currTimes++;
					}
				}
			}
			else
			{
				this.currTimes = 0;
			}
		}
		
		public function get active():Boolean
		{
			return this.currTimes != 0;
		}
		
		
		
		public function get lv():int
		{
			return this.data.lv?this.data.lv:1;
		}
		/**
		 * 执行过后就结束该单位的行动
		 */
		public function get isEnd():Boolean
		{
			return this.data.end;
		}
		
		/**
		 * 扣除本回合的检测机会
		 */
		public function toExpendCurr():void
		{
			this.currTimes--;
		}
		/**
		 * 成功使用，消耗一次本场对决的使用次数，如果是受击时响应有hitData
		 */
		public function toExpendAll():void
		{
			if(this.allTimes>0)
				this.allTimes--;
		}
		
		public function ActionBase(unitFighting:UnitFighting, data:Object)
		{
			//this.id = id;
			this.unitFighting = unitFighting;
			this.setData(data);
			//FightUtils.traceStr('生成了ActionBase  '+id);
		}
		
		public function setData(data:*):void
		{
			this.data = data;
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				}
			}
			if (!this.times)
			{
				this.times = 1;
			}
			if (!this.allTimes)
			{
				this.allTimes = -1;
			}
		}
		
		/**
		 * 新回合重置
		 */
		public function resetRound():void
		{
			this.active = true;
		}
		
		/**
		 * 检查能否触发，如果可以直接消耗次数
		 * @param	srcAction 原行动（只有目标是绑定型行动才传入该参数）
		 * @param	ignoreBinding 是否忽略一般攻击性后续绑定行动（特定绑定不会被忽略）
		 * @return  返回是否可用
		 */
		public function checkCanUse(srcAction:AttackAction = null, ignoreFollow:Boolean = false):Boolean
		{
			if (!this.active)
			{
				return false;
			}
			//满足follow条件，才计入本回合消耗
			if(this.checkFollow(srcAction, ignoreFollow)){
				this.toExpendCurr();
				var canUse:Boolean = this.checkCanUseFun(srcAction);
				if (canUse){
					this.toExpendAll();
					return true;
				}
			}
			return false;
		}
		protected function checkCanUseFun(srcAction:AttackAction = null):Boolean
		{
			return this.checkRound(srcAction) && this.checkCondition(this.cond, srcAction);
		}
		
		/**
		 * 检查是否满足主行动跟随触发条件
		 * @param	ignoreFollow 是否忽略一般攻击性后续跟随行动（特定跟随不会被忽略）
		 */
		protected function checkFollow(srcAction:AttackAction, ignoreFollow:Boolean):Boolean
		{
			var info:String;
			if (this.follow)
			{
				if (this.follow == 'all'){	//强制绑定
					return true;
				}
				else{
					info = srcAction.getInfo();
					if (info == this.follow)
						return true;
					else
						return false;
				}
			}
			if (this.data.unFollow)
			{
				//不能跟随特定行动发动
				info = srcAction.getInfo();
				if (info == this.data.unFollow)
					return false;
			}
			//通用型如果被禁止，不能跟随发动
			return !ignoreFollow;
		}
		
		/**
		 * 检查回合是否触发
		 */
		private function checkRound(srcAction:AttackAction = null):Boolean
		{
			//如果有傲气阻挡
			var fight:FightLogic = this.unitFighting.getFight();
			var point:int;
			if(!this.data.nonSkill)
			{
				point = this.unitFighting.logic.skillPoint;
				if (point<ConfigFight.ratePoint){
					if (fight.random.determine(point)==false){
						//trace('傲气'+proud + ' 阻止施法');
						return false;
					}
				}
			}

			if (this.round == null)
			{
				return true;
			}
			var roundNum:int = fight.round;
			var roundString:String = roundNum.toString();
			point = 0;
			if (this.round.hasOwnProperty(roundString))
			{
				point = this.round[roundString];
			}
			else if (roundNum > 0)
			{
				if (roundNum <= 2)
				{
					//远战回合
					if (this.round.hasOwnProperty('far'))
					{
						point = this.round.far;
					}
				}
				else
				{
					//近战回合
					if (this.round.hasOwnProperty('near'))
					{
						point = this.round.near;
					}
				}
				if (point == 0 && this.round.hasOwnProperty('all'))
				{
					//都未能匹配
					point = this.round.all;
				}
			}
			if (point == 0 && this.round.hasOwnProperty('any'))
			{
				//都未能匹配
				point = this.round.any;
			}
			if (srcAction){
				//有对标的技能，当前技能等级如果大于源技能，提升释放概率
				if (this.round.hasOwnProperty('lv>') && this.lv > srcAction.lv){
					point += this.round['lv>'];
				}
			}
			if (this.round.hasOwnProperty('energy') && this.data.costKey){
				//消耗标记类的技能，可能因为标记数量而提升触发概率
				var energyNum:int = this.unitFighting.troopFighting.getEnergy(this.data.costKey);
				if (energyNum>0){
					point += this.round.energy * energyNum;
				}
			}
			return fight.random.determine(point);
		}
		
		/**
		 * 检查是否满足所有触发条件，首层与，2层或，3层与...
		 */
		protected function checkCondition(condArr:Array, srcAction:AttackAction, isOr:Boolean = false):Boolean
		{
			if (condArr == null)
			{
				return true;
			}
			var fight:FightLogic = this.unitFighting.getFight();
			var i:int;
			var len:int = condArr.length;
			//var troopFighting:TroopFighting;
			for (i = 0; i < len; i++)
			{
				//本次检查的结果
				var isTrue:Boolean = false;
				var condOneArr:Array = condArr[i];
				
				if (condOneArr[0] is Array){
					//如果内部仍是数组，则表示或的关系，外层表示与
					isTrue = this.checkCondition(condOneArr, srcAction, !isOr);
				}
				else{
					//最后单层关系
					var type:String = condOneArr[0];
					var value:* = condOneArr[1];
					var value2:* = condOneArr[2];
					
					switch (type)
					{
						case 'army': //我军部队存活且未被控制
							isTrue = this.checkConditionArmy(this.unitFighting.troopFighting, value, true);
							break;
						case 'enemyArmy': //敌军部队存活
							isTrue = this.checkConditionArmy(this.getEnemyTroopFighting(), value);
							break;
						case 'noMain': //当前回合未用主动行为（只算Main阶段）
							isTrue = !this.unitFighting.doneMain;
							break;
						case 'comp': //比较双方属性，胜出才能触发
							var isBurn:Boolean = false;
							var heroLogic:HeroLogic = this.unitFighting.troopFighting.heroFighting.getHeroLogic();
							if (heroLogic.comp == 'loss'){
								//拼点无效
								isTrue = false;
								break;
							}
							var isWin:Boolean = this.unitFighting.compareHero(value, value2);
							if (value != 'sum' && heroLogic.comp){
								//非比较总四维时可替代
								if ((!value2&&!isWin)||(value&&isWin)){
									//比多失败或比少获胜，主动方尝试再比
									value = heroLogic.comp;
									if (this.unitFighting.compareHero(value,value2)){
										isWin = true;
									}
									else{
										isTrue = false;
										break;
									}
								}
							}
							if(!isWin){
								isTrue = false;
							}
							else{
								//拼点成功，只有主动方才显示压制
								if (this.unitFighting == srcAction.unitFighting)
								{
									var j:int;
									var jLen:int = srcAction.compArr.length;
									var isRepeat:Boolean = false;
									for (j = 0; j < jLen; j++){
										var oneArr:Array = srcAction.compArr[j];
										if (oneArr[0] == value){
											//重复属性拼点
											isRepeat = true;
											break;
										}
									}
									if(!isRepeat)
										srcAction.compArr.push([value, isBurn]);
								}
								isTrue = true;
							}
							
							break;
						case 'hp':  //比较双方总兵力
							isTrue = this.unitFighting.troopFighting.compareArmyHp(value);
							break;
						case 'hpPoint':  //己方兵力千分点满足特定条件
							var hpPoint:int = this.unitFighting.troopFighting.getArmyHpPoint();
							if (condOneArr[3] && condOneArr[4]){
								//经过特殊标记修正
								value2 += this.unitFighting.troopFighting.getEnergy(condOneArr[3]) * condOneArr[4];
							}
							isTrue = FightUtils.compareValue(hpPoint, value2, value);
							break;
						case 'enemyHpPoint':  //敌方兵力千分点满足特定条件
							var enemyHpPoint:int = this.getEnemyTroopFighting().getArmyHpPoint();
							isTrue = FightUtils.compareValue(enemyHpPoint, value2, value);
							break;
						case 'rnd':  //几率触发
							isTrue = fight.random.determine(value);
							break;
						case 'checkBuff': //场中存在状态[1]敌我[2]部队[3]状态类型或指定状态[4]比较符[5]数量  
							isTrue = this.checkConditionBuff(condOneArr, srcAction);
							break;
						case 'energy': //满足特定的标记数量  
							var energyNum:int = this.unitFighting.troopFighting.getEnergy(value);
							isTrue = (energyNum >= value2);
							break;
							
						default: 
							isTrue = this.checkConditionExtend(condOneArr, srcAction);
							break;
					}
				}
				
				if (isTrue){
					if (isOr) return true;
				}else{
					if (!isOr) return false;
				}
			}
			return !isOr;
		}
		
		/**
		 * 检查触发条件  场中存在状态  [1]敌我[2]部队[3]状态类型或指定状态[4]比较符[5]数量  
		 */
		private function checkConditionBuff(condArr:Array, srcAction:AttackAction):Boolean
		{
			var num:int = 0;
			var unitFighting:UnitFighting;
			
			var tgtObj:Object = {'tgt':[condArr[1], condArr[2]]};
			var tgts:Array = this.getTargets(tgtObj);
			var len:int = tgts.length;
			for (var i:int = 0; i < len; i++) 
			{
				unitFighting = tgts[i];
				var buffType:* = condArr[3];
				num += unitFighting.buffManager.getBuffNum(buffType, srcAction.data.type != ConfigFight.ACT_PRE);
			}
			FightUtils.compareValue(num, condArr[5], condArr[4]);
			
			return FightUtils.compareValue(num, condArr[5], condArr[4]);
		}
		
		/**
		 * 检查扩展触发条件是否满足
		 */
		private function checkConditionExtend(condArr:Array, srcAction:AttackAction):Boolean
		{
			if (srcAction == null)
			{
				return true;
			}
			var type:String = condArr[0];
			var value:* = condArr[1];
			switch (type)
			{
			//case 'srcInfo': //当前主行动info为特定字段时才能触发（用于专用技绑定）
			//if (srcAction.getInfo() != value)
			//{
			//return false;
			//}
			//break;
			case 'srcArmy': //当前主行动来源armyIndex为特定时触发
				if (srcAction.unitFighting.logic.armyIndex != value)
				{
					return false;
				}
				break;
			case 'fate': //合击技，如果满足，则将该英雄加入合击套餐
				var troopLogic:TroopLogic = this.getTroopFighting().troopLogic;
				if (!troopLogic.others){
					return false;
				}
				var attends:Object = troopLogic.others.attends;
				//优先使用自己的副将
				var hid:String = FightUtils.getFateHid(attends, troopLogic.getSimplestAdjutantHids(), value, condArr[2], troopLogic.hid);

				if (hid == null)
				{
					return false;
				}else if (hid == ''){
					//没有添加合击技人员但允许合击
				}
				else{
					srcAction.fateHeroArr.push(hid);
				}
				break;
			case 'dmgRealRate': //当来源存在百分比伤害时
				if (srcAction.data )
				{
					return false;
				}
				break;
			default: 
				break;
			}
			return true;
		}
		
		/**
		 * 检查是否满足部队存活类条件，mustCanAction为true时该部队还不能被控
		 */
		private function checkConditionArmy(troopFighting:TroopFighting, value:int, mustCanAction:Boolean = false):Boolean
		{
			if (value == -1)
			{
				//只存活单军时触发
				if (troopFighting.getOnlyArmyIndex() == -1)
				{
					return false;
				}
			}
			else
			{
				var unitFighting:UnitFighting = troopFighting.getUnitFighting(value);
				if (!unitFighting)
					return false;
				
				if (mustCanAction){
					//指定部队活着还未被控时触发
					if (!unitFighting.canAction)
					{
						return false;
					}
				}else{
					//指定部队存活时触发
					if (!unitFighting.alive)
					{
						return false;
					}
				}
			}
			return true;
		}
		
		/**
		 * 执行动作，额外覆盖对象
		 */
		public function doAction(bindingObj:Object = null):void
		{
			//TestPrint.instance.timeStart('doAction' + this.getInfo());
			this.printAction();
			//TestPrint.instance.timeEnd('doAction' + this.getInfo());
		}
		
		
		/**
		 * 返回所有目标UnitFighting
		 */
		public function getTargets(tgtObj:Object):Array
		{
			var tgtArr:Array = tgtObj.tgt?tgtObj.tgt:[0,0];
			var arr:Array = [];
			
			var troopArr:Array;
			var troopIndex:int = tgtArr[0];
			//部队目标 0我方1敌方-1全体
			if (troopIndex == 0)
			{
				troopArr = [this.getTroopFighting()];
			}
			else if (troopIndex == 1)
			{
				troopArr = [this.getEnemyTroopFighting()];
			}
			else if (troopIndex == -1)
			{
				troopArr = [this.getEnemyTroopFighting(), this.getTroopFighting()];
			}
			else
			{
				troopArr = [];
			}
			
			var i:int;
			var iLen:int = troopArr.length;
			var tgtArmy:int = tgtArr[1];
			var tgtHero:int = tgtObj.tgtHero?tgtObj.tgtHero:0;
			//var tgtAdj0:int = troopArr.length>3?tgtArr[3]:0;
			//var tgtAdj1:int = troopArr.length>4?tgtArr[4]:0;
			
			for (i = 0; i < iLen; i++)
			{
				var troopFighting:TroopFighting = troopArr[i];
				//armyIndex前后军目标 0前军1后军2英雄3前副将4后副将 -1全军 -2任一军 -3另一军 -4英雄及前军 -5同一军 -6不计死亡的前后军 -7不计死亡的玩家 -8活着的英雄及前后军（执行时自动按情况变化）
				
				if (tgtArmy > -6){
					//多数情况，暂时兼容老版本
					this.addAliveArmyArr(arr, troopFighting, tgtArmy);
				}
				else if (tgtArmy == -6){
					arr.push(troopFighting.getArmyFighting(0),troopFighting.getArmyFighting(1));
				}
				else if (tgtArmy == -7){
					arr.push(troopFighting.heroFighting);
				}
				else if (tgtArmy == -8){
					if (troopFighting.heroFighting.alive)
						arr.push(troopFighting.heroFighting);
					this.addAliveArmyArr(arr, troopFighting, -1);
				}
				else if (tgtArmy == -9){
					arr.push(troopFighting.getArmyFighting(0));
				}
				else if (tgtArmy == -10){
					arr.push(troopFighting.getArmyFighting(1));
				}

				if (tgtHero){
					//强制包含英雄
					if (arr.indexOf(troopFighting.heroFighting) == -1){
						if (tgtHero > 0){
							if (troopFighting.heroFighting.alive)
							{
								arr.push(troopFighting.heroFighting);
							}
						}
						else{
							arr.push(troopFighting.heroFighting);
						}
					}
				}
			}
			
			return arr;
		}
		
		/**
		 * 增加存活的目标armyIndex数组   前后军目标 0前军1后军2英雄 -1全军 -2随机一军 -3另一军（执行时自动按情况变化）
		 */
		private function addAliveArmyArr(arr:Array, troopFighting:TroopFighting, targetArmyIndex:int):Array
		{
			var armyArr:Array = troopFighting.getAliveArmyArr(targetArmyIndex, this.unitFighting.logic.armyIndex);
			var i:int;
			var len:int = armyArr.length;
			
			for (i = 0; i < len; i++)
			{
				var tgtUnitFighting:UnitFighting = troopFighting.getUnitFighting(armyArr[i]);
				if(tgtUnitFighting)
					arr.push(tgtUnitFighting);
			}
			return arr;
		}
		
		
		
		
		public function getPlaybackData():*
		{
			return null;
		}
		
		/**
		 * 打印(纯客户端使用)
		 */
		public function printAction():void
		{
			//var className:String = FightUtils.getClassName(this);
			if (FightLogic.canPrint)
			{
				var actStr:String;
				if (this.data.type == ConfigFight.ACT_ROUND){
					actStr = '回合重置时发动';
				}
				else if (this.data.type == ConfigFight.ACT_PRE){
					actStr = '预先发动';
				}
				else if (this.data.type == ConfigFight.ACT_BUFF){
					actStr = '执行状态';
				}
				else if (this.data.type == ConfigFight.ACT_FIRST){
					actStr = '被动发动';
				}
				else if (this.data.type == ConfigFight.ACT_MAIN){
					actStr = '发动了';
				}
				else if (this.data.type == ConfigFight.ACT_ATK_AFT){
					actStr = '跟随发动';
				}
				else if (this.data.type == ConfigFight.ACT_HIT_AFT){
					actStr = '反制发动';
				}
				else if (this.data.type == ConfigFight.ACT_WIN){
					actStr = '胜利发动';
				}
				else if (this.data.type == ConfigFight.ACT_LOSS){
					actStr = '败北发动';
				}
				else if (this.data.type == ConfigFight.ACT_HERO){
					actStr = '中间发动';
				}
				else if (this.data.type == ConfigFight.ACT_DEBUFF_FAIL){
					actStr = '补充发动';
				}
				else{
					actStr = '特殊发动';
				}
				var priorityStr:String = '  优先级:'+this.data.priority;
				FightLogic.print('  ' + this.unitFighting.getName() + ' ' + actStr + '『' + this.getPrintInfo() + '』'+priorityStr, null, this.getPrintColor());
			}
		}
		
		/**
		 * 获得技能描述(用于判定follow条件，此外纯客户端使用)
		 */
		public function getInfo():String
		{
			var info:String;
			if (this.data.hasOwnProperty('info'))
			{
				info = this.data.info[0];
			}
			else
			{
				info = '???';
			}
			return info;
		}
		
		/**
		 * 获得技能动作名称打印(纯客户端使用)
		 */
		public function getPrintInfo():String
		{
			var lvStr:String = '';
			if (this.data.hasOwnProperty('info'))
			{
				if (this.data.lv && (this.data.info[1]==1 || this.data.info[1]==2)){
					lvStr = 'lv' + this.data.lv;
				}
			}
			return Tools.getMsgById(this.getInfo(), null, false) + lvStr;
		}
		/**
		 * 获得打印颜色(纯客户端使用)
		 */
		public function getPrintColor():String
		{
			return FightPrint.getPrintColor(this.unitFighting.logic.teamIndex);
		}
		/**
		 * 获得打印颜色(纯客户端使用)
		 */
		public function getPrintColorEnemy():String
		{
			return FightPrint.getPrintColor(this.unitFighting.logic.enemyTeamIndex);
		}
		
		/**
		 * 获得文字描述数组，补加技能等级(纯客户端使用)
		 */
		private function getInfoArr():Array
		{
			if (this.data.hasOwnProperty('info'))
			{
				var arr:Array = this.data.info;
				return arr.concat(this.lv,this.data.isBurn);
			}
			return null;
		}
		
		/**
		 * 合并文字描述(纯客户端使用)
		 */
		public function mergeInfos(srcData:Object):void
		{
			var infoArr:Array = this.getInfoArr();
			if (infoArr == null)
			{
				return;
			}
			
			if (!srcData.hasOwnProperty('infos'))
			{
				srcData.infos = [];
			}
			srcData.infos.push(infoArr);
		}
		/**
		 * 扩展文字描述(纯客户端使用)
		 */
		//public function extendInfos(srcData:Object, extend:*):Boolean
		//{
			//var infoArr:Array = this.getInfoArr();
			//if (infoArr == null)
			//{
				//return false;
			//}
			//
			//var infos:Array = srcData.infos;
			//if (infos){
				//var len:int = infos.length;
				//for (var i:int = 0; i < len; i++) 
				//{
					//var tempInfoArr:Array = infos[i];
					//if (tempInfoArr[0] == infoArr[0] && tempInfoArr[1] == infoArr[1] && tempInfoArr[2] == infoArr[2]){
						//tempInfoArr[3] = extend;
						//return true;
					//}
				//}
			//}
			//return false;
		//}
		
		
		/**
		 * 合并特效(纯客户端使用)
		 */
		public function mergeEffects(srcData:Object):void
		{
			if (!this.data.hasOwnProperty('eff'))
			{
				return;
			}
			
			if (!srcData.hasOwnProperty('effs'))
			{
				srcData.effs = [];
			}
			else if (srcData.effs.length >= 2)
			{
				return;
			}
			srcData.effs.push(this.data.eff);
		}
	
	}

}