package sg.map.view {
	import laya.display.Sprite;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Image;
	import laya.utils.Handler;
	import laya.utils.Tween;
	import sg.utils.StringUtil;
	
	/**
	 * ...
	 * @author light
	 */
	public class PopText extends Sprite {
		
		public function PopText(str:String, colors:Array = null, defaultColor:String='#FFFFFF') {
			var bg:Image = new Image();
			bg.skin = "ui/bar_19.png";
			
			var text:HTMLDivElement = new HTMLDivElement();
			text.style.fontSize = 16;		
			StringUtil.setHtmlText(text, str, colors, defaultColor);
			text.width = 220;
			//text.pivotX = text.contextWidth / 2;
			Tween.to(this, {pivotY:50}, 500, null, Handler.create(this, function():void {
				this.timer.once(1000, this, function():void{
					Tween.to(this, {alpha:0}, 500, null, Handler.create(this, this.destroy, [true]));
				});
			}));
			
			bg.size(text.contextWidth + 80, text.contextHeight + 20);	
			//text.autoSize = true;
			text.pos((bg.width - text.contextWidth) / 2, (bg.height - text.contextHeight) / 2);
			bg.addChild(text);
			this.addChild(bg);
			
			
			
			
			
			
			
			
			bg.pivotX = bg.width / 2;
		}
		
		
		override public function destroy(destroyChild:Boolean = true):void {
			Tween.clearAll(this);
			super.destroy(destroyChild);
		}
		
	}

}