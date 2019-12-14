package sg.fight.client.view
{
	import sg.utils.Tools;
	import ui.battle.fightRoundUI;
	
	/**
	 * 战斗中显示回合数的UI
	 * @author zhuda
	 */
	public class ViewFightRound extends fightRoundUI
	{
		public function ViewFightRound()
		{
			this.visible = false;
			this.scale(1.6, 1.6);
		}
		
		//public function init():void
		//{
			//this.alpha = 0;
		//}
		
		/**
		 * 刷新数据，显示回合信息
		 */
		public function updateData(index:int):void
		{
			if (index == 0)
			{
				this.roundName.text = Tools.getMsgById('round_info_0');
			}
			else if (index <= 2)
			{
				this.roundName.text = Tools.getMsgById('round_info_far');
			}
			else
			{
				this.roundName.text = Tools.getMsgById('round_info_near');
				index -= 2;
			}
			this.roundIndex.text = index.toString();
			
			this.visible = true;
		}
	
	}

}