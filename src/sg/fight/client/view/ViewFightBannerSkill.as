package sg.fight.client.view 
{
	import laya.display.Animation;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightSkillUI;
	/**
	 * 战斗中弹出的英雄技，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightBannerSkill extends fightSkillUI
	{
		///英雄id
		public var id:String;
		///技能名
		public var info:String;
		///基础翻转
		public var isFlip:Boolean;
		///品质 白绿蓝紫金红
		public var colorType:int;
		///停留时间毫秒
		public var time:int;
		///是否燃火
		public var isBurn:Boolean;
		
		public function ViewFightBannerSkill(id:String, info:String, isFlip:Boolean, colorType:int, time:int, isBurn:Boolean) 
		{
			this.id = id;
			this.info = info;
			this.isFlip = isFlip;
			this.colorType = colorType;
			this.isBurn = isBurn;
			this.time = time;
			
			this.initUI();
		}
		private function initUI():void
		{
			//this.label.text = Tools.getMsgById(this.info, null, false);
			Tools.textFitFontSize2(this.label, Tools.getMsgById(this.info, null, false));
			if(this.id)
				this.heroIcon.setHeroIcon(this.id);
			else{
				//没有头像，居中显示
				this.label.x = 0;
				this.label.width += 320;
				this.heroIcon.visible = false;
			}

			this.alpha = 0.2;
			//this.scaleX = 1.5;
			//this.scaleY = 1.5;
			this.y = Laya.stage.height * 0.15 + 80;
			var tempX:int = 20;
			if (this.isFlip){
				this.heroIcon.scaleX *= -1;
				this.heroIcon.x = -this.heroIcon.x;
				this.label.x *= -1;
				this.x = Laya.stage.width - ConfigFightView.BANNER_SKILL_X;
				tempX *= -1;
			}
			else
			{
				this.x = ConfigFightView.BANNER_SKILL_X;
			}
			
			
			if(this.isBurn){
				//加上动画
				var ani:Animation = FightLoad.loadAnimation('skillFire');
				ani.y = 39;
				this.addChildAt(ani, 1);
			}
			
			var tweenTime:int = 500;
			//var time:int = 2500;
			//FightTime.tweenTo(this, {alpha: 1, scaleX:1, scaleY:1}, time * 0.15, Ease.backOut);
			//FightTime.tweenTo(this, {alpha: 0, scaleX:1.2, scaleY:1.2}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), time * 0.85);
			//FightTime.tweenTo(this, {alpha: 0, scaleX:1.2, scaleY:1.2}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), time*0.85);
			
			FightTime.tweenTo(this, {alpha: 1}, tweenTime * 0.75, Ease.sineOut);
			FightTime.tweenTo(this, {x: this.x + tempX * 2}, tweenTime, Ease.backOut);
			
			//FightTime.tweenTo(this, {scaleX:1.1, scaleY:1.1}, time * 0.3, Ease.sineOut, null, time * 0.1);
			//FightTime.tweenTo(this, {scaleX:1, scaleY:1}, time * 0.3, Ease.sineIn, null, time * 0.4);
			
			FightTime.tweenTo(this, {alpha: 0,x: this.x - tempX}, tweenTime, Ease.sineIn, Handler.create(this, this.clear), this.time);
			
			
			if (ConfigApp.isPC){
				this.scaleX *= 1.2;
				this.scaleY *= 1.2;
			}
			//修改技能颜色
			EffectManager.changeSprColor(this.image, this.colorType);
		}
		
		override public function clear():void
		{
			this.removeSelf();
			Tools.destroy(this);
		}
	}

}