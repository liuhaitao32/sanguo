/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btn_sUI;
	import ui.com.hero_icon2UI;
	import ui.com.item_titleUI;
	import ui.bag.bagItemUI;

	public class visitFinishUI extends ViewPanel {
		public var imgBG:Image;
		public var comBig:hero_icon2UI;
		public var btn:Button;
		public var text0:Label;
		public var comTitle:item_titleUI;
		public var pro0:ProgressBar;
		public var pro5:ProgressBar;
		public var pro4:ProgressBar;
		public var pro3:ProgressBar;
		public var pro2:ProgressBar;
		public var pro1:ProgressBar;
		public var img4:Image;
		public var img3:Image;
		public var img2:Image;
		public var img1:Image;
		public var img0:Image;
		public var label:Label;
		public var list:List;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btn_sUI",panel_bg_btn_sUI);
			View.regComponent("ui.com.hero_icon2UI",hero_icon2UI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			super.createChildren();
			loadUI("map/visitFinish");

		}

	}
}