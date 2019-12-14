/**Created by the LayaAirIDE,do not modify.*/
package ui.arena {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.arena.itemArenaheroUI;
	import ui.com.hero_icon1UI;
	import ui.com.country_flag1UI;

	public class arenaDeployUI extends ViewPanel {
		public var mBox:Box;
		public var comTitle:item_titleUI;
		public var btn:Button;
		public var head0:hero_icon1UI;
		public var country0:country_flag1UI;
		public var text0:Label;
		public var name0:Label;
		public var info0:Label;
		public var head1:hero_icon1UI;
		public var country1:country_flag1UI;
		public var text1:Label;
		public var name1:Label;
		public var info1:Label;
		public var text2:Label;
		public var text3:Label;
		public var text4:Label;
		public var text5:Label;
		public var meTips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.arena.itemArenaheroUI",itemArenaheroUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("arena/arenaDeploy");

		}

	}
}