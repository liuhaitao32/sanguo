package sg.fight.client.spr 
{
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.fight.client.unit.ClientHero;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.client.utils.FightTime;
	import sg.utils.Tools;
	import ui.battle.fightSpeakUI;
	/**
	 * 战斗中的说话(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FSpeak extends FInfoBase
	{
		///文字描述
		public var info:String;
		///延迟弹出
		//public var delay:int;
		
		public function FSpeak(hero:ClientHero, info:String) 
		{
			this.info = info;
			//this.delay = delay;
			
			super(hero.getScene(), hero.id, hero.getPosX(), 0, 40, hero.isFlip, 1, 1);
		}
		override public function init():void
		{
			this.show();
			//this.delayTo(this.delay, this, this.show);
		}
		
		private function show():void
		{
			//var info:String = this.id;
			var fightSpeak:fightSpeakUI = new fightSpeakUI();
			//fightSpeak.tSpeak.text = this.info;
			Tools.textFitFontSize2(fightSpeak.tSpeak, this.info);
			
			this.spr = fightSpeak;
			fightSpeak.imgBg.x += 10;
			fightSpeak.tSpeak.x += 10;

			if (this.isFlip){
				fightSpeak.imgBg.scaleX *= -1;
				fightSpeak.imgBg.x *= -1;
				fightSpeak.tSpeak.x *= -1;
			}

			var time:int = ConfigServer.effect.fightSpeakTime;
			fightSpeak.alpha = 0.5;
			this._baseScale = 0.1;
			fightSpeak.scale(0.1, 0.1);
			FightTime.tweenTo(fightSpeak, {alpha: 1}, time * 0.1, Ease.sineOut);
			FightTime.tweenTo(fightSpeak, {scaleX: 1,scaleY: 1}, time * 0.2, Ease.backOut);
			FightTime.tweenTo(fightSpeak, {alpha: 0}, time * 0.2, null, Handler.create(this, this.clear), time);
			this.addInfoToScene();
		}
		
		public function get view():fightSpeakUI
		{
			return this.spr as fightSpeakUI;
		}
		
		//override public function clear():void
		//{
			//this.removeSelf();
			//Tools.destroy(this);
		//}
	}

}