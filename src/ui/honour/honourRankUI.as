/**Created by the LayaAirIDE,do not modify.*/
package ui.honour {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import ui.com.item_titleUI;
	import ui.honour.itemHonourRankUI;
	import ui.honour.itemHonourRank1UI;

	public class honourRankUI extends ViewPanel {

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			View.regComponent("ui.honour.itemHonourRankUI",itemHonourRankUI);
			View.regComponent("ui.honour.itemHonourRank1UI",itemHonourRank1UI);
			super.createChildren();
			loadUI("honour/honourRank");

		}

	}
}