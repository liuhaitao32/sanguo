package sg.fight.client.view 
{
	import sg.fight.client.utils.FightTime;
	import sg.utils.Tools;
	import ui.battle.fightReadyUI;
	/**
	 * ...
	 * @author zhuda
	 */
	public class ViewFightReady extends fightReadyUI
	{
		
		
		public function ViewFightReady(time:int) 
		{
			this.labelInfo.text = Tools.getMsgById('fight_ready');
			
			this.update(time);
		}
		public function update(time:int) :void
		{
			this.labelTime.text = (Math.ceil(time / 1000)).toString();
			this.show();
		}
		public function show() :void
		{
			if (this.alpha < 1)
			{
				FightTime.tweenTo(this, {alpha:1}, 400);
			}
		}
		public function hide() :void
		{
			if (this.alpha > 0)
			{
				FightTime.tweenTo(this, {alpha:0}, 400);
			}
		}
	}

}