package sg.fight.client.spr
{
	import laya.display.Animation;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightShogunUI;
	
	/**
	 * 战斗中弹出的幕府文字，包含缓动和消失(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FShogun extends FInfoBase
	{
		///颜色
		public var strokeColor:String;
		///延迟弹出
		public var delay:int;
		///持续时间
		public var duration:int;
		///值文本
		public var valueStr:String;
		
		public function FShogun(scene:FightSceneBase, id:String, valueStr:String, x:Number, y:Number, z:Number, strokeColor:String, delay:int = 0, duration:int = 1000)
		{
			this.strokeColor = strokeColor;
			this.delay = delay;
			this.duration = duration;
			this.valueStr = valueStr;
			super(scene, id, x, y, z, false, 1, 1);
		}
		
		override public function init():void
		{
			this.delayTo(this.delay, this, this.show);
		}
		
		public function show():void
		{
			var info:String = this.id;
			var fightShogun:fightShogunUI = new fightShogunUI();
			//Tools.textFitFontSize(fightShogun.label, info, 40);
			//fightShogun.label.text = info;
			//fightShogun.label.strokeColor = this.strokeColor;
			fightShogun.alpha = 0.2;
			
			if (this.valueStr){
				fightShogun.label.scaleX *= 0.8;
				fightShogun.label.scaleY *= 0.8;
				fightShogun.label.alpha = 0.9;
				fightShogun.tNum.text = this.valueStr;
				fightShogun.tNum.strokeColor = this.strokeColor;
				fightShogun.label.strokeColor = '#555555';
				Tools.textFitFontSize(fightShogun.label, info, 60);
			}
			else{
				fightShogun.label.strokeColor = this.strokeColor;
				fightShogun.tNum.visible = false;
				Tools.textFitFontSize(fightShogun.label, info, 140);
			}
			
			this.spr = fightShogun;
			
			var time:int = this.duration;
			var time2:int = 1500;
			
			//等待，再向上消失
			this.tweenTo(fightShogun, {alpha: 1}, time * 0.1, Ease.sineOut);
			if (this.valueStr)
			{
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z - 10}, time2 * 0.3, Ease.sineOut);
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 5}, time2 * 0.2, Ease.sineIn, null, time);
			}else{
				fightShogun.scale(2, 2);
				this.tweenTo(fightShogun, {scaleX:1, scaleY:1}, time2 * 0.4, Ease.sineOut);
			}
			this.tweenTo(fightShogun, {alpha: 0}, time2 * 0.2, null, Handler.create(this, this.clear), time);
			
			this.addInfoToScene();
		}
		
		public function get view():fightShogunUI
		{
			return this.spr as fightShogunUI;
		}
	
	}

}