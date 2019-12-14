/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.pve_starUI;
	import ui.com.hero_icon1UI;

	public class pveItem01UI extends ViewPanel {
		public var adImg:Image;

		override protected function createChildren():void {
			View.regComponent("ui.com.pve_starUI",pve_starUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("inside/pveItem01");

		}

	}
}