/**Created by the LayaAirIDE,do not modify.*/
package ui.activities {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.shop.shop_icon_textUI;

	public class activitiesSceneUI extends ViewScenes {
		public var box:Box;
		public var tabList:List;
		public var arrow_l:Box;
		public var arrow_r:Box;

		override protected function createChildren():void {
			View.regComponent("ui.shop.shop_icon_textUI",shop_icon_textUI);
			super.createChildren();
			loadUI("activities/activitiesScene");

		}

	}
}