package sg.fight.logic.action
{
	import sg.fight.logic.fighting.TroopFighting;
	import sg.fight.logic.fighting.UnitFighting;
	
	/**
	 * 有目标的行动
	 * @author zhuda
	 */
	public class TargetAction extends ActionBase
	{
		///发出源死亡时仍可发动
		public var srcFree:int;
		///目标数组
		public var tgt:Array;

		///本次行动不能触发攻受Bfr
		public var noBfr:int;
		///本次行动不能触发攻受Aft
		public var noAft:int;
		

		
		
		public function TargetAction(unitFighting:UnitFighting, data:Object)
		{
			super(unitFighting, data);
		}
		
		/**
		 * 是否目标对己方
		 */
		public function isTargetSelf():Boolean
		{
			return tgt && tgt[0] == 0;
		}
		


	
		//override public function doAction():void
		//{
		//FightUtils.traceStr('  执行了TargetAction  ' + this.unitFighting.getName());
		//}
	
		//override public function getPlaybackData():*
		//{
		//return null;
		//}
	
	}

}