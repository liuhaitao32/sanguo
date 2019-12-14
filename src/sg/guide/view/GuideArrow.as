package sg.guide.view 
{
	import laya.display.Sprite;
	import laya.maths.Point;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Timer;
	import laya.utils.Tween;

	import sg.manager.AssetsManager;
	import laya.utils.Ease;
	import sg.map.utils.Math2;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class GuideArrow extends Sprite 
	{
		private var arrowImage:Image;
		private var tempTimer:Timer;
		private var angle:Number = 0;
		private var speed:Number = 0.12;
		private var range:Number = 12;
		private var _reset:Boolean = true;
		private var _prevX:Number = 0;
		private var _prevY:Number = 0;
		private var tween_r:Tween = null;
		private var desRotation:Number = 0;
		private var _duration:Number = 0;
		public function GuideArrow() 
		{
			this.tempTimer = new Timer();
			this._initArrow();
		}
		
		private function _initArrow():void {
			this.arrowImage = new Image(AssetsManager.getAssetsUI('btn_jiantou.png'));
			this.arrowImage.setBounds(this.getBounds());
			this.arrowImage.anchorX = 0.5;
			this.arrowImage.anchorY = 0.5;
			this.addChild(this.arrowImage);
			this.visible = false;
		}
		
		private function onFrameChange():void {
			this.arrowImage.x = (Math.sin(this.angle) - 1) * this.range;
			this.angle += this.speed;
		}
		
		public function show(x:Number = 0, y:Number = 0, rotation:Number = 0):void {
			var radian:Number = Math2.angleToRadian(rotation);
			y -= Math.sin(radian) * this.arrowImage.height * 0.5;
			x -= Math.cos(radian) * this.arrowImage.width;
			var speed:Number = 800; // 像素每秒
			var duration:Number = this._duration = Point.TEMP.setTo(x, y).distance(this.x, this.y) / speed * 1000;
			this.desRotation = rotation;
			if (this._reset) {
				this.pos(Laya.stage.width * 0.5, Laya.stage.height * 0.5);
				duration = this._duration = Point.TEMP.setTo(x, y).distance(this.x, this.y) / speed * 1000;
				this._prevX = this.x;
				this._prevY = this.y;
				this.rotation = duration < 800 ? 90 : Math2.radianToAngle(Math.atan2(y - this.y, x - this.x));
			}
			duration = duration > 1000 ? 1000 : duration; // 箭头飞行时间最多1秒
			this.resetRotation();
			this.visible = true;
			this._reset = false;
			Tween.clearAll(this);
			this.alpha = 0;
			Tween.to(this, {alpha: 1}, 500, Ease.linearNone);
			Tween.to(this, {x: x, y: y, rotation: rotation}, duration, Ease.linearNone, Handler.create(tempTimer, tempTimer.frameLoop, [1, this, this.onFrameChange]));
		}

		private function _updateRotation():void
		{
			if (this.y < this._prevY) {
				this.rotation = Math2.radianToAngle(Math.atan2(y - this._prevY, x - this._prevX));
				this._prevX = this.x;
				this._prevY = this.y;
			}
			else {
				this.resetRotation();
				Tween.to(this, {rotation: this.desRotation}, (this._duration - tween_r.usedTimer), Ease.linearNone);
				Tween.clear(tween_r);
			}
		}

		private function resetRotation():void
		{
			if (Math.abs(this.desRotation - this.rotation) > 180) {
				 this.rotation += 360 * (this.rotation < 0 ? 1 : -1);
			}
		}
		
		public function reset():void {
			this.hide();
			this._reset = true;
		}
		
		public function hide():void {
			this.visible = false;
			Tween.clearTween(this);
			this.tempTimer.clear(this, this.onFrameChange);
		}
	}

}