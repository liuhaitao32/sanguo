package sg.fight.logic.action
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.utils.FightUtils;
	import sg.utils.Tools;
	
	/**
	 * 捆绑行动（只能绑定到攻击行动中）
	 * @author zhuda
	 */
	public class BindingAction extends ActionBase
	{
		///绑定效果对象
		public var binding:Object;
		
		public function BindingAction(unitFighting:UnitFighting, data:Object)
		{
			super(unitFighting, data);
		}

		
		/**
		 * 将自己的绑定效果附加到原攻击行动上
		 */
		public function bindingAttackData(atkObj:Object):void
		{
			var boolShow:Boolean = true;
			for (var key:String in this.binding)
			{
				if (key == 'buff'){
					var buffObj:Object = this.binding.buff;
					for (var buff:String in buffObj)
					{
						FightUtils.changeObjByPath(atkObj.buff, buff, buffObj[buff]);
					}
				}
				else if (key == 'resRealRate'){
					//当我军即将按比例损失兵力时，减免效果
					if (atkObj.loss){
						atkObj.loss = Math.max(0, Math.ceil(atkObj.loss * (1 - FightUtils.pointToPer(this.binding.resRealRate))));
					}
					else{
						boolShow = false;
					}
				}
				else
				{
					FightUtils.changeObjByPath(atkObj, key, this.binding[key]);
				}
			}
			if(boolShow){
				//对绑定类的word特殊处理
				this.mergeInfos(atkObj);
				//英雄技，或者普攻才合并攻击特效
				if(atkObj.src==2 || atkObj.nonSkill){
					this.mergeEffects(atkObj);
				}
			}
			
			if (FightLogic.canPrint){
				var priorityStr:String = '  优先级:'+this.data.priority;
				FightLogic.print('   ' + this.unitFighting.getName() + ' 触发「' + this.getPrintInfo() + '」'+priorityStr, null , this.getPrintColor());
			}
			//this.printAction();
		}
		
		/**
		 * 将自己的绑定效果附加到防御行动上，hitObj.dmg已经是小数含义为伤害系数，hitObj.dmgReal，resRealRate都可能为小数
		 */
		public function bindingBeHitData(hitObj:Object):void
		{
			var boolShow:Boolean = true;
			var resPer:Number;
			for (var key:String in this.binding)
			{
				//绑定时已按优先级排序，避免多重减免取整bug
				if (key == 'res'){
					//叠加减免伤害，这里的减免是1-效果率，且连真实伤害都能减免
					resPer = Math.max(0, 1 - FightUtils.pointToPer(this.binding.res));
					if (hitObj.dmg)
						hitObj.dmg *= resPer;
					if (hitObj.dmgReal)
						hitObj.dmgReal *= resPer;
				}
				else if (key == 'buff'){
					var buffObj:Object = this.binding.buff;
					for (var buff:String in buffObj)
					{
						FightUtils.changeObjByPath(hitObj.buff, buff, buffObj[buff]);
					}
				}
				else if (key == 'resRealRate'){
					//当我军即将按比例损失兵力时，减免效果
					if (hitObj.dmgRealRate || hitObj.dmgRealMax){
						resPer = Math.max(0, 1 - FightUtils.pointToPer(this.binding.resRealRate));
						if (hitObj.dmgRealRate) hitObj.dmgRealRate *= resPer;
						if (hitObj.dmgRealMax) hitObj.dmgRealMax *= resPer;
					}
					else {
						boolShow = false;
					}
				}
				else{
					FightUtils.changeObjByPath(hitObj, key, this.binding[key]);
				}
			}
			if(boolShow){
				this.mergeInfos(hitObj);
				this.mergeEffects(hitObj);
				
				if (FightLogic.canPrint){
					var priorityStr:String = '  优先级:'+this.data.priority;
					FightLogic.print('     ' + this.unitFighting.getName() + ' 触发「' + this.getPrintInfo() + '」'+priorityStr, null , this.getPrintColor());
				}
			}
			//this.printAction();
		}
	}

}