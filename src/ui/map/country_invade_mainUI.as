/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import sg.outline.view.OutlineViewCommon;
	import ui.bag.bagItemUI;
	import ui.com.comCountryOfficialUI;

	public class country_invade_mainUI extends ViewPanel {
		public var mBox:Box;
		public var outline:OutlineViewCommon;
		public var box_award:Box;
		public var boxClip1:Box;
		public var reward:bagItemUI;
		public var btn_country:Button;
		public var isGet1:Image;
		public var iName1:Label;
		public var txt_reward0:Label;
		public var box_award_merit:Box;
		public var img_reward_year:Image;
		public var iName2:Label;
		public var txt_reward1:Label;
		public var txt_ratio:Label;
		public var tNoInfo:Box;
		public var zhanling:Label;
		public var rewardList:List;
		public var txt_mail:Label;
		public var txt_reward_title:Label;
		public var btnHelp:Button;
		public var btn_go:Button;
		public var tInfo:Label;
		public var iTitle:Label;
		public var list:List;
		public var tName:Label;
		public var iRuler:Box;
		public var text0:Label;
		public var officerList:List;
		public var btnHelp2:Button;
		public var img_ad:Image;
		public var txt_count_tips:Label;
		public var txt_tips:Label;

		override protected function createChildren():void {
			View.regComponent("sg.outline.view.OutlineViewCommon",OutlineViewCommon);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.comCountryOfficialUI",comCountryOfficialUI);
			super.createChildren();
			loadUI("map/country_invade_main");

		}

	}
}