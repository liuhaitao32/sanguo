package sg.fight.client.spr 
{
	import laya.ui.Image;
	import sg.fight.client.cfg.ConfigFightView;
	import sg.fight.client.spr.FSpriteBase;
	import sg.fight.client.view.FightSceneBase;
	import sg.manager.AssetsManager;
	/**
	 * 战斗中的小静态图(控制器，spr为显示对象)
	 * @author zhuda
	 */
	public class FImage extends FSpriteBase
	{
		public var addToBg:Boolean;
		///强制渲染宽度
		public var halfWidth:Number;
		
		public function FImage(scene:FightSceneBase,id:String, x:Number, y:Number, isFlip:Boolean, baseScale:Number = 1, baseAlpha:Number = 1, addToBg:Boolean = false, halfWidth:Number = 0)
		{
			this.halfWidth = halfWidth;
			this.addToBg = addToBg;
			super(scene, id, x, y, 0, isFlip, baseScale, baseAlpha);
		}
		
		public function get img():Image
		{
			return this.spr as Image;	
		}
		
		override public function init():void
		{
			this.spr = new Image(AssetsManager.getAssetsFight(this.id));
			if(this.addToBg){
				this.addBgToScene();
			}
			else{
				this.addToScene();
			}
			
			//Laya.stage.on(Event.MOUSE_DOWN, this, this.mouseDown);
		}
		//public function mouseDown():void
		//{
			//this.spr.alpha = 0.5;
			//trace("点击");
		//}
		
		
		/**
		 * 平面转换视图坐标(可以不做缩放变换)
		 */
		override public function updatePos(changeScale:Boolean = false):void
		{
			if (!this.spr || this.spr.destroyed)
				return;
			//var scale:Number = 1 + this.y * ConfigFightView.PERSPECTIVE;
			//this.spr.y = this.y * scale;
			this.spr.y = this.transScreenY(this.y);
			var scale:Number = 1 + this.spr.y * ConfigFightView.PERSPECTIVE;
			var tempX:Number = (this.x - this.scene.cameraOffset) * scale;
			if (!this.forcedRender && (tempX+this.halfWidth < -ConfigFightView.VISIBLE_HALF_WIDTH || tempX-this.halfWidth > ConfigFightView.VISIBLE_HALF_WIDTH))
			{
				this.spr.visible = false;
			}
			else
			{
				this.spr.visible = true;
				this.spr.x = tempX;
				this.spr.y -= this.z * scale;
			}
			
			if (changeScale)
			{
				//this.ani.alpha = scale*0.9;
				scale *= this._baseScale;
				this.spr.scale(this.isFlip ? -scale : scale, scale);
					//this._ani.scale(-3, scale);
			}
		}
	}

}