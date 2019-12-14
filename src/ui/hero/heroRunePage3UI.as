/**Created by the LayaAirIDE,do not modify.*/
package ui.hero {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.hero_icon_rune_txtUI;

	public class heroRunePage3UI extends ItemBase {
		public var adImg:Image;
		public var btn_go:Button;

		override protected function createChildren():void {
			View.regComponent("ui.com.hero_icon_rune_txtUI",hero_icon_rune_txtUI);
			super.createChildren();
			loadUI("hero/heroRunePage3");

		}

	}
}