/**Created by the LayaAirIDE,do not modify.*/
package ui.inside {
	import laya.ui.*;
	import laya.display.*; 
	import sg.view.*; 
	import sg.view.com.*; 
	import ui.com.pve_starUI;
	import ui.com.hero_icon1UI;

	public class pveItemUI extends ViewScenes {
		public var box1:Box;
		public var box2:Box;
		public var box3:Box;
		public var box4:Box;

		override protected function createChildren():void {
			View.regComponent("ui.com.pve_starUI",pve_starUI);
			View.regComponent("ui.com.hero_icon1UI",hero_icon1UI);
			super.createChildren();
			loadUI("inside/pveItem");

		}

	}
}