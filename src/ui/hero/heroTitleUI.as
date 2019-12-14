/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;

	public class heroTitleUI extends ViewPanel {
		public var mBox:Box;
		public var adImg:Image;
		public var btn:Button;
		public var text2:Label;
		public var text1:Label;
		public var tInfo:Label;
		public var list:List;
		public var tPassive:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/heroTitle");

		}

	}
}