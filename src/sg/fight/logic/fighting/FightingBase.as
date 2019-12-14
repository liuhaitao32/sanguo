package sg.fight.logic.fighting 
{
	/**
	 * ...
	 * @author zhuda
	 */
	public class FightingBase 
	{
		public var isCleared:Boolean;
		
		public function FightingBase() 
		{
			
		}
		
		public function clear():void
		{
			this.isCleared = true;
		}
	}

}