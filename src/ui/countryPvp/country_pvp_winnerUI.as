/**Created by the LayaAirIDE,do not modify.*/
package ui.countryPvp {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon1UI;
	import ui.com.rank_inder_img_t_bigUI;
	import ui.com.country_flag1UI;

	public class country_pvp_winnerUI extends ItemBase {
		public var tempimg:Image;
		public var light0:Image;
		public var light1:Image;
		public var light2:Image;
		public var light3:Image;
		public var light4:Image;
		public var country0:Image;
		public var country1:Image;
		public var country2:Image;
		public var country3:Image;
		public var country4:Image;
		public var imgFlag:Image;
		public var btn:Button;
		public var text5:Label;
		public var text3:Label;
		public var tTitle:Label;
		public var tCountry:Label;
		public var text4:Label;
		public var text0:Label;
		public var text1:Label;
		public var text2:Label;
		public var list:List;
		public var tTips:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			View.regComponent("ui.com.rank_inder_img_t_bigUI",rank_inder_img_t_bigUI);
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			super.createChildren();
			loadUI("countryPvp/country_pvp_winner");

		}

	}
}