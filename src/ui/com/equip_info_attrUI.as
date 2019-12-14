/**Created by the LayaAirIDE,do not modify.*/
package ui.com {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 

	public class equip_info_attrUI extends ItemBase {
		public var bg:Image;
		public var txt:Label;
		public var icon:Button;

		override protected function createChildren():void {
			super.createChildren();
			loadUI("com/equip_info_attr");

		}

	}
}