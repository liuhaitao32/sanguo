package sg.fight.logic.unit 
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	/**
	 * 攻击者(可以附加攻击类buff)
	 * @author zhuda
	 */
	public class AttackerLogic extends LogicBase
	{
		public var troopLogic:TroopLogic;
		///前后军序号 0前1后2英雄3前副将4后副将
		public var armyIndex:int;
		
		/**
		 * 获得在本场战斗内的唯一id
		 */
		public function getFightId():String{
			return this.troopLogic.teamIndex + '_' + (this.armyIndex + 3);
		}
		override public function getTroopLogic():TroopLogic { 
			return this.troopLogic; 
		}

		public function get isHero():Boolean
		{
			return this.armyIndex == 2;
		}
		public function get isArmy():Boolean
		{
			return this.armyIndex < 2;
		}
		public function get isAdjutant():Boolean
		{
			return this.armyIndex > 2;
		}
		public function getArmyIndex():int
		{
			return this.armyIndex;
		}
		override public function get teamIndex():int { 
			return this.troopLogic.teamIndex; 
		}

		///所有伤害加成（千分点）
		public var dmg:int;
		///最终含真实伤害加成（千分点）
		public var dmgFinal:int;
		///对文官伤害加成（千分点）
		public var dmgType0:int;
		///对武将伤害加成（千分点）
		public var dmgType1:int;
		///对全才伤害加成（千分点）
		public var dmgType2:int;
		///对女性伤害加成（千分点）
		public var dmgSex0:int;
		///对男性伤害加成（千分点）
		public var dmgSex1:int;
		///对步兵伤害加成（千分点）
		public var dmgArmy0:int;
		///对骑兵伤害加成（千分点）
		public var dmgArmy1:int;
		///对弓兵伤害加成（千分点）
		public var dmgArmy2:int;
		///对方士伤害加成（千分点）
		public var dmgArmy3:int;
		
		///技能伤害加成（千分点）
		public var dmgSkill:int;
		///暴击率（千分点）
		public var crit:int;
		///真实伤害猛击率（千分点）
		public var bash:int;
		///真实伤害值
		public var bashDmg:int;
		
		///速度
		public var spd:int;
		
		
		
		//临时属性
		///当前被禁控次数
		public var ban:int;
		///战斗中Buff额外加成伤害率
		public var dmgRate:int;
		///额外受到不良状态几率千分点（小于-1000则不会中，1000则机会加倍）
		public var deBuffRate:int;
		///普通技能发动千分点，战斗开始时合并，整场生效
		public var skillPoint:int;

		
		///伤害乘率，战斗开始时合并，整场生效
		public var dmgPer:Number;
		///国战城市buff伤害乘率，战斗开始时合并，整场生效
		public var dmgRealPer:Number;

		///受到特殊属性攻击加成等，每次战斗开始都会清空，仅能被special初始化
		public var others:Object;

		
		public function AttackerLogic(data:*,troopLogic:TroopLogic,armyIndex:int)
		{
			this.troopLogic = troopLogic;
			this.armyIndex = armyIndex;
			super(data);
		}
		
		/**
		 * 战斗开始，重置
		 */
		public function resetStart(fightLogic:FightLogic):void
		{
			this.ban = 0;
			this.dmgRate = 0;
			this.deBuffRate = 0;
			this.skillPoint = ConfigFight.ratePoint;
			
			this.dmgPer = 1;
			this.dmgRealPer = 1;
			this.others = {};
			
			var buffValue:Number = this.troopLogic.getCountryBuffValue(true);
			if (buffValue)
			{
				this.dmgRealPer *= FightUtils.pointToRate(buffValue * ConfigFight.cityBuffRate[0]);
			}
			if (this.troopLogic.bless){
				//祝福加含真实伤害免伤
				this.dmgRealPer *= 1+this.troopLogic.bless;
			}
			if (fightLogic && fightLogic.battle_special){
				//战役对双方的加减成效果
				FightUtils.mergeObj(this.others, fightLogic.battle_special);
			}
			
			this.resetProud();
		}
		/**
		 * 战斗结束，重置该单位的所有数据为初始data，但不重置hp（只有客户端或客户端模拟的服务端战斗才有）
		 */
		public function resetEnd():void
		{
			this.dmg = 0;
			this.dmgFinal = 0;
			this.dmgType0 = 0;
			this.dmgType1 = 0;
			this.dmgType2 = 0;
			this.dmgSex0 = 0;
			this.dmgSex1 = 0;
			this.dmgArmy0 = 0;
			this.dmgArmy1 = 0;
			this.dmgArmy2 = 0;
			this.dmgArmy3 = 0;
			
			this.dmgSkill = 0;
			this.crit = 0;
			this.bash = 0;
			this.bashDmg = 0;
			this.spd = 0;

			this.setData(this.data);
		}
		
		/**
		 * 重置傲气相关属性
		 */
		protected function resetProud():void
		{
			var proud:int = this.troopLogic.proud;
			if (proud){
				//疲劳或傲气
				var cfgArr:Array = proud > 0?ConfigFight.proudActionRate:ConfigFight.proudTiredRate;
				if (proud < 0)
					proud = -proud;
				var point:int = Math.min(cfgArr[0] * proud, cfgArr[1]);
				this.skillPoint = Math.ceil(this.skillPoint * (1-FightUtils.pointToPer(point)));
			}
		}
		
		/**
		 * 计算输出伤害总倍数
		 * nonSkill 非技能
		 */
		public function getDmgMul(targetArmy:ArmyLogic,nonSkill:Boolean):Number
		{
			var targetHero:HeroLogic = targetArmy.troopLogic.heroLogic;
				
			var dmgMul:Number;
			dmgMul = FightUtils.pointToRate(this.dmg) * this.getTypeDmgMul(targetHero.type) * this.getSexDmgMul(targetHero.sex) * this.getArmyDmgMul(targetArmy.type);
			if (!nonSkill)
			{
				dmgMul *= FightUtils.pointToRate(this.dmgSkill);
			}
			dmgMul *= this.dmgPer;
			dmgMul *= FightUtils.pointToRate(this.dmgRate);
			return dmgMul;
		}
		
		/**
		 * 得到目标英雄为文官武将类型的伤害系数
		 */
		private function getTypeDmgMul(value:int):Number
		{
			return FightUtils.pointToRate(this['dmgType' + value.toString()]);
		}
		/**
		 * 得到目标英雄性别类型的伤害系数
		 */
		private function getSexDmgMul(value:int):Number
		{
			return FightUtils.pointToRate(this['dmgSex' + value.toString()]);
		}
		/**
		 * 得到目标兵种类型的伤害系数
		 */
		private function getArmyDmgMul(value:int):Number
		{
			return FightUtils.pointToRate(this['dmgArmy' + value.toString()]);
		}
		
		override public function clear():void
		{
			super.clear();
			this.troopLogic = null;
		}
	}

}