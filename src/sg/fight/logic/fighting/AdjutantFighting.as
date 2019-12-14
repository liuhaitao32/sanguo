package sg.fight.logic.fighting 
{
	import sg.fight.logic.unit.AdjutantLogic;
	/**
	 * 战斗中独立行动的副将，在双方主将后出手
	 * @author zhuda
	 */
	public class AdjutantFighting  extends UnitFighting
	{
		

		public function AdjutantFighting(troopFighting:TroopFighting,logic:AdjutantLogic) 
		{
			super(troopFighting, logic);
			this.alive = true;
		}
		
		public function getAdjutantLogic():AdjutantLogic
		{
			return this.logic as AdjutantLogic;
		}
	}

}