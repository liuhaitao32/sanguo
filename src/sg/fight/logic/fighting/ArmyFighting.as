package sg.fight.logic.fighting
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.ArmyLogic;
	import sg.fight.logic.unit.AttackerLogic;
	import sg.fight.logic.utils.FightClimbUtils;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	import sg.fight.test.TestFightData;
	import sg.utils.Tools;
	
	/**
	 * 战斗中独立行动的部队
	 * @author zhuda
	 */
	public class ArmyFighting extends UnitFighting
	{
		public function ArmyFighting(troopFighting:TroopFighting, logic:ArmyLogic)
		{
			super(troopFighting, logic);
			this.alive = logic.hp > 0;
			//同速下，前军先行，守方先行
			this.baseSpeed = (2 - logic.armyIndex) * 0.4 + logic.teamIndex * 0.1;
		}
		
		/**
		 * 获取当前速度，同速下，前军先行，守方先行
		 */
		override public function get speed():Number
		{
			return this.logic.spd + this.baseSpeed;
		}
		
		public function getArmyLogic():ArmyLogic
		{
			return this.logic as ArmyLogic;
		}
		
		/**
		 * 计算当前攻击力，还要核算buff等
		 */
		public function getCurrAttack():int
		{
			//已经全灭无攻击
			var armyLogic:ArmyLogic = this.getArmyLogic();
			return armyLogic.currAtk;
		}
		
		/**
		 * 计算当前防御等
		 */
		public function getCurrDefense():int
		{
			var armyLogic:ArmyLogic = this.getArmyLogic();
			return armyLogic.currDef;
		}
		
		/**
		 * 自损效果(按当前百分比掉血，不会致死)
		 */
		override public function lossHpSelf(value:int):int
		{
			var armyLogic:ArmyLogic = this.getArmyLogic();
			var hpOld:int = armyLogic.hp;
			var hpLoss:int = Math.floor(armyLogic.hp * FightUtils.pointToPer(value) / FightUtils.pointToRate(armyLogic.resRealRate));
			armyLogic.hp = Math.max(1, armyLogic.hp - hpLoss);
			var hpNew:int = armyLogic.hp;
			hpLoss = hpOld - hpNew;
			if (FightLogic.canPrint){
				var info:String;
				info = this.getName() + ' 自损兵力' + hpLoss + ' (' + hpOld + ' → ' + hpNew + ')';
				FightLogic.print('      ' + info, null, FightPrint.getPrintColor(this.logic.teamIndex));
			}
			return hpLoss;
		}
		
		/**
		 * 判定暴击格挡，直接影响伤血效果（真实伤害不会被暴击或格挡），返回1暴击 0正常 -1格挡
		 */
		private function checkCritOrBlock(dmg:int,hitData:Object):Array
		{
			//加入格挡力，技能有额外格挡力
			var armyLogic:ArmyLogic = this.getArmyLogic();
			var crit:int = hitData.crit;
			var block:int = armyLogic.block + (hitData.block?hitData.block:0);
			var type:int;
			
			if (crit > ConfigFight.maxPoint){
				type = 1;
			}
			else if (block > ConfigFight.maxPoint){
				type = -1;
			}
			else{
				if (crit < 0) crit = 0;
				if (block < 0) block = 0;
				var weightObj:Array = [['1',crit],['-1',block],['0',ConfigFight.ratePoint]];
				var str:String = FightClimbUtils.randomWeightObj(weightObj, this.getFight().random);
				type = parseInt(str);
			}

			delete hitData.crit;
			delete hitData.block;
			
			
			if (type == 1){
				//暴击
				dmg = Math.ceil(FightUtils.pointToPer(ConfigFight.critRate) * dmg);
			}
			else if (type == -1){
				//格挡
				dmg = Math.ceil(FightUtils.pointToPer(ConfigFight.blockRate) * dmg);
			}

			return [dmg,type];
		}
		/**
		 * 被攻击伤血，hitObj.dmg已经是小数
		 */
		override protected function beHitDamage(attackAction:AttackAction, hitData:Object, tgtData:Object):Array
		{
			var armyLogic:ArmyLogic = this.getArmyLogic();
			var wounded:int;
			var dmgIn:int = 0;
			///伤害类型0普通 1暴击 -1格挡 3治疗 4护盾
			var type:int = 0;
			var elementRate:Number;
			var info:String = '';
			var hpOld:int = armyLogic.hp;
			var hpNew:int = hpOld;
			var canPrint:Boolean = FightLogic.canPrint;
			
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest
			//if (TestFightData.testNextHurt){
				//trace(hitData, tgtData);
			//}
			//TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestEnd
			
			
			if (AttackAction.isSummon(hitData)){
				//征召效果
				type = 3;
				var summon:int = Math.floor(hitData.summonReal + FightUtils.pointToPer(hitData.summon) * armyLogic.hpm);
				//治疗量不能超出最大兵力
				if (hpOld + summon > armyLogic.hpm){
					summon = armyLogic.hpm - hpOld;
				}
				//处理elementSummon对应全部召唤恢复效果
				elementRate = armyLogic.others['elementSummon'];
				if (elementRate){
					summon = Math.max(0,Math.ceil(summon * FightUtils.pointToRate(elementRate)));
				}
				
				dmgIn = -summon;
				armyLogic.beHit(dmgIn);
				this.revive();
				
				if (canPrint){
					hpNew = armyLogic.hp;
					info = this.getName() + ' 征召兵力' + summon + ' (' + hpOld + ' → ' + hpNew+')';
					FightLogic.print('      ' + info, null, FightPrint.getPrintColor(this.logic.teamIndex));
				}
			}
			else if (AttackAction.isCure(hitData)){
				//治疗，消耗对应伤兵
				type = 3;
				wounded = this.troopFighting.getEnergy('wounded' + armyLogic.armyIndex);
				if (wounded>0){
					var cure:int = Math.floor((hitData.cureReal + FightUtils.pointToPer(hitData.cure) * wounded) * FightUtils.pointToRate(hitData.cureScale));
					if (cure){
						cure = Math.min(wounded, cure);
						//治疗量不能超出最大兵力
						if (hpOld + cure > armyLogic.hpm){
							cure = armyLogic.hpm - hpOld;
						}
						//处理elementCure对应全部治疗效果
						elementRate = armyLogic.others['elementCure'];
						if (elementRate){
							cure = Math.max(0,Math.ceil(cure * FightUtils.pointToRate(elementRate)));
						}
						
						this.troopFighting.addEnergy( -cure, 'wounded' + armyLogic.armyIndex);
						dmgIn = -cure;
						
						armyLogic.beHit(dmgIn);
						this.revive();

						if (canPrint){
							hpNew = armyLogic.hp;
							info = this.getName() + ' 治疗兵力' + cure + ' (' + hpOld + ' → ' + hpNew+')'+ '   剩余伤兵'+this.troopFighting.getEnergy('wounded' + armyLogic.armyIndex);
							FightLogic.print('      '+ info, null, FightPrint.getPrintColor(this.logic.teamIndex));
						}
					}
				}
			}
			else{
				//伤害类
				var attackerLogic:AttackerLogic = attackAction.unitFighting.logic;
				var debuffNum:int = -1;
				//应用过的防御值
				var def:Number = 0;
				var dmgTempValue:Number;
				
				if (hitData.dmg > 0)
				{
					//计算忽视防御后防御
					def = 1 - FightUtils.pointToPer(hitData.ignDef);
					if(def > 0){
						def *= this.getCurrDefense();
					}
					//保底攻击力
					var atkIn:Number =  Math.max(hitData.atk * ConfigFight.damageMinPer, hitData.atk - def * ConfigFight.defValuePer);
					//输入伤害率
					var dmgTemp:Number = hitData.dmg / armyLogic.getResMul(attackerLogic, hitData.nonSkill);
					
					//this.testTrace('防御：', def);
					//this.testTrace('攻击：', atkIn);
					//this.testTrace('输入伤害率1：',dmgTemp);

					if (hitData.dmgDebuff)
					{
						//每有一个debuff伤害增加
						if(debuffNum<0){
							debuffNum = this.buffManager.getBuffNum(2);
						}
						if(debuffNum){
							dmgTemp *= 1 + (FightUtils.pointToPer(hitData.dmgDebuff) * debuffNum);
						}
					}
					
					//this.testTrace('输入伤害率2：', dmgTemp);
					//this.testTrace('当前buffs：', this.buffManager.buffArr);
					
					//结算伤害
					dmgIn = Math.ceil(dmgTemp * atkIn * ConfigFight.damageOutPer);
					
					//this.testTrace('伤害0：',dmgIn);
					
					//计算暴击格挡的普通伤害
					var arr:Array = this.checkCritOrBlock(dmgIn,hitData);
					dmgIn = arr[0];
					type = arr[1];
				}
				else if(hitData.dmg<0){
					if (canPrint){
						info = this.getName() + ' 未损失兵力' + ' (' + armyLogic.hp+')';
						FightLogic.print('      '+ info + '   【异常】输入伤害率'+Tools.percentFormat(hitData.dmg,2) + ' 输入真实伤害' + hitData.dmgReal, null, FightPrint.getPrintColor(this.logic.teamIndex));
					}
				}

				//this.testTrace('伤害1：',dmgIn);

				if (hitData.dmgReal)
				{
					hitData.dmgReal = Math.floor(hitData.dmgReal);
					dmgIn += hitData.dmgReal;
				}
				if (hitData.dmgDebuffReal)
				{
					//每有一个debuff伤害增加
					if(debuffNum<0){
						debuffNum = this.buffManager.getBuffNum(2);
					}
					if(debuffNum){
						dmgIn += hitData.dmgDebuffReal * debuffNum;
					}
				}
				
				
				//this.testTrace('伤害2：',dmgIn);
				
				if (dmgIn && !hitData.noBuff){
					dmgTempValue = dmgIn;
					
					//处理最终增减伤害，此时已经包含真实伤害
					if (attackerLogic.dmgFinal){
						dmgIn *= FightUtils.pointToRate(attackerLogic.dmgFinal);
					}
					if (armyLogic.resFinal){
						dmgIn /= FightUtils.pointToRate(armyLogic.resFinal, true);
					}
					if (hitData.dmgScale){
						dmgIn *= FightUtils.pointToRate(hitData.dmgScale);
					}
					
					dmgIn = Math.ceil(dmgIn * attackerLogic.dmgRealPer / armyLogic.resRealPer);
					
					//最后   检查一系列因兽灵带来的伤害免伤效果系数	
					dmgIn = this.checkBeastDmg(attackAction, dmgIn, def);
					
					
					//if (canPrint && dmgTempValue != dmgIn){
						//info = '检查了增减伤效果和兽灵，修正伤害 ' + dmgTempValue + ' → ' + dmgIn;
						//FightLogic.print('      '+ info, null, FightPrint.getPrintColor(this.logic.teamIndex));
					//}
				}
				
				//this.testTrace('伤害3：',dmgIn);
				
				if (hitData.dmgRealRate)
				{
					//按当前生命的千分率掉血，单纯此效果不会导致阵亡
					dmgIn += Math.min(hpOld-1,Math.floor(hpOld * FightUtils.pointToPer(hitData.dmgRealRate) / FightUtils.pointToRate(armyLogic.resRealRate, true)));
				}
				if (hitData.dmgRealMax)
				{
					//按最大生命的千分率掉血，会导致阵亡
					dmgIn += Math.floor(armyLogic.hpm * FightUtils.pointToPer(hitData.dmgRealMax) / FightUtils.pointToRate(armyLogic.resRealRate, true));
				}
				
				//this.testTrace('伤害4：',dmgIn);
				
				//结算暴击格挡的最后附加伤害
				if (type == 1){
					dmgTempValue = attackerLogic.troopLogic.critAdd + ConfigFight.critAdd;
					if (canPrint){
						info = attackAction.unitFighting.getName() +' 触发了暴击，修正伤害 ' + dmgIn + ' → ' + (dmgIn+dmgTempValue) + ' (比率伤害影响在之前已生效)';
						FightLogic.print('      '+ info, null, FightPrint.getPrintColor(attackerLogic.teamIndex));
					}
					dmgIn += dmgTempValue;
				}
				else if (type == -1){
					dmgTempValue = -(this.troopFighting.troopLogic.blockAdd + ConfigFight.blockAdd);
					
					if (canPrint){
						info = this.getName() +' 触发了格挡，修正伤害 ' + dmgIn + ' → ' + Math.max(0,dmgIn+dmgTempValue) + ' (比率伤害影响在之前已生效)';
						FightLogic.print('      '+ info, null, FightPrint.getPrintColor(this.logic.teamIndex));
					}
					dmgIn += dmgTempValue;	
					if (dmgIn < 0)
						dmgIn = 0;
				}
				
				//this.testTrace('伤害5：',dmgIn);
				
				if(dmgIn){
					if (hitData.element){
						//处理元素抗性
						elementRate = armyLogic.others['element' + hitData.element];
						if (elementRate){
							dmgTempValue = Math.ceil(dmgIn * FightUtils.pointToRate(elementRate));
							if (canPrint){
								info = '受到'+ hitData.element +'元素影响，修正伤害 ' + dmgIn + ' → ' + Math.max(0, dmgTempValue);
								FightLogic.print('      '+ info, null, FightPrint.getPrintColor(this.logic.teamIndex));
							}

							dmgIn = Math.max(0, dmgTempValue);
						}
					}
					if (hitData.noKill){
						//无法致死
						dmgIn = Math.min(hpOld - 1, dmgIn);
					}
				}
				
				//this.testTrace('伤害6：',dmgIn);
				info = '';
				hitData.dmgIn = dmgIn;
				if (dmgIn){
					if (this.bearDamage(armyLogic, dmgIn, tgtData)){
						//应用了完全抵挡的护盾
						dmgIn = 0;
					}
					else{
						//战损充能（普通护盾也不影响充能）
						this.troopFighting.addEnergy(dmgIn);
		
						//armyLogic.beHit(dmgIn);
						hpNew = armyLogic.hp;
						//伤兵充能
						wounded = Math.floor((hpOld-hpNew) * ConfigFight.woundedPer);
						if(wounded){
							this.troopFighting.addEnergy(wounded, 'wounded' + armyLogic.armyIndex);
						}
						if (armyLogic.hp == 0)
						{
							this.dead();
							info = '【阵亡】';
						}
					}
					//trace('      ' + this.getName() + '  兵力：' + hpOld + ' -> ' + armyLogic.hp);
					if (canPrint){
						info = this.getName() + ' 损失兵力' + (hpOld-hpNew) + ' (' + hpOld + ' → ' + hpNew+')' + info;
						FightLogic.print('      '+ info + '   输入伤害率'+Tools.percentFormat(hitData.dmg,2) + ' 输入真实伤害' + hitData.dmgReal, null, FightPrint.getPrintColor(this.logic.teamIndex));
					}
					//trace('      伤害' + atkData.dmg + '(+' + atkData.dmgReal + ')\t ' + this.getName() + '\t 承受'  + dmgIn + '\t 兵力' + hpOld + ' -> ' + armyLogic.hp + info);
				}
				else if(hitData.dmg>0){
					if (canPrint){
						info = this.getName() + ' 未损失兵力' + ' (' + armyLogic.hp+')';
						FightLogic.print('      '+ info + '   输入伤害率'+Tools.percentFormat(hitData.dmg,2) + ' 输入真实伤害' + hitData.dmgReal, null, FightPrint.getPrintColor(this.logic.teamIndex));
					}
				}

			}

			
			//this.testTrace('打印结束',null, true);
			
			return [dmgIn,type,this.getHp()];
		}
		/**
		 * 承受战损，可能优先用护盾承担。返回是否应用了完全抵挡的护盾
		 */
		private function bearDamage(armyLogic:ArmyLogic, dmgIn:int,tgtData:Object):Boolean
		{
			var arr:Array = this.buffManager.bearDamage(dmgIn,tgtData);
			dmgIn = arr[0];
			armyLogic.beHit(dmgIn);
			return arr[1];
		}
		
		
		/**
		 * 最后   处理一系列因兽灵带来的伤害免伤效果
		 */
		private function checkBeastDmg(attackAction:AttackAction, dmgIn:int, def:Number):int
		{
			if (dmgIn<=0)
				return 0;
			var bearRate:Number = 1;
			var bearDmg:int = 0;
			var value:Number;
			var temp:Number;
			var enemyTroopFighting:TroopFighting = attackAction.getTroopFighting();
			if (enemyTroopFighting.troopLogic.teamIndex == this.troopFighting.troopLogic.teamIndex){
				//自己打自己的不受兽灵影响
				return dmgIn;
			}
			var atkBeast:Object = enemyTroopFighting.beastObj;
			var beHitBeast:Object = this.troopFighting.beastObj;
			if (!atkBeast && !beHitBeast){
				return dmgIn;
			}
			var fight:FightLogic = this.getFight();
			//穿透防御或临时防御值
			var defValue:int = 0;
			//受方兵力
			var beHitHpPer:Number = this.troopFighting.getArmyHpPer();
			//攻方仅剩单队
			var atkOnly:Boolean = enemyTroopFighting.getOnlyArmyIndex()>=0;
			
			if (atkBeast){
				//攻方携带的效果
				//回合增伤类检查
				value = atkBeast['round_dmg_' + fight.round];
				if (value){
					bearRate *= FightUtils.pointToRate(value);
				}
				//前后军、英雄穿透防御检查
				if(def){
					value = atkBeast['act_army' + attackAction.unitFighting.logic.armyIndex + '_ignDef'];
					if (value){
						defValue -= value;
					}
				}
				//受方兵力比例类检查
				if (beHitHpPer < ConfigFight.beastHpLow){
					value = atkBeast['hp_low_dmg'];
					if (value){
						bearRate *= FightUtils.pointToRate(value);
					}
				}
				else if (beHitHpPer > ConfigFight.beastHpHigh){
					value = atkBeast['hp_high_dmg'];
					if (value){
						bearRate *= FightUtils.pointToRate(value);
					}
				}
				//攻方仅剩单队
				if (atkOnly){
					value = atkBeast['only_dmg'];
					if (value){
						bearRate *= FightUtils.pointToRate(value);
					}
				}
				//攻方武智属性压制
				value = atkBeast['str_dmg'];
				if (value){
					temp = enemyTroopFighting.getHeroDValue('str');
					if(temp >= ConfigFight.beastCompPoint){
						bearRate *= FightUtils.pointToRate(value);
					}
				}
				value = atkBeast['agi_dmg'];
				if (value){
					temp = enemyTroopFighting.getHeroDValue('agi');
					if(temp >= ConfigFight.beastCompPoint){
						bearRate *= FightUtils.pointToRate(value);
					}
				}
				
				//攻方任意伤害加值
				value = atkBeast['any_dmgReal'];
				if (value){
					bearDmg += value;
				}
			}
			if (beHitBeast){
				//受方携带的效果
				//回合免伤类检查
				value = beHitBeast['round_res_' + fight.round];
				if (value){
					bearRate /= FightUtils.pointToRate(value);
				}
				//前后军、英雄临时防御检查
				if(def){
					value = beHitBeast['act_army' + attackAction.unitFighting.logic.armyIndex + '_strDef'];
					if (value){
						defValue += value;
					}
				}
				//受方兵力比例类检查
				if (beHitHpPer < ConfigFight.beastHpLow){
					value = beHitBeast['hp_low_res'];
					if (value){
						bearRate /= FightUtils.pointToRate(value);
					}
				}
				else if (beHitHpPer > ConfigFight.beastHpHigh){
					value = beHitBeast['hp_high_res'];
					if (value){
						bearRate /= FightUtils.pointToRate(value);
					}
				}
				//攻方仅剩单队
				if (atkOnly){
					value = beHitBeast['only_res'];
					if (value){
						bearRate /= FightUtils.pointToRate(value);
					}
				}
				//受方魅统属性压制
				value = beHitBeast['cha_res'];
				if (value){
					temp = this.troopFighting.getHeroDValue('cha');
					if(temp >= ConfigFight.beastCompPoint){
						bearRate /= FightUtils.pointToRate(value);
					}
				}
				value = beHitBeast['lead_res'];
				if (value){
					temp = this.troopFighting.getHeroDValue('lead');
					if(temp >= ConfigFight.beastCompPoint){
						bearRate /= FightUtils.pointToRate(value);
					}
				}
				
				//受方任意伤害加值
				value = beHitBeast['any_resReal'];
				if (value){
					bearDmg -= value;
				}
				
			}
			if (bearRate != 1){
				dmgIn *= bearRate;
			}
			if (defValue){
				//因为穿透防御或临时防御带来的额外伤害值
				temp = def * FightUtils.pointToPer(-defValue) * ConfigFight.beastDefPer;
				temp = Math.min(ConfigFight.beastDefDmgMax * dmgIn, Math.max(ConfigFight.beastDefDmgMin * dmgIn, temp));
				dmgIn += temp;
			}
			if (bearDmg){
				dmgIn += bearDmg;
			}
			return Math.floor(Math.max(1,dmgIn));
		}
		
		/**
		 * 剩余兵力千分点
		 */
		override public function getHp():int
		{
			var armyLogic:ArmyLogic = this.getArmyLogic();
			return armyLogic.hp;
		}
		
		
		/**
		 * 测试打印
		 */
		//private function testTrace(str:String = null,value:* = null,isEnd:Boolean = false):void
		//{
			//if (TestFightData.testNextHurt){
				//trace(str,value);
				//if (isEnd){
					//TestFightData.testNextHurt = false;
				//}
			//}
		//}
	}
}