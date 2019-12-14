package sg.guide.view
{
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.HitArea;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ClickContainer extends Sprite
	{
		private var sp_0:Sprite = new Sprite();
		private var sp_1:Sprite = new Sprite();
		private var sp_2:Sprite = new Sprite();
		private var sp_3:Sprite = new Sprite();
		
		private var hitArea_0:HitArea = new HitArea();
		private var hitArea_1:HitArea = new HitArea();
		private var hitArea_2:HitArea = new HitArea();
		private var hitArea_3:HitArea = new HitArea();
		
		private var rect:Rectangle;
		public function ClickContainer()
		{
			this._initContainer();
		}
		
		private function _initContainer():void
		{
			var stageW:Number = Laya.stage.width;
			var stageH:Number = Laya.stage.height;
			var sp:Sprite = null;
			
			for (var i:int = 0; i < 4; i++)
			{
				var name:String = "sp_" + i;
				sp = this[name];
				sp.name = name;
				sp.hitArea = this["hitArea_" + i];
				this.addChildren(sp);
				sp.on(Event.CLICK, this, this._onClickSprite);
			}
		}
		
		public function show(rect:Rectangle):void {
			var stageW:Number = Laya.stage.width;
			var stageH:Number = Laya.stage.height;
			var x:Number = rect.x;
			var y:Number = rect.y;
			var width:Number = rect.width;
			var height:Number = rect.height;
			this.rect = rect;
			this.hide();
			this.hitArea_0.hit.drawRect(0, 0, x + width, y, "#ffff00");
			this.hitArea_1.hit.drawRect(x + width, 0, stageW - (x + width), y + height, "#ff0000");
			this.hitArea_2.hit.drawRect(0, y, x, stageH - y, "#00ff00");
			this.hitArea_3.hit.drawRect(x, y + height, stageW - x, stageH - (y + height), "#0000ff");
		}
				
		private function _onClickSprite(event:Event):void
		{
			// trace(event.target);
			// trace(event.target.name);
		}
				
		public function checkPoint(pos:Point):Boolean
		{
			return rect.contains(pos.x, pos.y);
		}
		
		public function hide():void
		{
			for (var i:int = 0; i < 4; i++)
			{
				this["hitArea_" + i].hit.clear();
			}
		}
	
	}

}