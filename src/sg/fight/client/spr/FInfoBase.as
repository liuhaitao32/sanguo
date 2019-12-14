package sg.fight.client.spr 
{
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.view.FightSceneBase;
	/**
	 * 战斗无透视信息面板(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FInfoBase extends FSpriteBase
	{
		public var standX:Number;
		public var standY:Number;
		
		public function FInfoBase(scene:FightSceneBase,id:String, x:Number, y:Number, z:Number, isFlip:Boolean, baseScale:Number = 1, baseAlpha:Number = 1)
		{
			this.standX = x;
            this.standY = y;
			super(scene,id, x, y, z, isFlip, baseScale, baseAlpha);
		}
		/**
		 * 前进并停留在新位置
		 */
		public function move(offset:Number, speedRate:Number = 1):void
		{
			this.standX = this.standX + offset;
			
			if (speedRate <= 0)
			{
				this.x = this.standX;
				this.updatePos();
			}
			else{
				var dis:Number = Math.abs(offset);
				var time:int = ConfigFightView.MOVE_BASE_TIME + parseInt((dis/ConfigFightView.MOVE_BASE_SPEED / speedRate).toString());
				this.tweenTo(this, {update:new Handler(this, this.updatePos), x:this.standX}, time, Ease.sineInOut);
			}
		}
		public function moveTo(x:Number, speedRate:Number = 1):void
		{
			this.move(x - this.standX, speedRate);
		}
		
		/**
		 * 重显现
		 */
		public function reShow():void
		{
			this.appear();
			this.resetPos();
		}
		public function resetPos():void
		{
			this.x = this.getX();
			this.updatePos();
		}
		public function getX():int
		{
			return 0;
		}
		
		/**
		 * 平面转换视图坐标，无需透视(可以不做缩放变换)
		 */
		override public function updatePos(changeScale:Boolean = false):void
		{
			if (!this.spr || this.spr.destroyed)
				return;
			var scale:Number = 1 + this.y * ConfigFightView.PERSPECTIVE;
			this.spr.y = this.y - this.z;
			this.spr.x = (this.x - this.scene.cameraOffset) * scale;
	
			if (changeScale)
			{
				this.spr.scale(this._baseScale, this._baseScale);
			}
		}
		

	}

}