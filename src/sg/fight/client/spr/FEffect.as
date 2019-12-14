package sg.fight.client.spr 
{
	import laya.display.Animation;
	import laya.events.Event;
	import sg.fight.client.view.FightSceneBase;
	/**
	 * 战斗中的特效动画(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FEffect extends FAnimation
	{
		///延迟弹出
		public var delay:int;
		///旋转角度
		public var rota:Number;
		
		public function FEffect(scene:FightSceneBase,id:String, x:Number, y:Number, z:Number, isFlip:Boolean, rota:Number = 0, baseScale:Number = 1, baseAlpha:Number = 1, delay:int = 0, isAdd:Boolean = false)
		{
			this.delay = delay;
			this.rota = rota;
			super(scene, id, x, y, z, isFlip, baseScale, baseAlpha, true);
			
			if (isAdd){
				this.spr.blendMode = 'lighter';
			}
		}
		
		
		override public function init():void
		{
			super.init();
			
			if(this.delay == 0){
				this.bang();
			}else{
				this.spr.alpha = 0;
				this.ani.stop();
				this.delayTo(this.delay, this, this.bang);
			}
		}
		
		/**
		 * 爆发一次就消亡
		 */
		public function bang():void
		{
			if (!this.spr || this.spr.destroyed)
				return;
			this.spr.alpha = 1;
			this.spr.rotation = this.rota;
			var ani:Animation = this.ani;
			ani.play(0, false);
			ani.once(Event.COMPLETE, this, this.clear);
		}
	}

}