package sg.fight.client.view 
{
	import laya.display.Animation;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.utils.FightTime;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightBeastSkillUI;
	/**
	 * 战斗中弹出的兽灵，包含缓动和消失
	 * @author zhuda
	 */
	public class ViewFightBeastSkill extends fightBeastSkillUI
	{
		///兽灵套
		public var id:String;
		///兽灵技能描述
		public var info:String;
		///兽灵技能扩展描述
		public var infoExtra:String;
		///兽灵目标描述
		public var infoTgt:String;
		///基础翻转
		public var isFlip:Boolean;
		///品质 0白1绿2蓝3紫4金5红
		public var colorType:int;
		///停留时间毫秒
		public var time:int;
		///是否燃火
		public var index:int;
		///是否燃火
		//public var isBurn:Boolean;
		
		public function ViewFightBeastSkill(id:String, info:String, infoExtra:String, infoTgt:String, isFlip:Boolean, colorType:int, time:int, index:int) 
		{
			this.id = id;
			this.info = info;
			this.infoExtra = infoExtra;
			this.infoTgt = infoTgt;
			this.isFlip = isFlip;
			this.colorType = colorType;
			this.index = index;
			this.time = time;
			
			this.initUI();
		}
		private function initUI():void
		{
			//this.label.text = Tools.getMsgById(this.info, null, false);
			if (Tools.hasMsgById(this.info + 'Extra')){
				var infoExtraName:String = Tools.getMsgById(this.infoExtra, null, false);
				Tools.textFitFontSize(this.extra, Tools.getMsgById(this.info + 'Extra', [infoExtraName, this.infoTgt], false));
			}
			else{
				//没有额外说明
				this.title.y += 10;
				this.extra.visible = false;
			}
			Tools.textFitFontSize(this.title, Tools.getMsgById(this.info, null, false));
			this.icon.skin = AssetsManager.getAssetLater('beastType_' + this.id + AssetsManager.PNG_EXT);

			this.alpha = 0;
			var tempScale:Number = 0.8 - this.index*0.08;
			if (ConfigApp.isPC){
				tempScale *= 1.2;
			}
			this.y = Laya.stage.height * 0.15 + 100 + (this.index * 45* (tempScale+1)/2);
			this.scale(tempScale, tempScale);
			var baseX:Number = ConfigFightView.BANNER_BEAST_SKILL_X ;// - 70 * (1 - tempScale);
			
			var tempX:int = 5;
			if (this.isFlip){
				this.icon.scaleX *= -1;
				this.icon.x *= -1;
				this.title.x *= -1;
				this.extra.x *= -1;
				this.image.x *= -1;
				this.x = Laya.stage.width - baseX;
				tempX *= -1;
			}
			else
			{
				this.x = baseX;
			}
			
			
			
			var tweenTime:int = 500;
			var delayTime:int = 200 * this.index;
			
			FightTime.tweenTo(this, {alpha: 1}, tweenTime * 0.75, Ease.sineOut,null,delayTime);
			FightTime.tweenTo(this, {x: this.x + tempX * 2}, tweenTime, Ease.backOut,null,delayTime);

			FightTime.tweenTo(this, {alpha: 0,x: this.x - tempX}, tweenTime, Ease.sineIn, Handler.create(this, this.clear), this.time+delayTime);

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