package sg.fight.client.view 
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import sg.fight.client.utils.FightTime;
	import sg.fight.test.TestFightData;
	import sg.guide.view.GuideFocus;
	/**
	 * 战斗场景
	 * @author zhuda
	 */
	public class FightScene extends FightSceneBase
	{
		public var minCameraOffset:Number;
		public var maxCameraOffset:Number;
		///交战中心
		public var centerCameraOffset:Number = 0;
		
		private var _lastCameraOffset:Number;
		private var _lastMouseX:Number;

		public function FightScene(id:String = null) 
		{
			super(id);
		}

		public function resetPos():void
		{
			this.mouseUp();
			this._lastMouseX = 0;
			this._lastCameraOffset = 0;
			this.cameraOffset = 0;
			this.updatePos();
		}
		
		override public function init() :void
		{
			this._lastMouseX = 0;
			this._lastCameraOffset = 0;
			super.init();
		}
		override public function onRemovedBase():void
		{
			super.onRemovedBase();
			Laya.stage.off(Event.MOUSE_MOVE, this, this.mouseMove);
			Laya.stage.off(Event.MOUSE_UP, this, this.mouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, this.mouseUp);
			this.on(Event.MOUSE_DOWN, this, this.mouseDown);
		}
		/**
		 * 自动滚屏到战斗焦点
		 */
		public function tweenToCenter(time:int = 1500):void
		{
			this.offDrag();
			FightTime.tweenTo(
				this, 
				{
					update:new Handler(this, this.updatePos), 
					cameraOffset:this.centerCameraOffset
				},
				time, 
				Ease.sineInOut,
				Handler.create(this, function():void{
					this.mouseUp();
					this.initDrag();
				})
			);
		}
		
		/**
		 * 开始拖动，需要等待战斗初始化完毕
		 */
		public function initDrag():void
		{
			if (TestFightData.testMode == -3){
				//不加载
				return;
			}
			this.mouseEnabled = true;
			this.on(Event.MOUSE_DOWN, this, this.mouseDown);
			//console.trace('initDrag');
		}
		/**
		 * 停止拖动
		 */
		public function offDrag():void
		{
			this.mouseUp();
			this.mouseEnabled = false;
			this.off(Event.MOUSE_DOWN, this, this.mouseDown);
		}
		private function mouseMove():void
		{
			this.cameraOffset = this._lastCameraOffset + this._lastMouseX - Laya.stage.mouseX;
			this.cameraOffset = Math.max(this.minCameraOffset, Math.min(this.maxCameraOffset, this.cameraOffset));
			this.updatePos();
		}
		private function mouseUp():void
		{
			this._lastCameraOffset = this.cameraOffset;
			Laya.stage.off(Event.MOUSE_MOVE, this, this.mouseMove);
			Laya.stage.off(Event.MOUSE_UP, this, this.mouseUp);
			Laya.stage.off(Event.MOUSE_OUT, this, this.mouseUp);
		}
		private function mouseDown():void
		{
			GuideFocus.focusOut();
			this._lastMouseX = Laya.stage.mouseX;
			Laya.stage.on(Event.MOUSE_MOVE, this, this.mouseMove);
			Laya.stage.on(Event.MOUSE_UP, this, this.mouseUp);
			Laya.stage.on(Event.MOUSE_OUT, this, this.mouseUp);
		}
	}

}