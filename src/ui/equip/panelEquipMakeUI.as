/**Created by the LayaAirIDE,do not modify.*/
package ui.equip {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txt_blueUI;
	import laya.html.dom.HTMLDivElement;

	public class panelEquipMakeUI extends ItemBase {
		public var btn_make:Button;
		public var btn1:btn_icon_txt_sureUI;
		public var btn0:btn_icon_txt_blueUI;
		public var equipArr:Box;
		public var box0:Box;
		public var img00:Image;
		public var img01:Image;
		public var text0:Label;
		public var box2:Box;
		public var text2:HTMLDivElement;
		public var box3:Box;
		public var tText:Label;
		public var boxNum:Box;
		public var box1:Box;
		public var img10:Image;
		public var img11:Image;
		public var text1:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txt_blueUI",btn_icon_txt_blueUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("equip/panelEquipMake");

		}

	}
}