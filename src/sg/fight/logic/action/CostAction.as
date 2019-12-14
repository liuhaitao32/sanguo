package sg.fight.logic.action 
{
	import sg.fight.logic.fighting.UnitFighting;
	import sg.fight.logic.utils.FightUtils;
	/**
	 * 消耗能量的动作
	 * @author zhuda
	 */
	public class CostAction extends AttackAction
	{
		///每次释放消耗能量的类型
		public var costKey:String;
		///每次释放消耗能量
		public var cost:int;
		///多倍使用时 消耗充能
		public var costMult:int;
		
		///多倍消耗的效果(如果没有此键则不可多倍施法)
		public var mult:Object;
		///一次使用的最大倍数
		public var multMax:int;
		
		///临时倍率
		//public var tempMult:int;
		
		public function CostAction(unitFighting:UnitFighting, data:Object)
		{
			super(unitFighting, data);
			if (!data.costMult)
				this.costMult = this.cost;
		}
		
		/**
		 * 检查能否触发
		 * @param	expend 在检查前消耗次数
		 * @param	srcAction 原行动（只有目标是绑定型行动才传入该参数）
		 * @param	ignoreBinding 是否忽略一般攻击性后续绑定行动（特定绑定不会被忽略）
		 * @return  返回是否可用
		 */
		override protected function checkCanUseFun(srcAction:AttackAction = null):Boolean
		{
			if (this.getTroopFighting().getEnergy(this.costKey) >= this.cost){
				return super.checkCanUseFun(srcAction);
			}
			return false;
		}
		
		
		/**
		 * 克隆多倍数据准备攻击，并消耗对应能量标记（已阵亡士兵）
		 */
		override protected function cloneMultData(srcData:Object):Object
		{
			var atkObj:Object = FightUtils.clone(this.data);
			var multNum:int = this.getTroopFighting().useEnergy(this.cost, this.costMult, this.multMax, this.costKey, srcData);
			multNum --;
			if (multNum > 0){
				var multObj:Object = this.mult;
				if (multObj){
					if(multNum>1){
						multObj = FightUtils.clone(multObj);
						FightUtils.multObject(multObj, multNum);
					}
					FightUtils.mergeObj(atkObj, multObj);
				}
				
			}
			return atkObj;
		}
	}

}