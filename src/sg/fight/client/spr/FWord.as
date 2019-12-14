package sg.fight.client.spr
{
	import laya.display.Animation;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.utils.FightLoad;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.EffectManager;
	import sg.utils.Tools;
	import ui.battle.fightWordUI;
	
	/**
	 * 战斗中弹出的文字，包含缓动和消失(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FWord extends FInfoBase
	{
		///品质 白绿蓝紫橙红
		public var colorType:int;
		///是否燃火
		public var isBurn:Boolean;
		///延迟弹出
		public var delay:int;
		
		public function FWord(scene:FightSceneBase, id:String, x:Number, y:Number, z:Number, isFlip:Boolean, colorType:int, isBurn:Boolean, delay:int = 0)
		{
			this.colorType = colorType;
			this.isBurn = isBurn;
			this.delay = delay;
			
			//防止后排技能看不到，提到靠前的位置
			var posX:Number = x + (isFlip ? -1 : 1) * 10;
			
			super(scene, id, posX, y, z, isFlip, 1, 1);
		}
		
		override public function init():void
		{
			this.delayTo(this.delay, this, this.show);
		}
		
		public function show():void
		{
			var info:String = Tools.getMsgById(this.id,null,false);
			var fightWord:fightWordUI = new fightWordUI();
			Tools.textFitFontSize2(fightWord.label, info);
			//fightWord.label.text = info;
			fightWord.alpha = 0.2;
			
			this.spr = fightWord;
			
			var time:int = 2000;
			var tempX:int = 40;
			this.x += this.isFlip ? -tempX : tempX;
			//this.tweenTo(this.spr, {alpha: 0}, time * 0.2, Ease.sineIn, Handler.create(this, this.clear), time);
			
			if(this.isBurn){
				//加上动画
				var ani:Animation = FightLoad.loadAnimation('skillFire');
				ani.scale(0.2, 0.3);
				ani.y = 17;
				this.spr.addChildAt(ani, 1);
			}
			
			//先向后颤抖，等待，再向上消失
			this.tweenTo(fightWord, {alpha: 1}, time * 0.1, Ease.sineOut);
			this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.x + (this.isFlip ? tempX : -tempX)}, time * 0.2, Ease.backOut);
			this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 20}, time * 0.2, Ease.sineIn, null, time);
			this.tweenTo(fightWord, {alpha: 0}, time * 0.2, null, Handler.create(this, this.clear), time);
			
			this.addInfoToScene();
			
			//修改技能颜色
			EffectManager.changeSprColor(fightWord.image, this.colorType);
		}
		
		public function get view():fightWordUI
		{
			return this.spr as fightWordUI;
		}
	
	}

}