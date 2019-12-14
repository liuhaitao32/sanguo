/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_starUI;

	public class heroPropertyUI extends ItemBase {
		public var clipBox:Box;
		public var btn_star:Button;
		public var btn_lv:Button;
		public var barExp:ProgressBar;
		public var barStar:ProgressBar;
		public var btn_pub:Button;
		public var tLv:Label;
		public var tStarPro:Label;
		public var tExp:Label;
		public var heroStar:hero_starUI;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_starUI",hero_starUI);
			super.createChildren();
			loadUI("hero/heroProperty");

		}

	}
}