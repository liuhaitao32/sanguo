/**Created by the LayaAirIDE,do not modify.*/
package ui.festival {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon2UI;

	public class festivalLoginUI extends ItemBase {
		public var character:hero_icon2UI;
		public var rewardListPanel:Image;
		public var list_days:List;
		public var btn_reward:Button;
		public var txt_hint:Label;
		public var img_bg:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			super.createChildren();
			loadUI("festival/festivalLogin");

		}

	}
}