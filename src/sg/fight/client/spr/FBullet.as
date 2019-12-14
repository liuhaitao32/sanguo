package sg.fight.client.spr
{
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Utils;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.view.FightSceneBase;
	
	/**
	 * 战斗中的子弹特效(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FBullet extends FAnimation
	{
		public function FBullet(scene:FightSceneBase, id:String, x:Number, y:Number, z:Number, isFlip:Boolean, baseScale:Number = 1, baseAlpha:Number = 1, isAdd:Boolean = false)
		{
			super(scene, id, x, y, z, isFlip, baseScale, baseAlpha, true);
			
			if (isAdd){
				this.spr.blendMode = 'lighter';
			}
		}
		
		override public function init():void
		{
			super.init();
		}
		
		/**
		 * 执行飞行
		 */
		public function doFlight(aimX:Number, aimY:Number, aimZ:Number, time:int, gravity:Number = 0):void
		{
			if (time > 200)
			{
				this.tweenTo(this.spr, {alpha: 0}, 200, null, null, time - 200);
			}
			
			this.tweenTo(this, {update: new Handler(this, this.updatePos), x: aimX, y: aimY}, time, null, Handler.create(this, this.clear)); //Ease.linearIn

			
			if (gravity)
			{
				gravity = gravity * 0.07;
				
				//受重力，抛高
				var offsetZ:Number = aimZ - this.z;
				//时间片数
				var frame2:Number = time * ConfigFightView.FRAME_PER_MS;
				
				var speedX:Number = (aimX - this.x) / frame2;
				var speedZ0:Number = (offsetZ + 0.5*gravity * frame2 * frame2) / frame2;
				var rotation0:Number = Utils.toAngle(Math.atan(-speedZ0 / speedX));
				var rotation2:Number = 1.2;
				//if(this.isFlip){
					//rotation0 *= -1;
					//rotation2 *= -1;
				//}
				this.spr.rotation = rotation0;
				
				var speedZ2:Number;
				
				
				if(speedZ0 > 0){
					var frame1:Number = speedZ0 / gravity;
					var time1:Number = frame1/ConfigFightView.FRAME_PER_MS;
					var z1:Number = this.z + speedZ0 * frame1 - 0.5*gravity * frame1 * frame1;
					
					speedZ2 = speedZ0 - gravity * frame2;
					rotation2 *= Utils.toAngle(Math.atan(-speedZ2 / speedX));
					this.tweenTo(this.spr, {rotation: 0}, time1, Ease.sineOut);
					this.tweenTo(this.spr, {rotation: rotation2}, time-time1, Ease.sineIn, null, time1);
					
					this.tweenTo(this, {z: z1}, time1, Ease.sineOut);
					this.tweenTo(this, {z: aimZ}, time-time1, Ease.sineIn, null, time1);
				}
				else{
					//不存在最高点，直接向下
					speedZ2 = speedZ0 - gravity * frame2;
					rotation2 *= Utils.toAngle(Math.atan(-speedZ2 / speedX));
					this.tweenTo(this.spr, {rotation: rotation2}, time, Ease.sineIn);
					this.tweenTo(this, {z: aimZ}, time, Ease.sineIn);
				}
				
				//var halfTime:Number = time / 2;
				//var speedX:Number = dis / time;
				//var speedZ:Number = -gravity * halfTime * 0.0001;
				//var maxZ:Number = midZ - speedZ * halfTime;
				

				

			}
		}
	
	}

}