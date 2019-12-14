package sg.guide.view 
{
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class MaskContainer extends Sprite 
	{
		private var sp_0:Sprite = new Sprite();
		private var sp_1:Sprite = new Sprite();
		private var sp_2:Sprite = new Sprite();
		private var sp_3:Sprite = new Sprite();
		public function MaskContainer() 
		{
			//var stageW:Number = Laya.stage.width;
			//var stageH:Number = Laya.stage.height;
			//this.cacheAs = "bitmap"; // 设置容器位画布缓存
			//this.size(stageW, stageH);
			//
			//// 绘制遮罩区，含透明度
			//var maskArea:Sprite = new Sprite();
			//maskArea.alpha = 0.75;
			//maskArea.graphics.drawRect(0, 0, stageW, stageH, "#000000");
			for (var i:int = 0; i < 4; i++) 
			{
				this["sp_" + i].alpha = 0.75;
			}
			this.addChildren(this.sp_0, this.sp_1, this.sp_2, this.sp_3);
		}
		
		public function show(rect:Rectangle):void {
			var stageW:Number = Laya.stage.width;
			var stageH:Number = Laya.stage.height;
			var x:Number = rect.x;
			var y:Number = rect.y;
			var width:Number = rect.width;
			var height:Number = rect.height;
			this.clearContainer();
			this.sp_0.graphics.drawRect(0, 0, x + width, y, "#000000");
			this.sp_1.graphics.drawRect(x + width, 0, stageW - (x + width), y + height, "#000000");
			this.sp_2.graphics.drawRect(0, y, x, stageH - y, "#000000");
			this.sp_3.graphics.drawRect(x, y + height, stageW - x, stageH - (y + height), "#000000");
			// this.visible = true;
		}
		
		private function clearContainer():void {
			for (var i:int = 0; i < 4; i++) 
			{
				this["sp_" + i].graphics.clear();
			}
		}
		public function hide():void {
			this.clearContainer();
		}
	}

}