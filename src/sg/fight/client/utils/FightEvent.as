package sg.fight.client.utils 
{
	import laya.events.EventDispatcher;
	/**
	 * 客户端战斗的事件
	 * @author zhuda
	 */
	public class FightEvent 
	{
		///清理了战斗时间控制器
		public static const FIGHT_TIME_CLEAR:String = 'FightTimeClear';
		
		public static var ED:EventDispatcher = new EventDispatcher;
	
		
		public function FightEvent() 
		{
			
		}
		
	}

}