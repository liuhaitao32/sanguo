package sg.scene.view 
{
	import laya.display.Sprite;
	import laya.map.GridSprite;
	import sg.map.utils.ArrayUtils;
	
	/**
	 * ...
	 * @author light
	 */
	public class EventGridSprite extends GridSprite {
		
		public var items:Array;
		
		public var eventLayer:EventLayer;
		
		public var enabled:Boolean = true;
		
		public function EventGridSprite(eventlayer:EventLayer) {
			this.eventLayer = eventlayer;
		}
		
		public function addItemSprite(sprite:Sprite):void {
			if (this.items == null) {
				this.items = [];
			}
			ArrayUtils.push(sprite, this.items);
		}
		
		public function removeItemSprite(sprite:Sprite):void {
			if (this.items) ArrayUtils.remove(sprite, this.items);
		}
		
		override public function show():void {
			this.enabled = true;
			if (!this.visible && this.items) {
				for (var j:int = 0, len2:int = this.items.length; j < len2; j++) {
					this.items[j].show();
				}	
			}
			super.show();		
		}
		
		override public function hide():void {
			this.enabled = false;
			if (this.visible && this.items) {
				for (var j:int = 0, len2:int = this.items.length; j < len2; j++) {
					this.items[j].hide();
				}	
			}
			super.hide();
		}
		
		override public function clearAll():void {
			this.items = null;
			this.enabled = true;
			super.clearAll();
		}
	}

}