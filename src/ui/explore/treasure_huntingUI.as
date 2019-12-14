/**Created by the LayaAirIDE,do not modify.*/
package ui.explore {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.payTypeUI;
	import ui.com.payTypeBigUI;
	import ui.com.country_flag2UI;

	public class treasure_huntingUI extends ViewScenes {
		public var box:Box;
		public var box_pic:Box;
		public var bg:Image;
		public var pic_2:Image;
		public var groupPanel1:Panel;
		public var pic_0:Image;
		public var pic_1:Image;
		public var groupPanel0:Panel;
		public var btn_back:Box;
		public var box_search:Box;
		public var icon_cost:payTypeUI;
		public var btn_search:Box;
		public var btn_shop:Box;
		public var box_fight:Box;
		public var txt_fight:Label;
		public var btn_fight:Box;
		public var btn_pray:Box;
		public var btn_msg:Box;
		public var txt_pray:Label;
		public var box_resource:Box;
		public var icon_Resource:payTypeBigUI;
		public var btn_help:Button;
		public var name_box_enemy:Box;
		public var icon_country:country_flag2UI;
		public var txt_name_enemy:Label;

		override protected function createChildren():void {
			View.regComponent("ui.com.payTypeUI",payTypeUI);
			View.regComponent("ui.com.payTypeBigUI",payTypeBigUI);
			View.regComponent("ui.com.country_flag2UI",country_flag2UI);
			super.createChildren();
			loadUI("explore/treasure_hunting");

		}

	}
}