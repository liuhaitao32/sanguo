package sg.fight.logic.unit 
{
	/**
	 * 战斗中前后军（其中一队）
	 * @author zhuda
	 */
	public class ArmyLogic extends UnitLogic
	{
		///士兵资源
		public var resId:String;
		
		///兵种0步兵1骑兵2弓兵3方士
		public var type:int;
		///兵阶
		public var rank:int;
		
		///开战初始兵力
		public var initHp:int;
		
		
		public function ArmyLogic(data:*,troopLogic:TroopLogic,armyIndex:int,initHp:int) 
		{
			super(data,troopLogic,armyIndex,initHp);
		}

		
		/**
		 * 战斗开始，重置
		 */
		//override public function resetStart():void
		//{
		//}
		/**
		 * 战斗结束，重置该单位的所有数据为初始data，但不重置hp（只有客户端或客户端模拟的服务端战斗才有）
		 */
		override public function resetEnd():void
		{
			var endHp:int = this.hp;
			super.resetEnd();
			this.hp = endHp;
		}
		
		override public function setData(data:*):void
		{
			//if (data.hp == null)
			//{
				//TestFight.traceStr(id + ' 军队hp == null ');
			//}
			super.setData(data);
		}
		override public function getData():*
		{
			var reData:Object = super.getData();
			
			reData.type = this.type;
			reData.rank = this.rank;
			
			return reData;
		}
	}

}