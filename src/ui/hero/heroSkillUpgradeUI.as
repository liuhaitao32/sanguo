/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.bag.bagItemUI;
	import ui.com.btn_icon_txtUI;
	import ui.com.btn_icon_txt_sureUI;
	import laya.html.dom.HTMLDivElement;
	import ui.com.item_titleUI;

	public class heroSkillUpgradeUI extends ViewPanel {
		public var mBox:Box;
		public var imgLearn:Image;
		public var barColor:Image;
		public var boxDetail:Box;
		public var skillIcon:bagItemUI;
		public var btnSpecial:CheckBox;
		public var btn_del:Button;
		public var errBox:Box;
		public var tTips:Label;
		public var btn_coin:btn_icon_txtUI;
		public var btn_gold:btn_icon_txt_sureUI;
		public var btn_from:Button;
		public var skillIcon1:bagItemUI;
		public var barSkill:ProgressBar;
		public var tName:Label;
		public var tLv:Label;
		public var tType:Label;
		public var tAbility:Label;
		public var tTypeV:Label;
		public var ability_info:Label;
		public var tRound:Label;
		public var tRoundV:Label;
		public var tSkill:Label;
		public var tLearn:Label;
		public var dengji:Label;
		public var clipBox:Box;
		public var boxAdjutant:Box;
		public var btn_go:Button;
		public var hInfo:HTMLDivElement;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.bag.bagItemUI",bagItemUI);
			View.regComponent("ui.com.btn_icon_txtUI",btn_icon_txtUI);
			View.regComponent("ui.com.btn_icon_txt_sureUI",btn_icon_txt_sureUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/heroSkillUpgrade");

		}

	}
}