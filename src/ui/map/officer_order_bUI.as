/**Created by the LayaAirIDE,do not modify.*/
package ui.map {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.btn_icon_txt_sureUI;
	import ui.com.btn_icon_txtUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_titleUI;

	public class officer_order_bUI extends ViewPanel {
		public var mBox:Box;
		public var att_coin:btn_icon_txt_sureUI;
		public var att_free:btn_icon_txtUI;
		public var def_coin:btn_icon_txt_sureUI;
		public var def_free:btn_icon_txtUI;
		public var imgOrder1:Image;
		public var attName:Label;
		public var jiacheng_1:Label;
		public var attInfo:HTMLDivElement;
		public var imgOrder2:Image;
		public var defName:Label;
		public var jiacheng_2:Label;
		public var defInfo:HTMLDivElement;
		public var attMerit:Label;
		public var kaiqi_1:Label;
		public var attTips:HTMLDivElement;
		public var defTips:HTMLDivElement;
		public var defMerit:Label;
		public var kaiqi_2:Label;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("map/officer_order_b");

		}

	}
}