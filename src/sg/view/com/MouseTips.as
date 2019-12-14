package sg.view.com 
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.maths.Point;
	import ui.com.mouse_tipsUI;
	/**
	 * 鼠标悬浮 提示
	 * @author zhuda
	 */
	public class MouseTips extends mouse_tipsUI
	{
		public var htmlDiv:HTMLDivElement;
		
		public var initWidth:Number;
		//public var initHeight:Number;
		
		public function MouseTips() 
		{
			this.mouseEnabled = false;
			this.mouseThrough = true;
			this.label.color = '#FFCC66';
			this.label.fontSize = 14;
			this.label.leading = 6;
			this.label.align = 'left';
			this.initWidth = 400;
			//this.initWidth = this.label.width;
			//this.initHeight = this.label.height;
			
			this.htmlDiv = new HTMLDivElement();
			this.htmlDiv.width = this.initWidth;
			this.htmlDiv.style.leading = 6;
			this.htmlDiv.style.fontSize = 14;
			this.addChild(this.htmlDiv);
		}
		
		public function showInfo(spr:Sprite, info:String, isHtml:Boolean = false, width:int = 0) :void
		{
			this.htmlDiv.visible = isHtml;
			this.label.visible = !isHtml;
			Laya.stage.addChild(this);
			var p:Point = new Point(spr.width * 0.5, 0);
			spr.localToGlobal(p);
			var w:Number;
			var h:Number;
			var xx:Number;
			var yy:Number;
			var tempDis:int = 20;
			
			if (isHtml){
				this.htmlDiv.innerHTML = info;
				if(!width){
					this.htmlDiv.width = this.initWidth;
				}
				else{
					this.htmlDiv.width = width;
				}
				w = this.htmlDiv.contextWidth + tempDis;
				this.htmlDiv.width = w - tempDis;
				
				h = this.htmlDiv.contextHeight + tempDis;
				this.htmlDiv.height = h - tempDis;
				
				this.htmlDiv.x = -(w - tempDis*3) / 2;
				this.htmlDiv.y = -(h - tempDis*2.5);
			}
			else{
				this.label.text = info;
				if(!width){
					this.label.width = this.initWidth;
				}
				else{
					this.label.width = width;
				}
				w = this.label.textField.textWidth + tempDis;
				this.label.width = w -tempDis;

				h = this.label.textField.textHeight + tempDis;
				this.label.height = h -tempDis;
			}
			
			xx = p.x;
			xx = Math.min(Laya.stage.width - w * 0.5,Math.max(xx, w * 0.5));
			yy = p.y;
			if (yy < h){
				//向下对齐
				yy = p.y + spr.height * spr.globalScaleY + h;
			}
			
			this.bgImg.width = w;
			this.bgImg.height = h;
			this.pos(xx, yy);
		}
		
	}

}