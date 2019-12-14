/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class itemEquipTabUI extends ItemBase {
		public var btnBg:Button;
		public var imgIcon:Image;
		public var tName:Label;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("equip/itemEquipTab");

		}

	}
}