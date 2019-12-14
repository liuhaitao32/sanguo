/**Created by the LayaAirIDE,do not modify.*/
package ui.menu {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.country_flag1UI;
	import laya.html.dom.HTMLDivElement;

	public class bottomUI extends ItemBase {
		public var chat_bg:Image;
		public var bottom_bg:Image;
		public var btn_hero:Button;
		public var heroLabel:Label;
		public var btn_fight:Button;
		public var fightLabel:Label;
		public var btn_bag:Button;
		public var bagLabel:Label;
		public var btn_shop:Button;
		public var shopLabel:Label;
		public var btn_team:Button;
		public var guildLabel:Label;
		public var btn_season:Image;
		public var imgSeason:Image;
		public var btn_map2:Button;
		public var iMap2:Label;
		public var btn_map1:Button;
		public var mapName:Label;
		public var btn_chat:Box;
		public var chat_country:country_flag1UI;
		public var chat_name:Label;
		public var chat_btn:Button;
		public var chat_pan:Panel;
		public var chat_info:HTMLDivElement;
		public var btn_task:Button;
		public var iTask:Label;
		public var taskPanel:Box;
		public var content:HTMLDivElement;
		public var title:Label;
		public var btn_hintReward:Image;
		public var btn_reward:Image;
		public var btn_mayor:Button;
		public var iMayor:Label;
		public var btn_train:Button;
		public var iTrain:Label;
		public var btn_build:Button;
		public var iBuild:Label;
		public var btn_mng:Button;
		public var heromagLabel:Label;
		public var btn_alien:Box;
		public var imgAlien:Image;
		public var btn_more:Button;
		public var iMore:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.country_flag1UI",country_flag1UI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			super.createChildren();
			loadUI("menu/bottom");

		}

	}
}