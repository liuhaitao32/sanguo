/**Created by the LayaAirIDE,do not modify.*/
package ui.newTask {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.hero_icon2UI;
	import ui.newTask.item_newtaskUI;
	import ui.com.item_titleUI;

	public class newtask_mainUI extends ViewPanel {
		public var comHero:hero_icon2UI;
		public var list:List;
		public var comTitle:item_titleUI;
		public var btn:Button;
		public var boxTips:Box;
		public var text0:Label;
		public var textInfo:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.newTask.item_newtaskUI",item_newtaskUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("newTask/newtask_main");

		}

	}
}