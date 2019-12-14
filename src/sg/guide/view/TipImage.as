package sg.guide.view 
{
	import laya.display.Sprite;
	import laya.resource.Texture;
	import laya.utils.Handler;
	
	/**
	 * 引导中使用的提示图片所在的容器
	 * @author jiaxuyang
	 */
	public class TipImage extends Sprite 
	{
		
		public function TipImage() 
		{
		}
		
		public function showImage(imageUrl:String, imagePos:Object):void {
			this.loadImage("guide/" + imageUrl, imagePos.x, imagePos.y, 0, 0, Handler.create(this, this.onImageLoaded));
		}
		
		public function hide():void {
			this.graphics.clear();
		}
		
		private function onImageLoaded(tex:Texture):void {
			this.size(tex.sourceWidth, tex.sourceHeight);
			
			this.pivotX = this.width * 0.5;
			this.pivotY = this.height * 0.5;
		}
	}

}