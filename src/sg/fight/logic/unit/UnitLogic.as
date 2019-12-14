package sg.fight.logic.unit
{
	import sg.cfg.ConfigServer;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	
	/**
	 * 活着的单位，不直接生成，使用其子类英雄或前后军生成
	 * @author zhuda
	 */
	public class UnitLogic extends AttackerLogic
	{
		///最终含真实伤害抗性（千分点）
		public var resFinal:int;
		///所有伤害抗性（千分点）
		public var res:int;
		///对武将伤害抗性（千分点）
		public var resType0:int;
		///对文官伤害抗性（千分点）
		public var resType1:int;
		///对全才伤害抗性（千分点）
		public var resType2:int;
		///对女性伤害抗性（千分点）
		public var resSex0:int;
		///对男性伤害抗性（千分点）
		public var resSex1:int;
		///对步兵伤害抗性（千分点）
		public var resArmy0:int;
		///对骑兵伤害抗性（千分点）
		public var resArmy1:int;
		///对弓兵伤害抗性（千分点）
		public var resArmy2:int;
		///对方士伤害抗性（千分点）
		public var resArmy3:int;
		
		///英雄技能伤害抗性（千分点）
		public var resHero:int;
		///兵种技能伤害抗性（千分点）
		public var resArmy:int;
		///格挡率（千分点）
		public var block:int;
		
		///攻击
		public var atk:int;
		///防御
		public var def:int;
		///最大兵力
		public var hpm:int;
		///当前兵力
		public var hp:int;
		
		//临时属性

		///战斗中Buff攻击额外加成
		public var atkRate:int;
		///战斗中Buff防御额外加成
		public var defRate:int;
		///战斗中Buff免伤额外加成
		public var resRate:int;
		///最低血量攻击千分点
		public var atkMin:int;
		///剩余豁免会导致全灭的攻击次数（兵力剩1）
		public var stamina:int;
		///受到按比例损失兵力的效果减免（1000则减免一半，对自损生效）
		public var resRealRate:int;


		///攻击乘率，战斗开始时合并，整场生效  可受到buff影响
		public var atkPer:Number;
		///防御乘率，战斗开始时合并，整场生效  可受到buff影响
		public var defPer:Number;
		///免伤乘率，战斗开始时合并，整场生效  可受到buff影响
		public var resPer:Number;
		///含真实伤害免伤乘率，战斗开始时合并，整场生效  可受到buff影响
		public var resRealPer:Number;
		

		
		///初始化血量比例
		public var initHpPer:Number;

		
		public function UnitLogic(data:*, troopLogic:TroopLogic, armyIndex:int ,initHp:int)
		{
			super(data, troopLogic, armyIndex);
			if (initHp >= 0){
				this.hp = initHp;
			}
		}
		
		/**
		 * 战斗开始，重置
		 */
		override public function resetStart(fightLogic:FightLogic):void
		{
			this.atkRate = 0;
			this.defRate = 0;
			this.resRate = 0;
			this.atkMin = ConfigFight.attackMinPoint;
			this.stamina = 0;
			this.resRealRate = 0;
			
			this.atkPer = 1;
			this.defPer = 1;
			this.resPer = 1;
			this.resRealPer = 1;

			super.resetStart(fightLogic);

			this.initHpPer = this.hpPer;
			
			if (this.troopLogic.shogun){
				//幕府，英雄的伤害乘率不受影响
				var shogunValue:Number = this.troopLogic.shogun[0] +this.troopLogic.shogun[this.armyIndex + 1];
				//新增PVP幕府衰减
				if (fightLogic.isPVP){
					shogunValue *= ConfigFight.pkShogunPer;
				}
				if (fightLogic.battle_special && fightLogic.battle_special.shogunPoint){
					//战役对双方的幕府加减成效果
					shogunValue *= FightUtils.pointToRate(fightLogic.battle_special.shogunPoint);
				}
				this.atkPer *= FightUtils.pointToRate(shogunValue * ConfigFight.shogunRate[0]);
				this.defPer *= FightUtils.pointToRate(shogunValue * ConfigFight.shogunRate[1]);
				this.dmgPer *= FightUtils.pointToRate(shogunValue * ConfigFight.shogunRate[2]);
				this.resPer *= FightUtils.pointToRate(shogunValue * ConfigFight.shogunRate[3]);
			}
			if (this.troopLogic.magic){
				//卜卦
				var magicCfg:Object = ConfigServer.mining.magic_date[this.troopLogic.magic];
				if(magicCfg && magicCfg.attack_value){
					var magicValue:Number = FightUtils.pointToRate(magicCfg.attack_value);
					this.atkPer *= magicValue;
					this.defPer *= magicValue;
				}
			}
			if (this.troopLogic.bless){
				//祝福加含真实伤害免伤
				this.resRealPer *= 1+this.troopLogic.bless;
			}
			if (this.troopLogic.others){
				if (this.troopLogic.others.hasOwnProperty('official')){
					//国战官职buff增加攻击防御
					var official:int = this.troopLogic.others.official;
					var officialArr:Array = ConfigFight.officialRate[official.toString()];
					if (officialArr){
						this.atkPer *= FightUtils.pointToRate(officialArr[0]);
						this.defPer *= FightUtils.pointToRate(officialArr[1]);
					}
				}
				var buffValue:Number = this.troopLogic.getCountryBuffValue(false);
				if (buffValue)
				{
					this.resRealPer *= FightUtils.pointToRate(buffValue * ConfigFight.cityBuffRate[1]);
				}

				var spiritData:* = this.troopLogic.getSpiritData();
				if(spiritData){
					//获得激励
					for (var key:String in spiritData)
					{
						if (this.hasOwnProperty(key))
						{
							this[key] += spiritData[key];
						}
					}
				}
			}

		}
		
		/**
		 * 重置傲气相关属性
		 */
		override protected function resetProud():void
		{
			var proud:int = this.troopLogic.proud;
			if (proud){
				//疲劳或傲气
				var cfgArr:Array = proud > 0?ConfigFight.proudActionRate:ConfigFight.proudTiredRate;

				if (proud < 0)
					proud = -proud;
				
				var proudPer:Number = FightUtils.pointToRate(-Math.min( proud * cfgArr[2], cfgArr[3]));
				this.atkPer *= proudPer;
				this.defPer *= proudPer;
				//this.skillPoint = Math.min(cfgArr[0] * proud, cfgArr[1]);
				var point:int = Math.min(cfgArr[0] * proud, cfgArr[1]);
				this.skillPoint = Math.ceil(this.skillPoint * (1-FightUtils.pointToPer(point)));
			}
		}
		
		/**
		 * 战斗结束，重置该单位的所有数据为初始data，但不重置hp（只有客户端或客户端模拟的服务端战斗才有）
		 */
		override public function resetEnd():void
		{
			this.resFinal = 0;
			this.res = 0;
			this.resType0 = 0;
			this.resType1 = 0;
			this.resType2 = 0;
			this.resSex0 = 0;
			this.resSex1 = 0;
			this.resArmy0 = 0;
			this.resArmy1 = 0;
			this.resArmy2 = 0;
			this.resArmy3 = 0;
			
			this.resHero = 0;
			this.resArmy = 0;
			this.block = 0;

			super.resetEnd();
		}
		
		override public function getData():*
		{
			var reData:Object = {};
			
			var i:int;
			var len:int = ConfigFight.propertyUnitArr.length;
			var key:String;
			for (i = 0; i < len; i++)
			{
				key = ConfigFight.propertyUnitArr[i];
				if (this[key] != 0)
				{
					data[key] = this[key];
				}
			}
			
			return data;
		}
		
		/**
		 * 剩余兵力比例
		 */
		public function get hpPer():Number
		{
			return this.hp / this.hpm;
		}
		
		/**
		* 得到当前攻击力引用的血量比例，混合上初始兵力比例
		 */
		public function get currAtkHpPer():Number
		{
			var tempHpPer:Number = this.hpPer;
			var rate:Number = FightUtils.pointToPer(ConfigFight.initHpPerPoint);
			tempHpPer = rate * this.initHpPer + (1 - rate) * tempHpPer;
			return tempHpPer;
		}
		
		/**
		 * 当前攻击力（现在改为全灭也有攻击力）
		 */
		public function get currAtk():int
		{
			//if (this.hp <= 0){
				//return 0;
			//}
			var per:Number = FightUtils.pointToRate(this.atkRate);
			var atkMinPer:Number = FightUtils.pointToPer(this.atkMin);
			per *= (1 - atkMinPer) * this.currAtkHpPer + atkMinPer;
			per *= this.atkPer;
			return Math.max(1,Math.ceil(this.atk * per));
		}
		/**
		 * 当前防御力
		 */
		public function get currDef():int
		{
			var per:Number = FightUtils.pointToRate(this.defRate);
			per *= this.defPer;
			return Math.max(0,Math.ceil(this.def * per));
		}

		
		/**
		 * 计算输入免伤总倍数
		 */
		public function getResMul(srcAttacker:AttackerLogic, nonSkill:Boolean):Number
		{
			var srcHero:HeroLogic = srcAttacker.getTroopLogic().heroLogic;
			

			
			var resMul:Number;
			resMul = FightUtils.pointToRate(this.res) * this.getTypeResMul(srcHero.type) * this.getSexResMul(srcHero.sex);
			
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest
			//if (TestFightData.testNextHurt){
				//trace('resMul1', resMul);
			//}
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestEnd
			
			if (srcAttacker.isArmy)
			{
				var srcArmy:ArmyLogic = srcAttacker as ArmyLogic;
				resMul *= this.getArmyResMul(srcArmy.type);
				
				//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest
				//if (TestFightData.testNextHurt){
					//trace('黄月英army[1]：',this);
					////trace('army[1].resArmy3：',this.getArmyResMul(srcArmy.type));
					//trace('resMul2', resMul, srcArmy.type ,this.getArmyResMul(srcArmy.type));
				//}
				//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestEnd
			}


			if (!nonSkill && !srcAttacker.isAdjutant)
			{
				resMul *= FightUtils.pointToRate(srcAttacker.isHero ? this.resHero : this.resArmy);
			}
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest
			//if (TestFightData.testNextHurt){
				//trace('resMul3', resMul);
			//}
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestEnd

			resMul *= this.resPer;
			

			resMul *= FightUtils.pointToRate(this.resRate);
			return resMul;
		}
		
		/**
		 * 得到源英雄为文官武将类型的免伤系数
		 */
		private function getTypeResMul(value:int):Number
		{
			return FightUtils.pointToRate(this['resType' + value.toString()]);
		}
		
		/**
		 * 得到源英雄性别类型的免伤系数
		 */
		private function getSexResMul(value:int):Number
		{
			return FightUtils.pointToRate(this['resSex' + value.toString()]);
		}
		
		/**
		 * 得到源兵种类型的免伤系数
		 */
		private function getArmyResMul(value:int):Number
		{
			return FightUtils.pointToRate(this['resArmy' + value.toString()]);
		}
		
		/**
		 * 被攻击
		 */
		public function beHit(value:int):void
		{
			if (this.stamina > 0 && this.hp <= value){
				//抵抗全灭，兵力剩1
				this.stamina--;
				this.hp = 1;
			}
			else
			{
				this.hp = Math.max(0, this.hp - value);
			}
		}
	}

}