/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.panel_bg_btnUI;
	import laya.html.dom.HTMLDivElement;
	import ui.hero.heroRuneItemUI;
	import ui.com.item_titleUI;

	public class heroRuneUpgradeUI extends ViewPanel {
		public var mBox:Box;
		public var bar:ProgressBar;
		public var tName:Label;
		public var tLv:Label;
		public var tExp:Label;
		public var tOnly:Label;
		public var tProp:Label;
		public var tClick:Label;
		public var tDown:Label;
		public var hInfo:HTMLDivElement;
		public var hNext:HTMLDivElement;
		public var runeIcon:heroRuneItemUI;
		public var clipBox:Box;
		public var comTitle:item_titleUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.panel_bg_btnUI",panel_bg_btnUI);
			View.regComponent("HTMLDivElement",HTMLDivElement);
			View.regComponent("ui.hero.heroRuneItemUI",heroRuneItemUI);
			View.regComponent("ui.com.item_titleUI",item_titleUI);
			super.createChildren();
			loadUI("hero/heroRuneUpgrade");

		}

	}
}