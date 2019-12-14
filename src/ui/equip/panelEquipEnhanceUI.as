/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeSUI;

	public class panelEquipEnhanceUI extends ItemBase {
		public var btn:Button;
		public var img00:Image;
		public var img01:Image;
		public var comItem:payTypeSUI;
		public var text6:Label;
		public var text5:Label;
		public var box1:Box;
		public var img0:Image;
		public var text2:Label;
		public var box2:Box;
		public var img1:Image;
		public var text3:Label;
		public var box3:Box;
		public var img2:Image;
		public var text4:Label;
		public var box0:Box;
		public var text0:Label;
		public var text1:Label;
		public var boxAni:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("equip/panelEquipEnhance");

		}

	}
}