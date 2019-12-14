package sg.fight.client.view 
{
	import laya.display.Animation;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.utils.FightTime;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightBashUI;
	/**
	 * 战斗中弹出的猛击板子，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightBash extends fightBashUI
	{
		///基础翻转
		public var isFlip:Boolean;
		public function ViewFightBash(isFlip:Boolean) 
		{
			this.isFlip = isFlip;
			this.initUI();
		}
		private function initUI():void
		{
			var tempX:int = 20;
			if (this.isFlip){
				tempX *= -1;
				this.x = Laya.stage.width - ConfigFightView.BASH_X - tempX;
				this.imgWord.x = 30;
				this.imgBg.scaleX = -1;
			}
			else
			{
				this.imgWord.x = -30;
				this.x = ConfigFightView.BASH_X - tempX;
			}
			
			var time:int = 2500;
			this.y = Laya.stage.height * 0.15 + 80;
			this.alpha = 0;
			
			FightTime.tweenTo(this, {alpha: 1}, time * 0.15, Ease.sineOut);
			FightTime.tweenTo(this, {x: this.x + tempX}, time * 0.2, Ease.backOut);
			FightTime.tweenTo(this, {alpha: 0, x: this.x - tempX}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), time * 0.8);
			
			if (ConfigApp.isPC){
				this.scaleX *= 1.2;
				this.scaleY *= 1.2;
			}
		}
		
		override public function clear():void
		{
			this.removeSelf();
			Tools.destroy(this);
		}
	}

}