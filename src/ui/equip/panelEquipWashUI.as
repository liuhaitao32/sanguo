/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.equip.itemWash1UI;
	import ui.com.payTypeSUI;

	public class panelEquipWashUI extends ItemBase {
		public var list1:List;
		public var btnGiveUp:Button;
		public var btnSave:Button;
		public var img4:Image;
		public var img3:Image;
		public var img2:Image;
		public var img1:Image;
		public var img0:Image;
		public var comNum:payTypeSUI;
		public var tText:Label;
		public var list0:List;
		public var btnWash:Button;

		override protected function createChildren():void {
			View.regComponent("ui.equip.itemWash1UI",itemWash1UI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("equip/panelEquipWash");

		}

	}
}