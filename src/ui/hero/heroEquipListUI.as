/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.inside.equipItemUI;
	import laya.html.dom.HTMLDivElement;

	public class heroEquipListUI extends ViewPanel {
		public var list:List;
		public var tName:Label;
		public var text0:Label;
		public var attrInfo:Box;
		public var washInfo:HTMLDivElement;
		public var enhanceInfo:HTMLDivElement;
		public var box1:Box;
		public var text1:Label;
		public var box2:Box;
		public var text2:Label;
		public var btn_ok:Button;
		public var btn_up:Button;
		public var btn_wash:Button;
		public var btn_en:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.inside.equipItemUI",equipItemUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("hero/heroEquipList");

		}

	}
}