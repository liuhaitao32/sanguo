package sg.fight.client.spr
{
	import laya.ui.Box;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.cfg.ConfigColor;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	
	/**
	 * 战斗中弹出的伤害数字，包含缓动和消失(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FDamage extends FInfoBase
	{
		///伤害数字级别 01234伤害 5治疗
		public var lv:int;
		///类型 0普通 1暴击 -1格挡 3治疗
		public var type:int;
		///延迟弹出
		public var delay:int;
		
		/**
		 * 
		 * @param	scene
		 * @param	id
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	isFlip
		 * @param	type
		 * @param	delay
		 */
		public function FDamage(scene:FightSceneBase, id:String, x:Number, y:Number, z:Number, isFlip:Boolean, lv:int, type:int, delay:int = 0)
		{
			this.lv = lv;
			this.type = type;
			this.delay = delay;
			
			//防止后排受伤看不到，提到靠前的位置
			var posX:Number = x + (isFlip ? -1 : 1) * 10;
			
			super(scene, id, posX, y, z, isFlip, 1, 1);
		}
		
		override public function init():void
		{
			this.delayTo(this.delay, this, this.show);
			//FightTime.timer.once(this.delay, this, this.show);
		}
		
		/**
		 * 位图字体
		 */
		public function show():void
		{
			var info:String = this.id;
			//info = "+-123 8";
			var box:Box = new Box();
			this.spr = box;
			
			var damageText:Label = new Label();
			damageText.text = info;
			//使用位图字体
			damageText.font = AssetsManager.FIGHT_FONT;
			EffectManager.changeSprColor(damageText, this.lv, false, ConfigColor.DAMAGE_COLOR_FILTER_MATRIX);
			
			damageText.anchorX = 0.5;
			damageText.anchorY = 0.5;
			damageText.align = 'center';
			damageText.valign = 'middle';
			box.addChild(damageText);
			box.alpha = 0.2;
			
			var time:int = 2000;
			this.tweenTo(box, {alpha: 1}, time * 0.1, Ease.sineOut);
			this.tweenTo(box, {alpha: 0}, time * 0.2, null, Handler.create(this, this.clear), time);
			
			var img:Image;
			if (this.type == 1){
				//暴击图片
				img = new Image(AssetsManager.getAssetsFight('word_crit'));
			}
			else if (this.type == -1){
				//格挡图片
				img = new Image(AssetsManager.getAssetsFight('word_block'));
			}
			else{
				//trace(this.type);
			}
			if (img){
				img.anchorX = 0.5;
				img.anchorY = 0.5;
				img.y = -45;
				img.scale(1.4, 1.4);
				this.tweenTo(img, {scaleX:0.7, scaleY:0.7}, time * 0.15, Ease.backOut);
				this.tweenTo(img, {scaleX:1.4, scaleY:1.4}, time * 0.2, Ease.sineIn, null, time);
				box.addChild(img);
			}
			
			var tempX:int;
			if (this.lv == 0)
			{
				//白色小字 普通显现，向上消失
				this._baseScale = 0.8;
				tempX = 25;
				this.x += this.isFlip ? -tempX : tempX;
				this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.x + (this.isFlip ? tempX : -tempX)}, time * 0.2, Ease.backOut);
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 20}, time * 0.2, Ease.sineIn, null, time);
			}
			else if (this.lv == 1)
			{
				//白色中字 先向后颤抖，等待，再向上消失
				this._baseScale = 0.9;
				tempX = 35;
				this.x += this.isFlip ? -tempX : tempX;
				this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.x + (this.isFlip ? tempX : -tempX)}, time * 0.2, Ease.backOut);
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 20}, time * 0.2, Ease.sineIn, null, time);
			}
			else if (this.lv == 2)
			{
				//黄色中字 先向后颤抖，等待，再向上消失
				this._baseScale = 1;
				//damageText.scale(1, 1);
				tempX = 45;
				this.x += this.isFlip ? -tempX : tempX;
				damageText.rotation = this.isFlip ? 5 : -5;
				this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.x + (this.isFlip ? tempX : -tempX)}, time * 0.2, Ease.backOut);
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 20}, time * 0.2, Ease.sineIn, null, time);
			}
			else if (this.lv == 3)
			{
				//橙色大字 从大缩小，等待，再放大消失
				this._baseScale = 1.6;
				this.spr.scale(1.6, 1.6);
				damageText.rotation = this.isFlip ? 10 : -10;
				this.tweenTo(this.spr, {scaleX:1.1, scaleY:1.1}, time * 0.15, Ease.backOut);
				this.tweenTo(this.spr, {scaleX:1.6, scaleY:1.6}, time * 0.2, Ease.sineIn,null,time);
			}
			else if (this.lv == 4)
			{
				//红色大字 从大缩小，等待，再放大消失
				this._baseScale = 2;
				this.spr.scale(2, 2);
				damageText.rotation = this.isFlip ? 15 : -15;
				this.tweenTo(this.spr, {scaleX:1.2, scaleY:1.2}, time * 0.15, Ease.backOut);
				this.tweenTo(this.spr, {scaleX:2, scaleY:2}, time * 0.2, Ease.sineIn, null, time);
			}
			else
			{
				//中字 普通显现，向上消失
				this._baseScale = 0.9;
				tempX = 35;
				this.x += this.isFlip ? -tempX : tempX;
				this.tweenTo(this, {update: new Handler(this, this.updatePos), x: this.x + (this.isFlip ? tempX : -tempX)}, time * 0.2, Ease.backOut);
				this.tweenTo(this, {update: new Handler(this, this.updatePos), z: this.z + 20}, time * 0.2, Ease.sineIn, null, time);
			}

			this.addInfoToScene();
		}
		
		
		//public function get label():Label
		//{
			//return this.spr as Label;
		//}
	
	}

}