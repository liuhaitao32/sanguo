package sg.fight.logic.unit 
{
	import sg.fight.logic.BuffManager;
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.utils.FightPrint;
	import sg.fight.logic.utils.FightUtils;
	/**
	 * 护盾状态
	 * @author zhuda
	 */
	public class ShieldLogic extends LogicBase
	{
		///绑定的对象
		public var buffManager:BuffManager;
		///绑定的buff, 护盾移除时需要移除buff，反之也是
		public var buff:BuffLogic;
		///必须指定id 同id会叠加或覆盖
		public var id:String;
		///护盾值额外获得最大兵力的部分比例千分点
		public var hpmRate:int;
		///当前护盾值，1:1抵挡伤亡，初始化为护盾固定值
		public var value:int;
		///抵消千分点，如果小于0表示为抵消次数类
		public var bearPoint:int;
		
		///排序优先级，越优先的护盾越先承受伤害
		public var priority:int;
		
		public function ShieldLogic(id:String, data:*, buffManager:BuffManager, buff:BuffLogic, priority:int) 
		{
			this.id = id;
			this.buffManager = buffManager;
			this.buff = buff;
			this.buff.shield = this;
			this.priority = priority;
			super(data);
			
			var armyLogic:ArmyLogic = buffManager.armyLogic;
			if(armyLogic){
				if (this.hpmRate){
					this.value += armyLogic.hpm * FightUtils.pointToPer(this.hpmRate);
				}
				
				if (this.bearPoint > 0){
					//非抵消次数类，处理elementShield对应全部护盾效果
					var elementRate:Number = armyLogic.others['elementShield'];
					if (elementRate){
						this.value = Math.max(1,this.value * FightUtils.pointToRate(elementRate));
					}
				}
			}
			this.value = Math.ceil(this.value);
		}
		
		/**
		 * 承受伤害，尝试用护盾抵挡，返回溢出伤害
		 */
		public function bearDamage(dmgIn:int,tgtData:Object):int
		{
			var bearValue:int = 0;
			if (this.bearPoint < 0){
				//抵御抵消次数类
				this.value--;
				bearValue = dmgIn;
				if (FightLogic.canPrint)
				{
					FightLogic.print('      ' + this.buff.buffManager.unitFighting.getName() + ' 的 ' + this.buff.getName() + ' 完全抵御了伤害，还可抵御 ' + this.value +' 次', null, FightPrint.getPrintColor(this.buff.buffManager.unitFighting.logic.teamIndex));
				}
			}
			else{
				bearValue = Math.ceil(dmgIn * FightUtils.pointToPer(this.bearPoint));
				if (bearValue > this.value){
					bearValue = this.value;
				}
				this.value-= bearValue;
				//护盾帮忙承受了伤害
				if (FightLogic.canPrint)
				{
					FightLogic.print('      ' + this.buff.buffManager.unitFighting.getName() + ' 的 ' + this.buff.getName() + ' 替代承受战损' + bearValue +' 护盾值 ' + (this.value+bearValue) + ' → ' + this.value , null, FightPrint.getPrintColor(this.buff.buffManager.unitFighting.logic.teamIndex));
				}
			}
			
			if (this.value <= 0){
				this.buffManager.removeBuff(this.buff,tgtData);
			}
			return dmgIn - bearValue;
		}
		
		/**
		 * 移除buff，还原属性
		 */
		override public function clear() :void
		{
			if (this.isCleared)
				return;
			this.buff = null;
			this.buffManager = null;
			super.clear();
		}
	}

}