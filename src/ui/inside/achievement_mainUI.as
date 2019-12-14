/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.inside.achievement_baseUI;
	import ui.com.payTypeSUI;

	public class achievement_mainUI extends ViewScenes {
		public var mc_tips:Box;
		public var tipsTxt:Label;
		public var achieveList:List;
		public var tabList:List;
		public var mcComplete:payTypeSUI;

		override protected function createChildren():void {
			View.regComponent("ui.inside.achievement_baseUI",achievement_baseUI);
			View.regComponent("ui.com.payTypeSUI",payTypeSUI);
			super.createChildren();
			loadUI("inside/achievement_main");

		}

	}
}