package sg.fight.logic.unit 
{
	import sg.fight.logic.FightLogic;
	import sg.fight.logic.unit.LogicBase;
	import sg.fight.logic.utils.FightUtils;
	/**
	 * 战斗中副将
	 * @author zhuda
	 */
	public class AdjutantLogic extends AttackerLogic
	{
		///以下属性不直接在data中
		public var id:String;
		
		public function getAdjutantIndex():int
		{
			return this.armyIndex - 3;
		}
		
		
		public function AdjutantLogic(data:*,troopLogic:TroopLogic,adjutantIndex:int) 
		{
			var dataArr:Array = data as Array;
			this.id = dataArr[0];
			
			super(data, troopLogic, 3 + adjutantIndex);
			//需要在此将宝物评分转为伤害加成
			var equipScore:int = dataArr.length > 4?dataArr[4]:0;
			this.dmgFinal = FightUtils.getAdjutantEquipDmgFinal(equipScore);
		}

		
		/**
		 * 战斗开始，重置
		 */
		override public function resetStart(fightLogic:FightLogic):void
		{
			super.resetStart(fightLogic);
		}
		/**
		 * 战斗结束，重置该单位的所有数据为初始data，但不重置hp
		 */
		override public function resetEnd():void
		{
			//this.setData(this.data);
		}
	}

}