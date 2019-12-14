package sg.fight.logic.unit
{
	
	/**
	 * 战斗单元的基类
	 * @author zhuda
	 */
	public class LogicBase
	{
		public var data:*;
		public var isCleared:Boolean;
		
		public function get classType():int
		{
			throw new Error(this + '没有复写此方法！');
			return -1;
		}
		
		public function get teamIndex():int
		{
			throw new Error(this + '没有复写此方法！');
			return -1;
		}
		
		public function get enemyTeamIndex():int
		{
			return 1 - teamIndex;
		}
		
		public function getTroopLogic():TroopLogic
		{
			throw new Error(this + '没有复写此方法！');
			return null;
		}
		
		public function LogicBase(data:*)
		{
			this.isCleared = false;
			if(data)
				this.setData(data);
		}
		
		public function setData(data:*):void
		{
			this.data = data;
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				}
			}
		}
		
		public function getData():*
		{
			return null;
		}
		
		public function clear():void
		{
			this.data = null;
			this.isCleared = true;
		}
	}

}