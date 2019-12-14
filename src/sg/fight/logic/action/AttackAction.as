package sg.fight.logic.action
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.fighting.ArmyFighting;
	import sg.fight.logic.fighting.HeroFighting;
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	
	/**
	 * 攻击行动
	 * @author zhuda
	 */
	public class AttackAction extends TargetAction
	{
		private var bindingActions:Array;
		///临时记录的回放数据
		protected var _playbackData:Object;
		
		///共同参与的合击技英雄
		public var fateHeroArr:Array;
		///刚刚的拼点属性[key,isBurn]
		public var compArr:Array;
		
		public function AttackAction(unitFighting:UnitFighting, data:Object)
		{
			super(unitFighting, data);
			
			this.bindingActions = [];
			this.fateHeroArr = [];
			this.compArr = [];
		}
		
		override public function getPlaybackData():*
		{
			return this._playbackData;
		}
		
		public function addBindingAction(bindingAction:BindingAction):void
		{
			this.bindingActions.push(bindingAction);
		}
		
		/**
		 * 检查触发猛击，返回猛击的真实伤害叠加
		 */
		public function checkBash():int
		{
			if (this.unitFighting.logic.isArmy)
			{
				var armyLogic:ArmyLogic = this.unitFighting.logic as ArmyLogic;
				if (armyLogic.bash > 0)
				{
					if (this.getFight().random.determine(armyLogic.bash))
						return armyLogic.bashDmg;
				}
			}
			return 0;
		}
		/**
		 * 克隆多倍数据准备攻击
		 */
		protected function cloneMultData(srcData:Object):Object
		{
			return FightUtils.clone(this.data);
		}
		
		/**
		 * 停止行动，被无懈
		 */
		public function stopAction():void
		{
			var srcData:Object = {unit: [this.unitFighting.logic.teamIndex, this.unitFighting.logic.armyIndex]};
			var playbackValueData:Object = {src: [srcData], tgt: [], effs:['effStop']};
			this._playbackData = {key: 'act', time: ConfigFight.fightStopActionTime, value: playbackValueData};
			
			this.mergeInfos(srcData);
			this.getFight().addPlayback(this._playbackData);
		}
		
		/**
		 * 对所有目标依次进行攻击
		 */
		override public function doAction(bindingObj:Object = null):void
		{
			//自身已死，什么都不执行
			if (!this.srcFree && !this.unitFighting.alive)
				return;
			
			super.doAction(bindingObj);
			
			//没有目标的话，什么都不执行
			if (!this.tgt)
				return;
				
				
				
			var srcData:Object = {unit: [this.unitFighting.logic.teamIndex, this.unitFighting.logic.armyIndex]};
			var playbackValueData:Object = {src: [srcData], tgt: []};
			this._playbackData = {key: 'act', time: ConfigFight.fightActionTime, value: playbackValueData};
			
			//副本，随便折腾
			var atkObj:Object = this.cloneMultData(srcData);
			this.mergeInfos(atkObj);
			this.mergeEffects(atkObj);

			//补充buff
			if (!atkObj.buff){
				atkObj.buff = {};
			}
			//绑定攻击特效
			atkObj = this.actionBefore(atkObj);
			if (bindingObj){
				for (var key:String in bindingObj)
				{
					FightUtils.changeObjByPath(atkObj, key, bindingObj[key]);
				}
			}
			
			//如果触发了使用后刷新效果，在此刷新，确保刷新的次数不被无懈。且刷新出的次数不在总次数限制范围内
			if (atkObj.refresh){
				this.refresh(atkObj.refresh);
				if (FightLogic.canPrint)
				{
					FightLogic.print('    ' + this.unitFighting.getName() + ' 的『' + this.getPrintInfo() + '』可额外连发' + atkObj.refresh + '次', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
				}
			}
			

			var enemyHeroFighting:HeroFighting = this.getEnemyTroopFighting().heroFighting;
			if (this.unitFighting is HeroFighting && this.data.isHero && !this.data.follow){
				//发动正常英雄技时，若敌方英雄存活，且存在英雄技反制技能（无懈），可以立即使用
				if (enemyHeroFighting.alive && enemyHeroFighting.doReHeroActions(this)){
					if (FightLogic.canPrint)
					{
						FightLogic.print('    ' + this.unitFighting.getName() + ' 发动的『' + this.getPrintInfo() + '』被无效化了', null, FightPrint.getPrintColor(this.unitFighting.logic.teamIndex));
					}
					return;
				}
			}else if (this.data.type != ConfigFight.ACT_HERO){
				//非无懈执行中，才检查灵蛇禁锢禁用辅助技
				if (enemyHeroFighting.checkReAssistActions(this)){
					return;
				}
			}

			
			if (atkObj.hasOwnProperty('time'))
			{
				this._playbackData.time = atkObj.time;
			}
			
			playbackValueData.effs = atkObj.effs;
			if (this.fateHeroArr.length > 0)
			{
				playbackValueData.fate = this.fateHeroArr;
				this.fateHeroArr = [];
			}
			if (this.compArr.length > 0)
			{
				playbackValueData.comp = this.compArr;
				this.compArr = [];
			}
			//触发猛击
			if(!atkObj.noBfr){
				var bash:int = this.checkBash();
				if (bash)
				{
					playbackValueData.bash = bash;
					atkObj.dmgReal += bash;
				}
			}
			//加入暴击力，技能有额外暴击力
			atkObj.crit = this.unitFighting.logic.crit + (atkObj.crit ? atkObj.crit : 0);
			atkObj.ignDef = atkObj.ignDef ? atkObj.ignDef : 0;
			
			//如果有自损效果，在此生效（对阵NPC时不自损兵力）
			if (atkObj.loss>0 && !this.getEnemyTroopFighting().troopLogic.isNpc)
			{
				var hpLoss:int = this.unitFighting.lossHpSelf(atkObj.loss);
				srcData.hurt = [hpLoss, 2, this.unitFighting.getHp()];
			}
			
			//连打
			var j:int;
			var jLen:int = atkObj.combo ? atkObj.combo : 1;
			if (atkObj.comboRnd){
				//有几率有额外次数
				var comboRnd:int = Math.round(atkObj.comboRnd);
				jLen += this.getFight().random.getRandomInt(comboRnd);
			}
			
			var i:int;
			var iLen:int;
			var tgtArr:Array;
			var target:UnitFighting;
			var attackedTargets:Object = {};
			for (j = 0; j < jLen; j++)
			{
				//连打时需要先判断,敌人是否已全灭
				if (target)
				{
					if (!target.troopFighting.alive)
					{
						//如果是对自己的可无视死亡
						if (target != this.unitFighting){
							break;
						}
					}
				}
				
				//找到每个目标，攻击他们
				tgtArr = this.getTargets(atkObj);
				iLen = tgtArr.length;
				
				for (i = 0; i < iLen; i++)
				{
					//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest
					//if (i==1 && this.getInfo() == 'skill222'){
						////黄月英对战司马懿，司马地刺出手
						//
						//if (this.getTroopFighting().troopLogic.hid == 'hero707' && this.getEnemyTroopFighting().troopLogic.hid == 'hero705'){
							//var fight:FightLogic = this.getFight();
							//trace('客户端：' +fight.isClient + ' 第' + fight.fightCount +'战 第' + fight.round + '合 第' + fight.playbacks.length + '招：黄月英对战司马懿，司马地刺出手');
							//trace(this.getTroopFighting().troopLogic,this.getEnemyTroopFighting().troopLogic);
							//TestFightData.testNextHurt = true;
						//}
					//}
					//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestEnd
					
					
					target = tgtArr[i];
					this.attackOne(target, atkObj, attackedTargets[target.id]);
					attackedTargets[target.id] = 1;
				}
			}
			
			//如果有攻后追击效果，在此生效
			this.actionAfter(atkObj);
			

			//记录回放数据
			if (atkObj.infos)
				srcData.infos = atkObj.infos;
			
			//无目标的内讧，或追击不会放进战报
			tgtArr = playbackValueData.tgt;
			if (tgtArr.length > 0){
				this.getFight().addPlayback(this._playbackData);
			}
		}
		

		
		/**
		 * 对目标进行攻击UnitFighting
		 * 整理来源类型 和 目标类型，计算出伤害
		 */
		protected function attackOne(target:UnitFighting, atkObj:Object, isCombo:Boolean):void
		{
			var hitObj:Object;
			var buffObj:Object = FightUtils.clone(atkObj.buff);
			hitObj = {buff: buffObj, nonSkill: atkObj.nonSkill, noBuff: atkObj.noBuff, noBfr: atkObj.noBfr, noAft: atkObj.noAft, noKill: atkObj.noKill};
						
			if (AttackAction.isSummon(atkObj)){
				//有征召效果
				hitObj.summonReal = this.getSummonReal(atkObj);
				hitObj.summon = atkObj.summon?atkObj.summon:0;
			}
			else if (AttackAction.isCure(atkObj)){
				//有治疗效果
				hitObj.cureReal = atkObj.cureReal;
				hitObj.cure = atkObj.cure?atkObj.cure:0;
				hitObj.cureScale = atkObj.cureScale?atkObj.cureScale:0;
			}
			else{
				var dmgOutPer:Number;
				var atk:int;
				if (target.logic.isHero)
				{
					//目标是英雄
					dmgOutPer = 1;
					atk = 1;
				}
				else
				{
					var targetArmy:ArmyLogic = target.logic as ArmyLogic;
					dmgOutPer = this.getDamageOutPer(targetArmy, atkObj);
					atk = dmgOutPer > 0 ? this.getCurrAttack(atkObj):0;
				}
				//hitObj.dmg已经是小数
				hitObj.crit = atkObj.crit;
				hitObj.ignDef = atkObj.ignDef;
				hitObj.atk = atk;
				hitObj.dmg = dmgOutPer;
				hitObj.dmgDebuff = atkObj.dmgDebuff;
				hitObj.dmgDebuffReal = atkObj.dmgDebuffReal;
				//hitObj = {crit: atkObj.crit, ignDef: atkObj.ignDef, atk: atk, dmg: dmgOutPer, dmgDebuff: atkObj.dmgDebuff, buff: buffObj, nonSkill: atkObj.nonSkill, noBuff: atkObj.noBuff, noBfr: atkObj.noBfr, noAft: atkObj.noAft, noKill: atkObj.noKill};
				hitObj.dmgReal = this.getDamageOutReal(atkObj);
				hitObj.dmgRealRate = this.getDamageOutRealRate(atkObj);
				hitObj.dmgRealMax = this.getDamageOutRealMax(atkObj);
				hitObj.dmgScale = atkObj.dmgScale?atkObj.dmgScale:0;
				if (atkObj.element){
					//有元素效果
					hitObj.element = atkObj.element;
				}
			}
			
			//！！！！！！！！！！！！！！！！！！临时调试不一致
			//if (!target.logic.isHero){
				//hitObj.atkObj = atkObj;
				//hitObj.dmgMul1 = FightUtils.pointToPer(atkObj.dmg?atkObj.dmg:0);
				//hitObj.dmgMul2 = this.unitFighting.logic.getDmgMul(targetArmy, atkObj.nonSkill);
				//hitObj.dmgMul3 = FightUtils.pointToPer(ConfigFight.roundDmgArr[this.getFight().round]);
				//
				//hitObj.srcTroop = this.getTroopFighting().troopLogic.getCompData();
				//hitObj.tgtTroop = target.logic.troopLogic.getCompData();
			//}
			
			
			if (atkObj.removeBuff){
				hitObj.removeBuff = atkObj.removeBuff;
			}
			if (atkObj.removeDebuff){
				hitObj.removeDebuff = atkObj.removeDebuff;
			}
			if (atkObj.energyKey){
				//具有 充能效果
				hitObj.energyKey = atkObj.energyKey;
				hitObj.energy = this.getEnergyNum(atkObj);
			}
			
			if (FightLogic.canPrint)
			{
				if(!atkObj.stop)
					FightLogic.print('    ' + target.getName() + ' 被指为目标', null, FightPrint.getPrintColor(target.logic.teamIndex));
			}
			
			target.beHit(this, hitObj, isCombo, this._playbackData);
			//var dmgIn:int = target.beHit(this.unitFighting.logic, hitObj);
		
			//trace('    ' + this.unitFighting.getName() + info + target.getName());
		
		}
		
		/**
		 * 攻击前绑定，为自己附加所有绑定效果,装饰原攻击对象
		 */
		public function actionBefore(atkObj:Object):Object
		{
			var i:int;
			var len:int;
			var bindingAction:BindingAction;
			var atkBfrArr:Array = this.unitFighting.actions[ConfigFight.ACT_ATK_BFR];
			
			len = atkBfrArr.length;
			if (len > 0){
				var enemyHeroFighting:HeroFighting = this.getEnemyTroopFighting().heroFighting;
				for (i = 0; i < len; i++)
				{
					bindingAction = atkBfrArr[i];
					if (bindingAction.checkCanUse(this, atkObj.noBfr && !atkObj.allowSelf))
					{
						if (enemyHeroFighting.checkReAssistActions(bindingAction)){
							//被阻止了辅助技
							continue;
						}
						else{
							bindingAction.bindingAttackData(atkObj);
						}
					}
				}
			}
			
			return atkObj;
		}
		
		/**
		 * 攻击后绑定，追击技能
		 */
		public function actionAfter(atkObj:Object):void
		{
			var attackAfterArr:Array = this.unitFighting.actions[ConfigFight.ACT_ATK_AFT];
			var i:int;
			var len:int = attackAfterArr.length;
			for (i = 0; i < len; i++)
			{
				var act:ActionBase = attackAfterArr[i];
				if (act.checkCanUse(this, atkObj.noAft))
				{
					act.addExtraAction();
				}
			}
		}
		
		/**
		 * 计算当前来源攻击力
		 */
		private function getCurrAttack(atkObj:Object):int
		{
			var atkSrcArr:Array = [];
			atkSrcArr.push(atkObj.hasOwnProperty('atk0') ? atkObj.atk0 : 0);
			atkSrcArr.push(atkObj.hasOwnProperty('atk1') ? atkObj.atk1 : 0);
			
			var atk:int = 0;
			var armys:Array = this.getTroopFighting().armys;
			for (var i:int = ConfigFight.armyNum - 1; i >= 0; i--)
			{
				var value:int = atkSrcArr[i];
				if (value != 0)
				{
					var army:ArmyFighting = armys[i];
					atk += army.getCurrAttack() * FightUtils.pointToPer(value);
				}
			}
			atk = Math.ceil(atk);
			return atk;
		}
		
		
		/**
		 * 计算召唤士兵的数量
		 */
		protected function getSummonReal(atkObj:Object):int
		{
			var summonReal:int =  atkObj.summonReal?atkObj.summonReal:0;
			if (atkObj.summonRealRnd){
				summonReal += this.getFight().random.getRandomInt(atkObj.summonRealRnd, atkObj.summonRealRndExp);
			}
			return summonReal;
		}
		
		/**
		 * 计算输出伤害率，合并本回合伤害强度，已为小数（如果是PVP战斗，伤害乘以系数）
		 */
		protected function getDamageOutPer(targetArmy:ArmyLogic, atkObj:Object):Number
		{
			//var atk:int = this.getAttack(atkObj);
			var fight:FightLogic = this.getFight();
			
			var srcDmgRnd:int = atkObj.dmgRnd ? fight.random.getRandomInt(atkObj.dmgRnd) : 0;
			var srcDmg:int = atkObj.dmg ? atkObj.dmg : 0;
			
			var dmgMul1:Number = FightUtils.pointToPer(srcDmg + srcDmgRnd);
			var dmgMul2:Number = this.unitFighting.logic.getDmgMul(targetArmy, atkObj.nonSkill);
			var dmgMul3:Number = FightUtils.pointToPer(ConfigFight.roundDmgArr[fight.round]);
			if (fight.isPVP){
				dmgMul3 *= ConfigFight.pkDamagePer;
			}
			var dmg:Number = dmgMul1 * dmgMul2 * dmgMul3;
			//if (dmg<0){
				//trace(this.unitFighting.getName()+'【getDamageOutPer异常】' + dmgMul1+','+dmgMul2+','+dmgMul3);
			//}
			return dmg;
		}
		
		/**
		 * 计算输出真实伤害
		 */
		protected function getDamageOutReal(atkObj:Object):int
		{
			var dmgReal:int = atkObj.dmgReal?atkObj.dmgReal:0;
			if (atkObj.dmgRealRnd){
				dmgReal += this.getFight().random.getRandomInt(atkObj.dmgRealRnd, atkObj.dmgRealRndExp);
			}
			if (atkObj.dmgRealHpm0){
				dmgReal += FightUtils.pointToPer(atkObj.dmgRealHpm0) * this.getTroopFighting().troopLogic.getArmy(0).hpm;
			}
			if (atkObj.dmgRealHpm1){
				dmgReal += FightUtils.pointToPer(atkObj.dmgRealHpm1) * this.getTroopFighting().troopLogic.getArmy(1).hpm;
			}

			return dmgReal;
		}
		
		/**
		 * 计算真实百分比伤害千分率
		 */
		protected function getDamageOutRealRate(atkObj:Object):int
		{
			var num:int = atkObj.dmgRealRate ? atkObj.dmgRealRate : 0;
			var rnd:int = atkObj.dmgRealRateRnd ? this.getFight().random.getRandomInt(atkObj.dmgRealRateRnd, atkObj.dmgRealRateRndExp) : 0;
			return num + rnd;
		}
		/**
		 * 计算真实最大百分比伤害千分率
		 */
		protected function getDamageOutRealMax(atkObj:Object):int
		{
			var num:int = atkObj.dmgRealMax ? atkObj.dmgRealMax : 0;
			var rnd:int = atkObj.dmgRealMaxRnd ? this.getFight().random.getRandomInt(atkObj.dmgRealMaxRnd, atkObj.dmgRealMaxRndExp) : 0;
			return num + rnd;
		}		
		/**
		 * 计算能量获得数量
		 */
		protected function getEnergyNum(atkObj:Object):int
		{
			var num:int = atkObj.energy ? atkObj.energy : 0;
			var rnd:int = atkObj.energyRnd ? this.getFight().random.getRandomInt(atkObj.energyRnd, atkObj.energyRndExp) : 0;
			return num + rnd;
		}
	
		
		/**
		 * 是否为征召回复兵力效果
		 */
		public static function isSummon(atkObj:Object):Boolean
		{
			return atkObj.summonReal;
		}
		/**
		 * 是否为治疗效果
		 */
		public static function isCure(atkObj:Object):Boolean
		{
			return atkObj.cureReal;
		}
		/**
		 * 是否为杀伤效果
		 */
		public static function isDamage(atkObj:Object):Boolean
		{
			return !AttackAction.isSummon(atkObj) && !AttackAction.isCure(atkObj);
		}
	}

}