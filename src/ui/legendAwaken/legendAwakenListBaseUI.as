/**Created by the LayaAirIDE,do not modify.*/
package ui.legendAwaken {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;

	public class legendAwakenListBaseUI extends ItemBase {
		public var icon:hero_icon1UI;
		public var img_select:Image;
		public var box_hint:Box;
		public var txt_hint:Label;
		public var box_price:Box;
		public var img_item:Image;
		public var txt_price:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("legendAwaken/legendAwakenListBase");

		}

	}
}