package sg.fight.logic.fighting
{
	import laya.maths.MathUtil;
	import sg.cfg.ConfigApp;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.action.ActionBase;
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.action.BindingAction;
	import sg.fight.logic.action.CostAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.AttackerLogic;
	import sg.fight.logic.BuffManager;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.unit.TroopLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	
	/**
	 * 战斗中独立行动的单位
	 * @author zhuda
	 */
	public class UnitFighting extends FightingBase
	{
		public var troopFighting:TroopFighting;
		
		public function getFight():FightLogic
		{
			return this.troopFighting.fightLogic;
		}
		
		/**
		 * 获取敌对的部队
		 */
		public function getEnemyTroopFighting():TroopFighting
		{
			return this.troopFighting.getEnemyTroopFighting();
		}
		
		///本场战斗的唯一id
		public var id:String;
		///本回合尚未行动
		public var active:Boolean;
		///尚且生存
		public var alive:Boolean;
		///基础速度
		public var baseSpeed:Number;
		public function get speed():Number
		{
			return this.baseSpeed;
		}
		///逻辑实体
		public var logic:AttackerLogic;
		
		///每个回合需要清理的动作数组，为ConfigFight.ACT_ROUND_ARRAY的有效子集
		public var actionRounds:Array;
		///该战斗单位整理好的各情况action，已按优先级排好顺序  0起始 【1主】2攻前 3攻后 4防前 5防后 6状态 7对方英雄技 8战胜 9战败 10急救净化（在buff检测前绑定） 11施加debuff 12对方辅助触发技能
		public var actions:Array;
		
		///本回合正在行动的步骤阶段，不可逆[10急救净化，-1检查状态，0起始, 6状态动作, 1主, -2行动后状态]
		public var activeStep:int;
		///本回合是否已使用main行动，如果已经有，则不追加普攻
		public var doneMain:Boolean;
		
		///buff管理器
		public var buffManager:BuffManager;
		
		public function UnitFighting(troopFighting:TroopFighting, logic:AttackerLogic)
		{
			this.troopFighting = troopFighting;
			this.logic = logic;
			this.id = logic.teamIndex.toString() + logic.armyIndex.toString();
			
			this.buffManager = new BuffManager(this);
			
			this.initActions();
		}
		
		/**
		 * 活着且未被控制
		 */
		public function get canAction():Boolean
		{
			return this.alive && this.logic.ban == 0;
		}
		
		/**
		 * 初始化所有act空数组
		 */
		private function initActions():void
		{
			var i:int;
			this.actions = [];
			for (i = 0; i < ConfigFight.ACT_NUM; i++)
			{
				this.actions.push([]);
			}
		}
		
		/**
		 * 新回合重置
		 */
		public function resetRound():void
		{
			//TestPrint.instance.timeStart('resetRound');
			this.active = this.alive;
			var i:int;
			var len:int = this.actionRounds.length;
			var act:ActionBase;
			for (i = 0; i < len; i++)
			{
				var actType:int = this.actionRounds[i];
				var actArr:Array = this.actions[actType];
				
				var j:int;
				var jLen:int = actArr.length;
				for (j = 0; j < jLen; j++)
				{
					act = actArr[j];
					act.resetRound();
				}
				
				
				if (jLen > 0 && actType == ConfigFight.ACT_ROUND){
					var fight:FightLogic = this.getFight();
					//每个大回合重置阶段（无视速度）直接执行的动作
					for (j = 0; j < jLen; j++)
					{
						act = actArr[j];
						if(act.checkCanUse()){
							fight.addAction(act);
						}
					}
				}
			}
			//TestPrint.instance.timeEnd('resetRound');
		}
		
		/**
		 * 轮到自己的回合，重置
		 */
		public function startRound():void
		{
			this.active = false;
			this.doneMain = false;
			this.activeStep = 0;
			
			if (FightLogic.canPrint)
			{
				FightLogic.print(this.getName() + ' 开始行动！    速度:' +this.speed, null, FightPrint.getPrintColor(this.logic.teamIndex));
			}
		}
		
		/**
		 * 返回下个action
		 */
		public function nextAction():ActionBase
		{
			var currStepId:int;
			while (this.activeStep < ConfigFight.ACT_ACTIVE_ARRAY.length){
				//尝试各个阶段的action，阶段间不能反转
				currStepId = ConfigFight.ACT_ACTIVE_ARRAY[this.activeStep];
				if (currStepId == ConfigFight.ACT_CHECK_BUFF){
					this.buffManager.checkBuffs(0);
				}
				else if (currStepId == ConfigFight.ACT_CHECK_END){
					this.buffManager.checkBuffs(1);
				}
				else{
					var act:AttackAction;
					var i:int;
					var arr:Array;
					var len:int;
					arr = this.actions[currStepId];
					len = arr.length;
					for (i = 0; i < len; i++)
					{
						act = arr[i];
						if (act.checkCanUse(act))
						{
							if (currStepId == ConfigFight.ACT_MAIN)
								this.doneMain = true;
							return act;
						}
					}
				}
				//此阶段已无动作
				this.activeStep++;
			}
			return null;
		}
		
		
		/**
		 * 战斗中,移除指定状态
		 */
		public function removeBuffAction(buffId:String):void
		{
			var arr:Array = this.actions[ConfigFight.ACT_BUFF];
			for (var i:int = arr.length-1; i >=0; i--)
			{
				var act:ActionBase = arr[i];
				if (act.data.buffId == buffId){
					arr.splice(i, 1);
				}
			}
			
		}
		/**
		 * 战斗中,将本回合checkbuff整理好的arr传入，排序并生成Actions
		 */
		public function addBuffActions(arr:Array):void
		{
			this.actions[ConfigFight.ACT_BUFF] = arr;
			var len:int = arr.length;
			if (arr.length > 0)
			{
				this.formatActionArr(arr);
				
				for (var i:int = 0; i < len; i++)
				{
					var act:ActionBase = arr[i];
					act.active = true;
				}
			}
		}
		
		/**
		 * 加入一个act数据，等待之后的合并
		 */
		public function addAction(actData:*):void
		{
			var type:int = actData.type;
			var arr:Array = this.actions[type];
			if(arr)
				arr.push(actData);
		}
		
		/**
		 * 格式化所有Action为类实例，各个数组按优先级排序。并预处理每回合所需清理的动作类型
		 */
		public function formatActions():void
		{
			var i:int;
			var actArr:Array;
			var arrLength:int;
			for (i = 0; i < ConfigFight.ACT_NUM; i++)
			{
				actArr = this.actions[i];
				arrLength = actArr.length;
				if(arrLength){
					this.print('formatAction【' + i + '】 长度:' + arrLength, actArr);
				}
				this.formatActionArr(actArr);
			}
			//预处理每回合所需清理的动作类型
			var len:int = ConfigFight.ACT_ROUND_ARRAY.length;
			this.actionRounds = [];
			for (i = 0; i < len; i++)
			{
				var actType:int = ConfigFight.ACT_ROUND_ARRAY[i];
				actArr = this.actions[actType];
				arrLength = actArr.length;
				if (actArr.length > 0){
					this.actionRounds.push(actType);
				}
			}
		}
		
		/**
		 * 格式化单触发类型的Action数组，进行排序，并将内部元素改为类实例，不同父级的动作互相独立
		 */
		private function formatActionArr(arr:Array):void
		{
			var i:int;
			var len:int = arr.length;
			if (len > 1){
				//增加检查重复优先级
				if (TestFightData.testFightPrint){
					var sameObj:Object = FightUtils.checkSameValue(arr, 'priority');
					if (sameObj){
						FightPrint.print(this.getName() + 'formatAction优先级重复:', sameObj, '#FF0099');
						//trace(this.getName() + 'formatAction优先级重复:',sameObj);
					}
				}
				FightUtils.sortPriority(arr);
			}			
			for (i = 0; i < len; i++)
			{
				var data:Object = arr[i];
				var act:ActionBase = this.newAction(data);
				arr[i] = act;
			}
		}
		
		private function newAction(data:Object):ActionBase
		{
			var act:ActionBase;
			var type:int = data.type;
			if (type == ConfigFight.ACT_ATK_BFR || type == ConfigFight.ACT_HIT_BFR)
			{
				act = new BindingAction(this, data);
			}
			else
			{
				if (data.costKey){
					act = new CostAction(this, data);
				}
				else{
					act = new AttackAction(this, data);
				}
			}
			
			if (act == null)
			{
				act = new ActionBase(this, data);
			}
			return act;
		}
		
		/**
		 * 自损效果(按当前百分比掉血，不会致死)
		 */
		public function lossHpSelf(value:int):int
		{
			return 0;
		}
		
		/**
		 * 被攻击
		 * @param	srcAttacker  攻击者
		 * @param	hitData  hitData.dmg已经是小数
		 * @param	isCombo  是否是追加攻击，追击时不会显示info，也不会触发防后效果
		 * @param	playbackData  打算修改的回放数据
		 * @return
		 */
		public function beHit(attackAction:AttackAction, hitData:Object, isCombo:Boolean, playbackData:Object):int
		{
			hitData = this.beHitBefore(attackAction, hitData);
			
			//创建回放
			var tgtData:Object = {unit: [this.logic.teamIndex, this.logic.armyIndex]};
			
			var hurtArr:Array;
			//加BUFF
			hurtArr = this.beHitBuff(attackAction, hitData, tgtData);
			if(!hurtArr){
				//受伤减血
				hurtArr = this.beHitDamage(attackAction, hitData, tgtData);
			}
			//具有 特定充能标记效果，加入回放
			if (hitData.energyKey){
				this.troopFighting.addEnergy(hitData.energy, hitData.energyKey, tgtData);
				//tgtData.energy = [hitData.energyKey,hitData.energy];
			}
			
			//加入回放内容
			tgtData.hurt = hurtArr;
			if (hitData.effs)
				tgtData.effs = hitData.effs;
			
			//！！！！！！！！！！！！！！！！！！临时调试不一致
			//tgtData.hitData = hitData;
			
				
			var tgtArr:Array = playbackData.value.tgt;
			tgtArr.push(tgtData);
			
			if (!isCombo)
			{
				if (hitData.infos)
					tgtData.infos = hitData.infos;
				this.beHitAfter(attackAction, hitData);
			}
			return hurtArr[0];
		}
		
		/**
		 * 被攻击前绑定附加上状态
		 */
		private function beHitBefore(attackAction:AttackAction, hitData:Object):Object
		{
			var i:int;
			var len:int;
			var bindingAction:BindingAction;
			var hitBfrArr:Array = this.actions[ConfigFight.ACT_HIT_BFR];
			
			len = hitBfrArr.length;
			if (len > 0){
				var enemyHeroFighting:HeroFighting = this.getEnemyTroopFighting().heroFighting;
				for (i = 0; i < len; i++)
				{
					bindingAction = hitBfrArr[i];
					if (bindingAction.checkCanUse(attackAction, hitData.noBfr))
					{
						if (enemyHeroFighting.checkReAssistActions(bindingAction)){
							//被阻止了辅助技
							continue;
						}
						else{
							bindingAction.bindingBeHitData(hitData);
						}
					}
				}
			}
			return hitData;
		}
		
		/**
		 * 被攻击后附加上状态
		 */
		private function beHitBuff(attackAction:AttackAction, hitData:Object, tgtData:Object):Array
		{
			//移除增益或减益buff，加入回放
			if (hitData.removeBuff){
				this.buffManager.removeBuffsByType(1, hitData.removeBuff, tgtData, attackAction.data.type != ConfigFight.ACT_PRE);
			}
			if (hitData.removeDebuff){
				this.buffManager.removeBuffsByType(2, hitData.removeDebuff, tgtData, attackAction.data.type != ConfigFight.ACT_PRE);
			}
			if (hitData.buff)
			{
				//还要逐个判定buff的命中，加入回放
				return this.buffManager.addBuffs(attackAction, hitData, tgtData);
			}
			return null;
		}
		
		/**
		 * 被攻击伤血，hitObj.dmg已经是小数
		 */
		protected function beHitDamage(attackAction:AttackAction, hitData:Object, tgtData:Object):Array
		{
			hitData.dmgIn = 0;
			return [0, 0, this.getHp()];
		}
		
		/**
		 * 被攻击后的反击，如果有被攻击后触发的效果，此时触发
		 */
		public function beHitAfter(attackAction:AttackAction, hitData:Object):void
		{
			if (this.alive)
			{
				var hitAfterArr:Array = this.actions[ConfigFight.ACT_HIT_AFT];
				var i:int;
				var len:int = hitAfterArr.length;
				for (i = 0; i < len; i++)
				{
					var act:ActionBase = hitAfterArr[i];
					if (act.checkCanUse(attackAction, hitData.noAft))
					{
						act.addExtraAction(hitData);
					}
				}
					//trace('    可以接Aft  ' + atkData.noAft);
			}
		}
		
		/**
		 * 因治疗重生
		 */
		public function revive():void {
			if(!this.alive)
				this.active = this.alive = true;
        }
		/**
		 * 死亡
		 */
		public function dead():void
		{
			this.active = this.alive = false;
		}
		

		
		/**
		 * 与对方英雄比较属性，只有大于对方才能生效
		 */
		public function compareHero(key:String, mode:String):Boolean
		{
			var troopLogic:TroopLogic = this.logic.getTroopLogic();
			var heroLogic:HeroLogic = troopLogic.heroLogic;
			
			var enemyTroopLogic:TroopLogic = this.getFight().getTroopFighting(troopLogic.enemyTeamIndex).troopLogic;
			var enemyHeroLogic:HeroLogic = enemyTroopLogic.heroLogic;
			
			if (!mode) mode = '>';
			var value0:Number = heroLogic[key];
			var value1:Number = enemyHeroLogic[key];
			return FightUtils.compareValue(value0, value1, mode);
			
			//if (heroLogic[key] > enemyHeroLogic[key])
			//{
				//return true;
			//}
			//return false;
		}
		
		/**
		 * 剩余兵力
		 */
		public function getHp():int
		{
			if (this.alive)
			{
				return 1;
			}
			return 0;
		}
		
		
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function get _name():String
		{
			return this.getName();
		}
		/**
		 * 获取自身名称简讯(纯客户端使用)
		 */
		public function getName():String
		{
			var str:String = this.troopFighting.getName();
			var index:int = this.logic.armyIndex;
			if (index == 0)
			{
				str += '前军';
			}
			else if (index == 1)
			{
				str += '后军';
			}
			else if (index == 2)
			{
				str += '英雄';
			}
			else if (index == 3)
			{
				str += '前军副将';
			}
			else if (index == 4)
			{
				str += '后军副将';
			}
			else
			{
				str += '???';
			}
			return str;
		}
		
		/**
		 * 打印(纯客户端使用)
		 */
		public function print(str:String, data:Object = null):void
		{
			FightPrint.checkPrint('FightSpecial', '\n' + this.getName() + ' ' + str, data);
		}
		
		override public function clear():void
		{
			super.clear();
			this.troopFighting = null;
			this.logic = null;
			this.actions = null;
			this.actionRounds = null;
			this.buffManager.clear();
			this.buffManager = null;
		}
	}

}