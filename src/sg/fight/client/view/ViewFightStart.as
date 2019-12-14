package sg.fight.client.view 
{
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.utils.FightTime;
	import sg.utils.Tools;
	import ui.battle.fightStartUI;
	/**
	 * ...
	 * @author zhuda
	 */
	public class ViewFightStart extends fightStartUI
	{
		
		public function ViewFightStart() 
		{
			this.labelInfo.scale(3,3);
			FightTime.tweenTo(this.labelInfo, {scaleX:1,scaleY:1}, 600,Ease.backOut);
			
			//放大再缩小
			this.alpha = 0.5;
			this.scale(0.3,0.3);
			FightTime.tweenTo(this, {alpha:1, scaleX:1, scaleY:1}, 200, Ease.sineOut);
			FightTime.tweenTo(this, {scaleX:0.4,scaleY:0.4}, 300,Ease.sineIn,null,1000);
			FightTime.tweenTo(this, {alpha:0}, 200,null,Handler.create(null,Tools.destroy,[this]),1100);
		}

	}

}