package sg.fight.logic.fighting 
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.action.ActionBase;
	import sg.fight.logic.action.AttackAction;
	import sg.fight.logic.cfg.ConfigFight;
	import sg.fight.logic.unit.HeroLogic;
	import sg.fight.logic.utils.FightPrint;
	
	/**
	 * 战斗中独立行动的英雄
	 * @author zhuda
	 */
	public class HeroFighting extends UnitFighting
	{
		
		public function HeroFighting(troopFighting:TroopFighting,logic:HeroLogic) 
		{
			super(troopFighting, logic);
			this.alive = true;
		}
		
		public function getHeroLogic():HeroLogic
		{
			return this.logic as HeroLogic;
		}
		

		/**
		 * 被攻击伤血
		 */
		override protected function beHitDamage(attackAction:AttackAction,hitData:Object,tgtData:Object):Array
		{
			if (hitData.dmgReal &&	!this.getHeroLogic().undead){
				this.dead();
				if (FightLogic.canPrint){
					FightLogic.print('      '+ this.getName() + '\t 被斩杀！！！', null, FightPrint.getPrintColor(this.logic.teamIndex));
				}
			}
			if(this.alive){
				return [0,0,1];
			}
			return [0,0,0];
		}
		
		/**
		 * 对敌方施加不良状态时，若因几率没有成功，则有15%*妖狐标记数量的几率，强制施加该状态。生效时消耗2个（不足时消耗1）妖狐标记
		 */
		public function doForceDebuffActions(srcAct:AttackAction, tgtUnitFighting:UnitFighting, buffName:String):Boolean
		{
			var i:int;
			var arr:Array = this.actions[ConfigFight.ACT_DEBUFF_FAIL];
			var len:int = arr.length;
			var isForce:Boolean = false;
			if (len > 0){
				var reArr:Array = [];
				var act:AttackAction;
				for (i = 0; i < len; i++) 
				{
					act = arr[i];
					if (act.checkCanUse(srcAct)){
						//act是施加不良追加技，srcAct是原始不良技能。必中的原始不良技能未中的目标
						act.doAction({'tgt':[1, tgtUnitFighting.logic.armyIndex]});
						//act.doAction();
						if (act.data.force){
							isForce = true;
							if (FightLogic.canPrint)
							{
								FightLogic.print('    ' + this.troopFighting.getName() + ' 触发『' + act.getPrintInfo() + '』强制施加状态！', null, FightPrint.getPrintColor(this.logic.teamIndex));
							}
							//兽灵回放
							var playbackDataValue:Object = act.getPlaybackData().value;
							playbackDataValue.beast = buffName;
							//重新绑定目标
						}
						
					}
				}
			}
			
			return isForce;
		}
		
		/**
		 * 对方释放英雄技时，立即响应反馈我方的技能，返回是否停止对方释放英雄技
		 */
		public function doReHeroActions(srcAct:AttackAction):Boolean
		{
			var i:int;
			var arr:Array = this.actions[ConfigFight.ACT_HERO];
			var len:int = arr.length;
			var isStop:Boolean = false;
			if (len > 0){
				var reArr:Array = [];
				var act:AttackAction;
				for (i = 0; i < len; i++) 
				{
					act = arr[i];
					if (act.checkCanUse(srcAct)){
						var enemyHeroFighting:HeroFighting = this.getEnemyTroopFighting().heroFighting;
						if(!enemyHeroFighting.checkReAssistActions(act)){
							if (act.data.stop){
								isStop = true;
								srcAct.stopAction();
							}
							act.doAction();
						}
					}
				}
			}
			
			return isStop;
		}
		
		/**
		 * 对方触发辅助技时，判断是否响应反馈我方的技能，返回是否停止对方释放辅助技
		 */
		public function checkReAssistActions(srcAct:ActionBase):Boolean
		{
			var isStop:Boolean = false;
			if (srcAct.data.isAssist && !srcAct.data.follow){
				if (!srcAct.data.info || srcAct.data.info[1] == 0){
					return false;
				}
				var i:int;
				var arr:Array = this.actions[ConfigFight.ACT_ASSIST];
				var len:int = arr.length;
				if (len > 0){
					var reArr:Array = [];
					var act:AttackAction;
					for (i = 0; i < len; i++) 
					{
						act = arr[i];
						if (act.checkCanUse(null)){
							//act是反馈辅助技，srcAct是发动的辅助技。强制反馈的目标是辅助技发动者
							act.doAction({'tgt':[1,srcAct.unitFighting.logic.armyIndex]});
							if (act.data.stop){
								isStop = true;
								if (FightLogic.canPrint)
								{
									FightLogic.print('    ' + srcAct.unitFighting.getName() + ' 即将触发的『' + srcAct.getPrintInfo() + '』被阻止了', null, FightPrint.getPrintColor(this.logic.teamIndex));
								}
								//兽灵回放，重新绑定目标
								var playbackDataValue:Object = act.getPlaybackData().value;
								playbackDataValue.beast = srcAct.getInfo();
							}
						}
					}
				}
			}			
			return isStop;
		}
		
		/**
		 * 展开当前回合的Action
		 */
		//override public function openActionMains():Array
		//{
			//var arr:Array = [];
			//arr.push(new ActionBase('HeroFighting ' + this.speed));
			//this.active = false;
			//return arr;
		//}
	}

}