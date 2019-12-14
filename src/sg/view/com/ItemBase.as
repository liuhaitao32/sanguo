package sg.view.com
{
	import laya.ui.View;
	import sg.view.BaseSprite;
	import laya.events.Event;
	import sg.manager.LoadeManager;

	/**
	 * ...
	 * @author
	 */
	public class ItemBase extends BaseSprite{
		public function ItemBase(){
		}
		public function init():void{
		}
		public function onChange(type:* = null):void{
		}
		public function clear():void{
		}
		public function onRemove():void{
			this.clear();
		}
	}

}