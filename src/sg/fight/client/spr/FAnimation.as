package sg.fight.client.spr
{
	import laya.display.Animation;
	import sg.fight.client.utils.FightTime;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.EffectManager;
	
	/**
	 * 战斗中的动画(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FAnimation extends FSpriteBase
	{
		public function FAnimation(scene:FightSceneBase, id:String, x:Number, y:Number, z:Number, isFlip:Boolean, baseScale:Number = 1, baseAlpha:Number = 1, forcedRender = false)
		{
			super(scene, id, x, y, z, isFlip, baseScale, baseAlpha, forcedRender);
		}
		
		public function get ani():Animation
		{
			return this.spr as Animation;
		}
		
		override public function init():void
		{
			var animation:Animation = new Animation();
			animation.timer = FightTime.timer;
			EffectManager.getAnimation(this.res, "", 0, animation);
			this.spr = animation;
			this.addToScene();
		}
	
	}

}